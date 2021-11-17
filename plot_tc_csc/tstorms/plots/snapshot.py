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

from .. import argparse as tsargparse
from ..config import gracebat
from ..ori import ori

__all__ = [
    'generate_plot_data',
]

def generate_ori_data(type, template_env):
    ori_data = []
    with open('ori', 'r') as infile:
        for line in infile.readlines():
            ln = line.split()
            ori_data.append(f'{ln[0]} {ln[1]}')
    geog_dat = template_env.get_template('geog.dat')
    with open(f'ori_{type}.dat', 'w') as out:
        out.write(geog_dat.render(data=ori_data))


def generate_plot_data(ori, template_env):
    ori_stats = ori.stats
    xts = {}
    for b in ['NH', 'SH']:
        xts[b] = []
        for y in ori_stats[b].years:
            xts[b].append(f"{y} {ori_stats[b].get_year_total(y)}")

    # mean data
    xscyc = {}
    # Northern Hemisphere
    xscyc['NH'] = []
    for i, v in enumerate(ori_stats['NH'].mean[:12], start=1):
        xscyc['NH'].append(f"{i} {v}")
    # Souther Hemisphere
    xscyc['SH'] = []
    for i, v in enumerate(ori_stats['SH'].mean[6:12] + ori_stats['SH'].mean[:6], start=1):
        xscyc['SH'].append(f"{i} {v}")

    ori.cat_ori_files()
    generate_ori_data(ori.type, template_env)
    write_plot_data("xts_nh.dat", xts['NH'])
    write_plot_data("xts_sh.dat", xts['SH'])
    write_plot_data("xscyc_nh.dat", xscyc['NH'])
    write_plot_data("xscyc_sh.dat", xscyc['SH'])

    ori.freq_ori(True, False, True, False, False, False, False)
    for region in ['gl', 'nh', 'sh']:
        with open(f"xlon_{region}.dat", 'a') as outfile:
            with open(f"flon_{region}") as infile:
                outfile.write(infile.read())

    return ori_stats['NH'].mean[12], ori_stats['SH'].mean[12]


def write_plot_data(file, array):
    with open(file, "a") as f:
        f.write("\n".join(array + ['&\n']))


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

    grace_template_dir = os.path.join(os.path.dirname(__file__), 'templates')
    template_env = jinja2.Environment(loader=jinja2.FileSystemLoader(grace_template_dir))
    template_env.keep_trailing_newline = True
    template_env.trim_blocks = True
    template_env.lstrip_blocks = True
    template_env.rstrip_blocks = True

    with tempfile.TemporaryDirectory() as tmpdir:
        os.chdir(tmpdir)
        obs = ori(args.obsDir, args.beg_year, args.end_year, 'obs')
        model = ori(args.inDir, args.beg_year, args.end_year, 'model')

        nh_obs_mean, sh_obs_mean = generate_plot_data(obs, template_env)
        nh_model_mean, sh_model_mean = generate_plot_data(model, template_env)

        snapshot_par = template_env.get_template('snap_shot.par')
        snapshot_data = {
            "BEG_YEAR": args.beg_year,
            "END_YEAR": args.end_year,
            "NH_OBS_MEAN": nh_obs_mean,
            "NH_MODEL_MEAN": nh_model_mean,
            "SH_OBS_MEAN": sh_obs_mean,
            "SH_MODEL_MEAN": sh_model_mean,
            "PLOT_TITLE": args.expName,
        }
        with open('snapshot.par', 'w') as out:
            out.write(snapshot_par.render(snapshot_data))

        plot_filename = f"snapshot_{args.beg_year}-{args.end_year}.ps"
        grace_cmd = [
            gracebat,
            "-printfile", plot_filename,
            "-param", "snapshot.par",
            "-hardcopy",
            "-graph", "3", "xts_nh.dat", "-graph", "7", "xts_sh.dat",
            "-graph", "2", "xscyc_nh.dat", "-graph", "6", "xscyc_sh.dat",
            "-graph", "1", "xlon_nh.dat", "-graph", "5", "xlon_sh.dat",
            "-graph", "0", "ori_obs.dat", "-graph", "4", "ori_model.dat",
        ]
        subprocess.run(grace_cmd)

        shutil.copyfile(plot_filename,
                        os.path.join(args.outDir, plot_filename))
        print(f"Plot stored in '{os.path.join(args.outDir, plot_filename)}'")
