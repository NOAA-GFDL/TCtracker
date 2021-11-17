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

__all__ = [
    'generate_plot_data',
]


def generate_plot_data(ori):
    ori.freq_ori(do_40ns = True, do_map = False, do_lon = True, do_lat = False)
    for region in ['gl', 'nh', 'sh']:
        _append_file(f'flon_{region}', f'grace_{region}.dat')


def _append_file(in_file, out_file):
    with open(out_file, 'a') as outfile:
        with open(in_file) as infile:
            outfile.write(infile.read())


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

    grace_template_dir = os.path.join(os.path.dirname(__file__), 'templates')
    template_env = jinja2.Environment(loader=jinja2.FileSystemLoader(grace_template_dir))
    template_env.keep_trailing_newline = True
    template_env.trim_blocks = True
    template_env.lstrip_blocks = True
    template_env.rstrip_blocks = True

    obs = ori(args.obsDir, args.beg_year, args.end_year, 'obs')
    model = ori(args.inDir, args.beg_year, args.end_year, 'model')

    with tempfile.TemporaryDirectory() as tmpdir:
        os.chdir(tmpdir)

        generate_plot_data(model)
        generate_plot_data(obs)

        by_longitude_par = template_env.get_template('by_longitude.par')
        by_longitude_data = {
            'storm_type': storm_type,
            'year_start': args.beg_year,
            'year_end': args.end_year,
            'exp': [args.expName, 'obs'],
        }
        with open('by_longitude.par', 'w') as out:
            out.write(by_longitude_par.render(by_longitude_data))

        plot_filename = "by_longitude.ps"
        grace_cmd = [
            gracebat,
            "-autoscale", "y",
            "-printfile", plot_filename,
            "-param", "by_longitude.par",
            "-hardcopy",
            "-graph", "0", "grace_sh.dat",
            "-graph", "1", "grace_nh.dat",
            "-graph", "2", "grace_gl.dat",
        ]
        subprocess.run(grace_cmd)

        shutil.copyfile(plot_filename,
                        os.path.join(args.outDir, plot_filename))
        print(f"Plot stored in '{os.path.join(args.outDir, plot_filename)}'")
