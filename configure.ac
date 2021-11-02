# **********************************************************************
# TCtracker - Tropical Storm Detection
# Copyright (C) 1997-2008, 2021 Frederic Vitart, Joe Sirutis, Ming Zhao,
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

AC_PREREQ([2.69])

AC_INIT([GFDL Tropical Storms Detection],
        [2.0.0-alpha.1],
        [gfdl.climate.model.info@noaa.gov],
        [TCtracker],
        [https://www.gfdl.noaa.gov/tstorms/])

AC_CONFIG_SRCDIR([tstorms_driver/tstorms_drive.f90])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([foreign tar-pax subdir-objects])

# Installer can set location of ibtracs_dir.  If not set at configure time
# user will need to set IBTRACS_DIR or use the -O option.
AC_ARG_WITH([ibtracs],
  [AS_HELP_STRING([--with-ibtracs=[path]],
    [Use ibtracs path as default ibtracs_dir])],
    [test -d "$with_ibtracs" || AC_MSG_WARN([ibtracs directory '$with_ibtracs' does not exist])],
    [with_ibtracs='Not set'])
AC_SUBST([ibtracs_dir], [$with_ibtracs])

AC_PROG_SED
AC_PATH_PROG([GRACEBAT], [gracebat], [none])
if test "$GRACEBAT" = "none"; then
  AC_MSG_ERROR([Unable to find gracebat command in PATH])
fi

AC_PROG_FC([gfortran ifort])
AC_FC_MODULE_FLAG
AC_FC_MODULE_EXTENSION
AC_FC_MODULE_OUTPUT_FLAG

AC_PROG_INSTALL

AC_FC_FREEFORM()

AC_LANG_PUSH([Fortran])
AX_LIB_NETCDFF()
if test "$with_netcdf_fortran" = "no"; then
  AC_MSG_ERROR([Unable to find NetCDF Fortran library.])
fi
AC_LANG_POP([Fortran])

# Check that python3 and python packages are available
AC_PATH_PROGS([PYTHON], [python3 python])
AX_PROG_PYTHON_VERSION([3.6], ,AC_MSG_ERROR([unable to find a python version >=3.6 in PATH]))

AX_PYTHON_MODULE([jinja2], [t])

# Define the directory where *.mod files will reside.
# Used in Makefiles.
AC_SUBST([MODDIR],[.mods])

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile
                 plot_tc_csc/Makefile
                 plot_tc_csc/tstorms/Makefile
                 plot_tc_csc/tstorms/templates/Makefile
                 share/Makefile
                 trajectory_analysis/Makefile
                 tstorms_driver/Makefile
])
AC_OUTPUT
