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
import tempfile
import os
import shutil
import re

from ..config import pkglibexecdir
from .stat_ori_mask import stat_ori as _stat_ori
from .StormBox import StormBox
from .freq_ori import freq_ori as _freq_ori

all = ["ori",
       "StormBox"]

class ori():
    def __init__(self,
                 ori_dir: str,
                 beg_year: int,
                 end_year: int,
                 ori_type = 'model'):
        self.directory = ori_dir
        self.start_year = beg_year
        self.end_year = end_year
        self.type = ori_type
        self.stat_file = self._gen_stats()
        self.stats = self._read_stats()

    def cat_ori_files(self): # inDir: str, beg_year: int, end_year: int):
        """
        Concatinate ori_[YYYY] files into a single `ori` file.  The single
        `ori` file is required for certain plots.
        """

        # Concatenate all `ori_YYYY` files into a single `ori` file
        with open('ori', 'w') as outfile:
            for year in range(self.start_year, self.end_year + 1):
                fname = os.path.join(self.directory, "ori_{:04d}".format(year))
                with open(fname) as infile:
                    outfile.write(infile.read())
        return os.path.realpath('ori')

    def freq_ori(self,
                 do_40ns = True,
                 do_map = True,
                 do_lon = False,
                 do_lat = False,
                 do_latf = False,
                 do_fot = False,
                 traj_in = False):
        """
        """

        # Ensure the _correct_ ori file is in place
        self.cat_ori_files()
        _freq_ori(do_40ns, do_map, do_lon, do_lat, do_latf, do_fot, traj_in)

    def _gen_stats(self):
        """
        """

        stats_filename = 'stats_{0}_{1:04d}-{2:04d}'.format(self.type,
                                                            self.start_year,
                                                            self.end_year)
        # Remember where we are
        prev_cwd = os.getcwd()
        with tempfile.TemporaryDirectory() as tmpdir:
            os.chdir(tmpdir)
            # Concatinate all ori_YYYY files into a single ori file
            self.cat_ori_files()
            # Run the ori_stat executable
            _stat_ori(os.path.join(pkglibexecdir, 'imask_2'), False, False)

            shutil.copyfile('stat_mo', os.path.join(prev_cwd, stats_filename))

        os.chdir(prev_cwd)
        return os.path.realpath(stats_filename)

    def _read_stats(self):
        """
        Open a stat file, read in the contents, and return a dict of
        StormBox's with the Box ID as the key.
        """

        # Regex patterns for box, storms (by year) and stats over the time
        # period for the box.
        __boxhdr = re.compile(r"^ {2}\*{3} Box = {1,2}([A-Z]{1,2})$")
        __yearln = re.compile(r"^ *([0-9]+)((?: *[0-9]+){12}) *([0-9]+)$")
        __statln = re.compile(r"^ *(sum|sprd|mean|std)((?: *[0-9.]+){13})$")

        return_boxes = {}
        with open(self.stat_file, 'r') as f:
            for line in f:
                box_match = __boxhdr.match(line)
                if box_match:
                    box = StormBox(box_match.group(1))
                    next(f, None)  # The next line is the header line.
                    for line2 in f:
                        year_match = __yearln.match(line2)
                        stat_match = __statln.match(line2)
                        if year_match:
                            box.add_storms(year_match.group(1),
                                           year_match.group(2),
                                           year_match.group(3))
                        elif stat_match:
                            box.add_stats(stat_match.group(1),
                                          stat_match.group(2))
                        else:
                            return_boxes[box.id] = box
                            break
        return return_boxes
