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

"""Tropical Storm Timeseries Plot Generator

This module generates the Tropical Storm Timeseries plot using tracking data
generated from a GCM.
"""
import argparse
import os
import shutil
import subprocess
import jinja2
import tempfile

from .. import argparse as tsargparse
from ..config import gracebat
from ..ori import ori
from ._plot_helpers import template_env, write_plot_data

__all__ = [
    'generate_plot_data',
]


def generate_plot_data(region_stats):
    write_plot_data('grace.dat',
                    [f"{y} {region_stats.get_year_total(y)}" for y in region_stats.years])


if __name__ == "__main__":
    argparser = argparse.ArgumentParser()
    argparser.add_argument("-o",
                           help="Directory where plots will be stored",
                           metavar="outDir",
                           dest="outDir",
                           default=os.getcwd(),
                           type=tsargparse.absPath,
                           action=tsargparse.createDir)
    argparser.add_argument("-H",
                           help="Indicates plot is number of hurricanes",
                           dest="do_hur",
                           action='store_true')
    argparser.add_argument("inDir",
                           help="Directory where tropical storm data are available",
                           metavar="inDir",
                           type=tsargparse.absPath,
                           action=tsargparse.dirExists)
    argparser.add_argument("obsDir",
                           help="Compare to observations in directory",
                           metavar="obsDir",
                           type=tsargparse.absPath,
                           action=tsargparse.dirExists)
    argparser.add_argument("beg_year",
                           help="First year to process",
                           metavar="beg_year",
                           type=int)
    argparser.add_argument("end_year",
                           help="Last year to process",
                           metavar="end_year",
                           type=int)
    argparser.add_argument("expName",
                           help="Experiment name used in plots",
                           metavar="expName",
                           type=str)
    args = argparser.parse_args()

    storm_type = 'Tropical Storm'
    if (args.do_hur):
        storm_type = 'Hurricane (CAT. 1-5)'

    # y_region contains the plot's y-axis max and tick mark increment numbers
    y_region = {
        'G': {'max': 110, 'inc': 10},
        'WA': {'max': 20, 'inc': 2},
        'EA': {'max': 10, 'inc': 1},
        'WP': {'max': 50, 'inc': 5},
        'EP': {'max': 30, 'inc': 5},
        'NI': {'max': 10, 'inc': 1},
        'SI': {'max': 20, 'inc': 2},
        'AU': {'max': 20, 'inc': 2},
        'SP': {'max': 30, 'inc': 5},
        'SA': {'max': 10, 'inc': 1},
        'NH': {'max': 80, 'inc': 10},
        'SH': {'max': 50, 'inc': 5},
        'NA': {'max': 20, 'inc': 2}
    }

    obs = ori(args.obsDir, args.beg_year, args.end_year, 'obs')
    model = ori(args.inDir, args.beg_year, args.end_year, 'model')

    for region in ['G', 'WA', 'WP', 'EP', 'NH', 'SH']:
        with tempfile.TemporaryDirectory() as tmpdir:
            os.chdir(tmpdir)

            generate_plot_data(model.stats[region])
            generate_plot_data(obs.stats[region])

            timeseries_par = template_env.get_template('time_series.par')
            timeseries_data = {
                'storm_type': storm_type,
                'region_title': model.stats[region].region_title,
                'YYMAX': y_region[region]['max'],
                'YYINC': y_region[region]['inc'],
                'exp': [args.expName, 'obs'],
                'mean': [model.stats[region].mean[12], obs.stats[region].mean[12]]
            }
            with open('timeseries.par', 'w') as out:
                out.write(timeseries_par.render(timeseries_data))

            plot_filename = f"timeseries_{region}.ps"
            grace_cmd = [
                gracebat,
                "-autoscale", "xy",
                "-printfile", plot_filename,
                "-param", "timeseries.par",
                "-hardcopy",
                "grace.dat",
            ]
            subprocess.run(grace_cmd)

            shutil.copyfile(plot_filename,
                            os.path.join(args.outDir, plot_filename))
            print(f"Plot stored in '{os.path.join(args.outDir, plot_filename)}'")
