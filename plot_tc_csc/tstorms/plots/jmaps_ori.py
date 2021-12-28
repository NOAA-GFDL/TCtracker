#!/usr/bin/env python3

import sys
import argparse
import os
import tempfile
import shutil
import pyferret

from .. import argparse as tsargparse
from ..config import pkgdatadir
from ..ori import ori

def pyfer_run(cmd):
    (err, errmsg) = pyferret.run(cmd)
    if err != pyferret.FERR_OK:
        sys.exit(f'pyFerret command "{cmd}" failed with status={err}: {errmsg}')

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

    obs = ori(args.obsDir, args.beg_year, args.end_year, 'obs')
    model = ori(args.inDir, args.beg_year, args.end_year, 'model')

    plot_filename = f"maps_ori.{args.beg_year}-{args.end_year}.pdf"

    # Initialize pyferret
    pyferret.start(memsize=128,
                   journal=False,
                   verify=False,
                   unmapped=True,
                   quiet=True)

    # Add ferret_jnl to ferret search path(s)
    pyferret.addpath(os.path.join(pkgdatadir, 'ferret_jnl'))

    # Initialize plot window
    pyfer_run("go tstorm_nplots 2")

    with tempfile.TemporaryDirectory() as tmpdir:
        os.chdir(tmpdir)

        obs.cat_ori_files("ori.obs")
        model.cat_ori_files("ori.model")

        # Add obs to plot (viewport 1)
        pyfer_run("set viewport v1")
        pyfer_run("go tstorm_plot_ori_points ori.obs obs 40ns")

        # Add model to plot (viewport v2)
        pyfer_run("set viewport v2")
        pyfer_run(f"go tstorm_plot_ori_points ori.model {args.expName} 40ns")

        # Generate plot
        pyfer_run(f"frame /file={plot_filename}")

        # Save plot
        shutil.copyfile(plot_filename,
                        os.path.join(args.outDir, plot_filename))
