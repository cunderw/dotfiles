"""Re-serialize YAML exactly the way Home Assistant writes it.

Home Assistant's config API (the automation/script/scene editors) saves
automations.yaml, scripts.yaml and scenes.yaml through annotatedyaml's dump(),
which is PyYAML with these settings. Formatting a hand edit the same way keeps
the git diff to real changes when HA later rewrites the file.

Like HA, this drops comments and normalizes quoting/indentation.
Reads the buffer on stdin, writes the result to stdout.
"""

import sys

import yaml

Loader = getattr(yaml, "CSafeLoader", yaml.SafeLoader)
Dumper = getattr(yaml, "CSafeDumper", yaml.SafeDumper)

source = sys.stdin.read()
data = yaml.load(source, Loader=Loader)
if data is None:
    sys.stdout.write(source)
    sys.exit(0)

sys.stdout.write(
    yaml.dump(
        data,
        default_flow_style=False,
        allow_unicode=True,
        sort_keys=False,
        Dumper=Dumper,
    ).replace(": null\n", ":\n")
)
