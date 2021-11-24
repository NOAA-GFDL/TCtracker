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

import datetime

from .storm import storm

__all__ = [
    'storm_traj'
]

class storm_traj():
    """Class to hold strom trajaectory data

    Keyword Arguments:

        - year -- Year portion of storm track start date.
        - month -- Month portion of storm track start date.
        - day -- Day portion of storm track start date.
        - hour -- Hour portion of storm track start date.
        - track -- List of storm trajectory data.

    Attributes:

        - start_date == Datetime of storm's start date/time.
        - track -- List of class Storm trajectories
    """

    def __init__(self, year, month, day, hour, track):
       self.start_date = datetime.datetime(year, month, day, hour, tzinfo=datetime.timezone.utc)
       self.track = [storm(*t) for t in track]

    @property
    def duration(self):
        """Return duration of storm"""
        return len(self.track)
