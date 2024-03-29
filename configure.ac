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
        [2.0.0-alpha.4],
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
AS_IF([test "$GRACEBAT" = "none"],
  [AC_MSG_ERROR([Unable to find gracebat command in PATH])])


AC_PROG_FC([gfortran ifort])
AC_FC_MODULE_FLAG
AC_FC_MODULE_EXTENSION
AC_FC_MODULE_OUTPUT_FLAG
AC_FC_FREEFORM()
AC_FC_LINE_LENGTH([unlimited])

AC_PROG_INSTALL

AC_FC_FREEFORM()

AC_LANG_PUSH([Fortran])
AX_LIB_NETCDFF()
AS_IF([test "$with_netcdf_fortran" = "no"],
  [AC_MSG_ERROR([Unable to find NetCDF Fortran library.])])
AC_LANG_POP([Fortran])

# Check for the NCO used tools
AC_PATH_PROG([NCRCAT], [ncrcat], [none])
AS_IF([test "$NCRCAT" == "none"],
  [AC_MSG_ERROR([Unable to find ncrcat in PATH])])

# Check that python3 and python packages are available
AM_PATH_PYTHON([3.6])
AX_PYTHON_MODULE([jinja2], [t])
AX_PYTHON_MODULE([pyferret], [t])
AX_PYTHON_MODULE([scipy.io], [t])

# f2py for python/Fortran functionality
AC_CHECK_PROGS([F2PY], [f2py3 f2py], [none])
AS_IF([test "$F2PY" == "none"],
  [AC_MSG_ERROR([Unable to find f2py in PATH])])
# Get the Python extension for extension libraries
AC_CHECK_PROGS([PYTHON_CONFIG], [python3-config python-config], [none])
AS_IF([test "$PYTHON_CONFIG" == "none"],
  [AC_MSG_ERROR([Unable to find python-config in PATH])])
AC_MSG_CHECKING([for python's extension suffix])
AC_SUBST([PYTHON_EXTENSION_SUFFIX],[$(eval $PYTHON_CONFIG --extension-suffix)])
AC_MSG_RESULT([$PYTHON_EXTENSION_SUFFIX])

# Define the directory where *.mod files will reside.
# Used in Makefiles.
AC_SUBST([MODDIR],[.mods])

AC_CONFIG_FILES([Makefile
                 plot_tc_csc/Makefile
                 plot_tc_csc/tstorms/Makefile
                 plot_tc_csc/tstorms/ori/Makefile
                 plot_tc_csc/tstorms/plots/Makefile
                 plot_tc_csc/tstorms/plots/templates/Makefile
                 plot_tc_csc/tstorms/traj/Makefile
                 share/Makefile
                 share/ferret_jnl/Makefile
                 trajectory_analysis/Makefile
                 tstorms_driver/Makefile
])
AC_OUTPUT
