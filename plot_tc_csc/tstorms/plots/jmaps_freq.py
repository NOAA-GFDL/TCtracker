#!/usr/bin/env python3

import sys as _sys
import argparse as _argparse
import os as _os
import tempfile as _tempfile
import shutil as _shutil
import pyferret as _pyferret
import scipy.io as _scipy_io
import numpy as _numpy

from .. import argparse as _tsargparse
from ..config import pkgdatadir as _pkgdatadir
from ..ori import ori as _ori


def _pyfer_run(cmd):
    (err, errmsg) = _pyferret.run(cmd)
    if err != _pyferret.FERR_OK:
        _sys.exit(f'pyFerret command "{cmd}" failed with status={err}:',
                  f'{errmsg}')


def generate_data(ori, grid):
    with _tempfile.TemporaryDirectory() as tmpdir:
        _os.chdir(tmpdir)

        ori.freq_ori(do_40ns=False,
                     do_map=True,
                     do_lon=False,
                     do_lat=False,
                     do_latf=False,
                     do_fot=False,
                     traj_in=False)
        fmap_file = _scipy_io.FortranFile('fmap', 'r')
        freq = fmap_file.read_reals(dtype='f4').reshape((73, 44), order='F')
        fmap_file.close()

    lon_axis = grid.axes[_pyferret.X_AXIS]
    lat_axis = grid.axes[_pyferret.Y_AXIS]
    freq_masked = _numpy.ma.masked_array(freq, mask=freq == 0.0)
    freq_dict = {'name': f'FREQ_{ori.type}',
                 'title': 'TC Frequency per Decade',
                 'axis_types': (lon_axis.axtype, lat_axis.axtype),
                 'axis_names': (lon_axis.name, lat_axis.name),
                 'axis_units': (lon_axis.unit, lat_axis.unit),
                 'axis_coords': (lon_axis.coords, lat_axis.coords),
                 'data': freq_masked * 10}
    return freq_dict


if __name__ == "__main__":
    argparser = _argparse.ArgumentParser()
    argparser.add_argument("-o",
                           help="Directory where plots will be stored",
                           metavar="outDir",
                           dest="outDir",
                           default=_os.getcwd(),
                           type=_tsargparse.absPath,
                           action=_tsargparse.createDir)
    argparser.add_argument("inDir",
                           help="Directory where tropical storm data are " +
                                " available",
                           metavar="inDir",
                           type=_tsargparse.absPath,
                           action=_tsargparse.dirExists)
    argparser.add_argument("obsDir",
                           help="Compare to observations in directory",
                           metavar="obsDir",
                           type=_tsargparse.absPath,
                           action=_tsargparse.dirExists)
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

    obs = _ori(args.obsDir, args.beg_year, args.end_year, 'obs')
    model = _ori(args.inDir, args.beg_year, args.end_year, 'model')

    plot_filename = f"maps_freq.{args.beg_year}-{args.end_year}.pdf"

    # Initialize pyferret
    _pyferret.start(memsize=128,
                    journal=False,
                    verify=False,
                    unmapped=True,
                    quiet=True)

    # Add ferret_jnl to ferret search path(s)
    _pyferret.addenv(FER_GO=_os.path.join(_pkgdatadir, 'ferret_jnl'))

    # Initialize plot window
    _pyfer_run("go tstorm_nplots 2")
    _pyfer_run("go tstorm_plot_settings 40ns yes")
    # Create pyferret axes
    lon_axis = _pyferret.FerAxis(range(0, 361, 5),
                                 axtype=_pyferret.AXISTYPE_LONGITUDE,
                                 name='FREQ_X',
                                 unit='degrees_east')
    lat_axis = _pyferret.FerAxis(range(-86, 87, 4),
                                 axtype=_pyferret.AXISTYPE_LATITUDE,
                                 name='FREQ_Y',
                                 unit='degrees_north')
    freq_grid = _pyferret.FerGrid((lon_axis, lat_axis), name="FREQ_grid")

    obs_freq = generate_data(obs, freq_grid)
    _pyferret.putdata(obs_freq)

    model_freq = generate_data(model, freq_grid)
    _pyferret.putdata(model_freq)

    # Variables for plot data
    fer_shade_pal = 'exciting_cmyk'
    fer_shade_qual = \
        '/nolabels/hlimits=($lon_span)/vlimits=($lat_span)/levels=($lev_span)'
    fer_land_res = 60
    fer_land_color = 'gray'

    with _tempfile.TemporaryDirectory() as tmpdir:
        _os.chdir(tmpdir)

        # Add to plot (viewport 1)
        _pyfer_run("set viewport v1")
        _pyferret.shadeplot(obs_freq['name'],
                            pal=fer_shade_pal,
                            qual=fer_shade_qual)
        _pyferret.shadeland(res=fer_land_res, color=fer_land_color)
        _pyfer_run("label ($label_xp),($label_yp),-1,0,0.2 obs")

        # Add model to plot (viewport v2)
        _pyfer_run("set viewport v2")
        _pyferret.shadeplot(model_freq['name'],
                            pal=fer_shade_pal,
                            qual=fer_shade_qual)
        _pyferret.shadeland(res=fer_land_res, color=fer_land_color)
        _pyfer_run(f"label ($label_xp),($label_yp),-1,0,0.2 {args.expName}")

        # Generate plot
        _pyferret.saveplot(plot_filename)

        # Save plot
        _shutil.copyfile(plot_filename,
                         _os.path.join(args.outDir, plot_filename))
