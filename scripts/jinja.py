#!/usr/bin/env python3
from os.path import abspath, dirname, basename, splitext, expandvars, expanduser
import argparse

from math import *

def render(tempfile, **kargs):
    tempfile = abspath(expanduser(expandvars(tempfile)))
    new_filename, ext = splitext(tempfile)
    from jinja2 import Environment, FileSystemLoader
    from jinja2 import StrictUndefined
    e = Environment(loader=FileSystemLoader(dirname(tempfile)),
                    undefined=StrictUndefined)
    content = e.get_template(basename(tempfile)).render(**kargs)
    with open(new_filename, 'w') as fw:
        fw.write(content)
    return new_filename

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("filejj", type=str, nargs='*', default=[],
                        help="template file (must have .jj extension)")
    parser.add_argument("--jj", type=str, default='',
                        help="arguments for template tool (python3 syntax)")
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    opts = {}
    if args.jj:
        exec(args.jj, globals(), opts)
    for filejj in args.filejj:
        new_filename = render(filejj, **opts)
        print(f'wrote: {new_filename}')

