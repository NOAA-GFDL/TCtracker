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

"""Tropical Storm Snapshot Plot Generator

This module generates the Tropical Storm Snapshot plot using tracking data
generated from a GCM.
"""

import argparse
import os
import shutil
import subprocess
import jinja2
import tempfile
import collections

from .. import argparse as tsargparse
from ..config import gracebat
from ..traj import traj
from ._plot_helpers import template_env, write_plot_data

__all__ = [
    'generate_plot_data',
]


def generate_plot_data(traj):
    frac = traj.duration_frac
    write_plot_data(
        "grace.dat",
        [f"{n} {frac[n] if n in frac.keys() else 0.0}"\
         for n in range(max(frac.keys()) + 1)])


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

    obs = traj(args.obsDir, args.beg_year, args.end_year)
    model = traj(args.inDir, args.beg_year, args.end_year)

    with tempfile.TemporaryDirectory() as tmpdir:
        os.chdir(tmpdir)

        generate_plot_data(model)
        generate_plot_data(obs)

        duration_par = template_env.get_template(f'duration.par')
        duration_data = {
            'storm_type': storm_type,
            'year_start': args.beg_year,
            'year_end': args.end_year,
            'exp': [args.expName, 'obs'],
            'xmax': max(max(obs.duration_frac.keys()),
                        max(model.duration_frac.keys()))
        }
        with open(duration_par.name, 'w') as out:
            out.write(duration_par.render(duration_data))

        plot_filename = f"duration_{args.beg_year}-{args.end_year}.ps"
        grace_cmd = [
            gracebat,
            "-autoscale", "none",
            "-printfile", plot_filename,
            "-param", duration_par.name,
            "-hardcopy",
            "grace.dat"
        ]
        subprocess.run(grace_cmd)

        shutil.copyfile(plot_filename,
                        os.path.join(args.outDir, plot_filename))
        print(f"Plot stored in '{os.path.join(args.outDir, plot_filename)}'")
