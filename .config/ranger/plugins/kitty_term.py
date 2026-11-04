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


KittyImageDisplayer._late_init = _late_init
