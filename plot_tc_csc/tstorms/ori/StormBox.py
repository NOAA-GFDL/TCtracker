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

from typing import List


class StormBox():
    """
    Class to contain the yearly storm data by geographic box (e.g. Northern
    hemisphere (NH)).
    """

    region_titles = {
        'G': 'Global',
        'WA': 'West Atlantic',
        'EA': 'East Atlantic',
        'WP': 'West Pacific',
        'EP': 'East Pacific',
        'NI': 'North Indian_Ocean',
        'SI': 'South Indian_Ocean',
        'AU': 'Australia',
        'SP': 'South Pacific',
        'SA': 'South Atlantic',
        'NH': 'Northern Hemisphere',
        'SH': 'Southern Hemisphere',
        'NA': 'North Atlantic'
    }

    def __init__(self, id: int):
        self.id = id
        self.storms = {}
        self.stats = {}

    def add_storms(self,
                   year: int,
                   month_totals: List[int],
                   year_total: List[int]):
        """
        Add number of storms per month, and yearly total to StormBox

        Internally, self.storms is a dict, with the `year` as the key.
        """

        self.storms[year] = {}
        self.storms[year]['month_totals'] = month_totals.split()
        self.storms[year]['total'] = year_total

    def add_stats(self, name: str, stats: str):
        """
        Add specific stats to the StormBox.
        """

        self.stats[name] = stats.split()

    @property
    def years(self) -> List[int]:
        """
        Simple getter function to return a list of years
        """

        return list(self.storms.keys())

    def get_month_totals(self, year: int) -> List[int]:
        """
        Return number of storms per month, return a list.
        """

        return self.storms[str(year)]['month_totals']

    def get_year_total(self, year: int):
        """
        Return the total number of storms for a given year
        """

        return self.storms[str(year)]['total']

    @property
    def mean(self):
        """
        Return the mean statistics
        """

        return self.stats['mean']

    @property
    def region_title(self):
        """
        Return the region's long name
        """

        return self.region_titles[self.id]
