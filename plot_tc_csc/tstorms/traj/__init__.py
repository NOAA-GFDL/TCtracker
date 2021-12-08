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

"""
This module contains classes and other helper routines to read
traj_<year> files that contain tropical storm data.
"""

import re
import os
import collections
import datetime

from .storm_traj import storm_traj

__all__ = [
    'traj'
]

class traj():
    """Class to hold data for a group of `traj_<year>` files

    Keyword Arguments:

        - traj_dir -- Directory that contains the `traj_<year>` files.

        - beg_year -- First year of `traj_<year>` data to process.

        - end_year -- Last year of `traj_<year>` data to process.

    Attributes:

        - directory -- Holds `traj_dir`

        - start_year -- Holds `beg_year`

        - end_year -- Holds `end_year`

        - stroms -- Array of storm trajectories.

        - tsteps_day -- Number of timesteps per day in traj_<year> files
    """

    def __init__(self,
                 traj_dir: str,
                 beg_year: int,
                 end_year: int):
        self.directory = traj_dir
        self.start_year = beg_year
        self.end_year = end_year
        self.storms = self._read_storm_trajectories()
        self.tsteps_day = self._get_tsteps_day()

    def _get_tsteps_day(self):
        """Determine the number of timesteps per day"""

        sec_day = datetime.timedelta(days=1)
        tstep = 0
        for storm in self.storms:
            if storm.duration > 1:
                tstep = storm.track[1].date - storm.track[0].date
                break
        return sec_day / tstep

    def _read_storm_trajectories(self):
        """Read in storm trajectories from traj_<year> files"""

        storm_trajs = []
        # RegEx expression to match storm start
        strm_header = re.compile(r"^start +(.*)$")
        for year in range(self.start_year, self.end_year + 1):
            fname = os.path.join(self.directory, "traj_{:04d}".format(year))
            with open(fname, 'r') as f:
                for line in f:
                    hdr = strm_header.match(line)
                    if hdr:
                        hdr_data = list(map(int, hdr.group(1).split()))
                        trk_data = []
                        for i in range(hdr_data[0]):
                            data = next(f, None)
                            if data:
                                trk_data.append(data.split())
                        storm_trajs.append(storm_traj(hdr_data[1],
                                                      hdr_data[2],
                                                      hdr_data[3],
                                                      hdr_data[4],
                                                      trk_data))
        return storm_trajs

    @property
    def duration_count(self):
        """Return a Counter of storm"""
        return collections.Counter([int(x.duration/self.tsteps_day) for x in self.storms])

    @property
    def duration_frac(self):
        """Return a Counter of fraction of storms"""
        cnt = self.duration_count
        cnt_sum = sum(cnt.values())
        return {k: float(cnt[k]/cnt_sum) for k in cnt.keys()}
