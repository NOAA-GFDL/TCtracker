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

import re
from typing import List


class StormBox():
    """
    Class to contain the yearly storm data by geographic box (e.g. Northenr
    hemisphere (NH)).
    """

    def __init__(self, id: int):
        self.id = id
        self.storms = {}
        self.stats = {}

    def add_storms(self, year: int, month_totals: List[int], year_total: List[int]):
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


def read_storm_stats(file):
    """
    Open a stat file, read in the contents, and return a dict of StormBox's
    with the Box ID as the key.
    """

    # Regex patterns for box, storms (by year) and stats over the time
    # period for the box.
    __boxhdr = re.compile(r"^ {2}\*{3} Box = {1,2}([A-Z]{1,2})$")
    __yearln = re.compile(r"^ *([0-9]+)((?: *[0-9]+){12}) *([0-9]+)$")
    __statln = re.compile(r"^ *(sum|sprd|mean|std)((?: *[0-9.]+){13})$")

    return_boxes = {}
    with open(file, 'r') as f:
        for line in f:
            box_match = __boxhdr.match(line)
            if box_match:
                box = StormBox(box_match.group(1))
                next(f, None)  # The next line is the header line.
                for line2 in f:
                    year_match = __yearln.match(line2)
                    stat_match = __statln.match(line2)
                    if year_match:
                        box.add_storms(year_match.group(1), year_match.group(2), year_match.group(3))
                    elif stat_match:
                        box.add_stats(stat_match.group(1), stat_match.group(2))
                    else:
                        return_boxes[box.id] = box
                        break
    return return_boxes
