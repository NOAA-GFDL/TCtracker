# **********************************************************************
# TCtracker - Tropical Storm Detection
# Copyright (C) 2021 Frederic Vitart, Joe Sirutis, Ming Zhao,
# Kyle Olivo, Keren Rosado and Seth Underwood
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
# **********************************************************************

"""argparse helper classes

This module contains helper classes that extend the argparse module.
"""

import argparse
import os
import pathlib

__all__ = [
    "dirExists",
    "createDir",
    "absPath",
    "str2bool"
]


class dirExists(argparse.Action):
    """
    dirExists is an extension argparse Action that ensures the directory
    exists.  An error will be issued if the directory does not exist.
    """

    def __call__(self, parser, namespace, values, option_string=None):
        if not os.path.exists(values):
            parser.error(f"directory '{values}' does not exist")
        if not os.path.isdir(values):
            parser.error(f"'{values}' exists, but is not a directory")
        if os.access(values, os.R_OK):
            setattr(namespace, self.dest, values)
        else:
            parser.error(f"directory '{values}' is not readable")


class createDir(argparse.Action):
    """
    createDir is an axtension argparse Action that will attempt to create
    the directory (and all parents) if the directory doesn't exist.
    """

    def __call__(self, parser, namespace, values, option_string=None):
        if not os.path.exists(values):
            try:
                values.mkdir(parents=True, exist_ok=True)
            except Exception as err:
                parser.error(f"unable to create directory '{values}':",
                             f"{err.args[1]}")
        else:
            setattr(namespace, self.dest, values)


def absPath(p):
    """
    Get the full, absolute path.  Useful as a argpare argument type.
    """

    return pathlib.Path(p).absolute()


def str2bool(v):
    """
    Use multiple values for True/False
    """

    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')
