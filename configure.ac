AC_PREREQ([2.69])

AC_INIT([GFDL Tropical Storms Analysis],
        [1.0.0],
        [gfdl.climate.model.info@noaa.gov],
        [tstorms],
        [https://www.gfdl.noaa.gov/tstorms/])

AC_CONFIG_SRCDIR([tstorms_driver/tstorms_drive.f90])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([foreign tar-pax subdir-objects])

AC_PROG_SED

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

# Define the directory where *.mod files will reside.
# Used in Makefiles.
AC_SUBST([MODDIR],[.mods])

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile
                 plot_tc_csc/Makefile
                 trajectory_analysis/Makefile
                 tstorms_driver/Makefile
])
AC_OUTPUT
