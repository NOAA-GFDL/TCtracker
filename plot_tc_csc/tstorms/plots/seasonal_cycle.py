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
from ..ori import ori
from ._plot_helpers import template_env, write_plot_data

__all__ = [
    'generate_plot_data',
]


def generate_plot_data(ori):
    ori_stats = ori.stats

    region_list = {'ns': ['NH', 'SH'],
                   'nh': ['NH', 'NI', 'WP', 'EP', 'WA'],
                   'sh': ['SH', 'SI', 'AU', 'SP', 'SA']}

    for hemisphere in region_list.keys():
        for region in region_list[hemisphere]:
            stats = collections.deque(ori_stats[region].mean[0:12])
            if hemisphere == 'sh' or region == 'SH':
                stats.rotate(6)
            out_mean = []
            for i, mean in enumerate(stats, start=1):
                out_mean.append(f"{i} {mean}")
            write_plot_data(f"grace_{hemisphere}_{region}.dat", out_mean)


if __name__ == "__main__":
    argparser = argparse.ArgumentParser()
    argparser.add_argument("-o",
                           help="Directory where plots will be stored",
                           metavar="outDir",
                           dest="outDir",
                           default=os.getcwd(),
                           type=tsargparse.absPath,
                           action=tsargparse.createDir)
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


    with tempfile.TemporaryDirectory() as tmpdir:
        os.chdir(tmpdir)
        obs = ori(args.obsDir, args.beg_year, args.end_year, 'obs')
        model = ori(args.inDir, args.beg_year, args.end_year, 'model')

        generate_plot_data(model)
        generate_plot_data(obs)

        sea_cyc_plot = {'ns': ["-graph", "0", "grace_ns_SH.dat",
                               "-graph", "1", "grace_ns_NH.dat"],
                        'nh': ["-graph", "0", "grace_nh_EP.dat",
                               "-graph", "1", "grace_nh_NI.dat",
                               "-graph", "2", "grace_nh_NH.dat",
                               "-graph", "3", "grace_nh_WA.dat",
                               "-graph", "4", "grace_nh_WP.dat"],
                        'sh': ["-graph", "0", "grace_sh_SP.dat",
                               "-graph", "1", "grace_sh_SI.dat",
                               "-graph", "2", "grace_sh_SH.dat",
                               "-graph", "3", "grace_sh_SA.dat",
                               "-graph", "4", "grace_sh_AU.dat"]}

        sea_cyc_data = {
            'year_start': args.beg_year,
            'year_end': args.end_year,
            'exp': [args.expName, 'obs'],
        }
        sea_cyc_par = {}
        for hemisphere in ['ns', 'nh', 'sh']:
            sea_cyc_par[hemisphere] = template_env.get_template(f'sea_cyc_{hemisphere}.par')

            with open(sea_cyc_par[hemisphere].name, 'w') as out:
                out.write(sea_cyc_par[hemisphere].render(sea_cyc_data))

            plot_filename = f"sea_cyc_{hemisphere}_{args.beg_year}-{args.end_year}.ps"
            grace_cmd = [
                gracebat,
                "-autoscale", "y",
                "-printfile", plot_filename,
                "-param", sea_cyc_par[hemisphere].name,
                "-hardcopy",
            ]
            subprocess.run(grace_cmd+sea_cyc_plot[hemisphere])

            shutil.copyfile(plot_filename,
                            os.path.join(args.outDir, plot_filename))
            print(f"Plot stored in '{os.path.join(args.outDir, plot_filename)}'")
