# ranger 1.9.4's kitty previewer assumes real kitty. Under herdr:
# - TERM is xterm-256color, so ranger refuses to start the previewer;
# - herdr answers the file-transfer probe (t=f) with EINVAL, which ranger rejects;
# - TIOCGWINSZ reports 0 pixels, so images scale to nothing.
# Stream image data in-band and get the cell size from CSI 16 t when the ioctl has none.
import fcntl
import struct
import sys
import termios

import PIL.Image

from ranger.ext.img_display import KittyImageDisplayer


def _cell_size(self):
    ret = fcntl.ioctl(sys.stdout, termios.TIOCGWINSZ, struct.pack('HHHH', 0, 0, 0, 0))
    rows, cols, x_px, y_px = struct.unpack('HHHH', ret)
    if x_px and y_px:
        return x_px // cols, y_px // rows
    sys.stdout.write('\033[16t')
    sys.stdout.flush()
    resp = b''
    while not resp.endswith(b't'):
        resp += self.stdbin.read(1)
    _, height, width = resp[resp.rindex(b'[') + 1:-1].split(b';')
    return int(width), int(height)


def _late_init(self):
    self.stream = True
    self.backend = PIL.Image
    self.pix_row, self.pix_col = _cell_size(self)
    self.needs_late_init = False


def _draw(self, path, start_x, start_y, width, height):
    # ranger's draw waits for kitty's "OK" reply. In a remote herdr session, reply text
    # leaks into ranger's input as keystrokes ("=" opens chmod), which redraws the
    # image and loops. q=2 tells the terminal not to reply, so draw reads nothing.
    from ranger.ext.img_display import temporarily_moved_cursor
    import base64
    self.image_id += 1
    if self.needs_late_init:
        self._late_init()
    image = self.backend.open(path)
    box = (width * self.pix_row, height * self.pix_col)
    if image.width > box[0] or image.height > box[1]:
        scale = min(box[0] / image.width, box[1] / image.height)
        image = image.resize((int(scale * image.width), int(scale * image.height)),
                             self.backend.LANCZOS)
    if image.mode not in ('RGB', 'RGBA'):
        image = image.convert('RGB')
    cmds = {'a': 'T', 'i': self.image_id, 't': 'd',
            'f': len(image.getbands()) * 8, 's': image.width, 'v': image.height}
    payload = base64.standard_b64encode(bytearray().join(map(bytes, image.getdata())))
    with temporarily_moved_cursor(int(start_y), int(start_x)):
        for cmd_str in self._format_cmd_str(cmds, payload=payload):
            self.stdbout.write(cmd_str)
    self.stdbout.flush()


_format = KittyImageDisplayer._format_cmd_str


def _format_cmd_str(self, cmd, payload=None, max_slice_len=2048):
    # Deletes (a=d) get q=2 too, so no reply of any kind reaches ranger's input.
    return _format(self, dict(cmd, q=2), payload, max_slice_len)


KittyImageDisplayer._late_init = _late_init
KittyImageDisplayer.draw = _draw
KittyImageDisplayer._format_cmd_str = _format_cmd_str
