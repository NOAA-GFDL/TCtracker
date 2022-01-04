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

from .lonlat import lonlat

__all__ = [
    'storm'
]

class storm():
    """Class to hold strom trajaectory

    Keyword Arguments:
        - lon -- Longitude of storm location
        - lat -- Latitude of storm location
        - wind -- Surface wind speed (m/s)
        - psl -- Pressure at sea level (hPa), Value -999 is missing data.
        - year -- Year portion of storm track start date.
        - month -- Month portion of storm track start date.
        - day -- Day portion of storm track start date.
        - hour -- Hour portion of storm track start date.
        - track -- List of storm trajectory data.

        Attributes:
        - position = lon/lat of storm position
        - wind -- Surface wind speed (m/s)
        - psl -- Pressure at sea level (hPa)
        - date -- Date of track data
    """

    def __init__(self, lon, lat, wind, psl, year, mon, day, hour):
        self.position = lonlat(float(lon), float(lat))
        self.wind = float(wind)
        self.psl = float(psl)
        self.date = datetime.datetime(int(year),
                                      int(mon),
                                      int(day),
                                      int(hour),
                                      tzinfo=datetime.timezone.utc)
