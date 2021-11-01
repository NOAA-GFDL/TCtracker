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

pkglibexec_PROGRAMS = tstorms_driver

AM_FCFLAGS = $(FC_MODINC). $(FC_MODOUT)$(MODDIR) $(NETCDF_FCFLAGS)

tstorms_driver_LDADD = $(NETCDF_FCLDFLAGS) $(NETCDF_FCLIBS)
tstorms_driver_LDFLAGS = $(NETCDF_FCLDFLAGS:-L%=-Wl,-rpath,%)

tstorms_driver_SOURCES = \
  get_date.f90 \
  indata.f90 \
  spline.f90 \
  time_manager.f90 \
  tsgpad.f90 \
  tstorms.f90 \
  tstorms_drive.f90 \
  utilities.f90 \
  vorcomp.f90


get_date.o: get_date_mod.$(FC_MODEXT)
indata.o: indata_mod.$(FC_MODEXT)
tstorms.o: tstorms_mod.$(FC_MODEXT)
tstorms_drive.o: indata_mod.$(FC_MODEXT) tstorms_mod.$(FC_MODEXT)

get_date_mod.$(FC_MODEXT): time_manager_mod.$(FC_MODEXT) utilities_mod.$(FC_MODEXT)
indata_mod.$(FC_MODEXT): get_date_mod.$(FC_MODEXT) vorcomp_mod.$(FC_MODEXT)
tstorms_mod.$(FC_MODEXT): spline_mod.$(FC_MODEXT)

MODFILES = \
  get_date_mod.$(FC_MODEXT) \
  indata_mod.$(FC_MODEXT) \
  spline_mod.$(FC_MODEXT) \
  time_manager_mod.$(FC_MODEXT) \
  tsgpad_mod.$(FC_MODEXT) \
  tstorms_mod.$(FC_MODEXT) \
  utilities_mod.$(FC_MODEXT) \
  vorcomp_mod.$(FC_MODEXT)
BUILT_SOURCES = $(MODFILES)

include $(top_srcdir)/mkmods.mk
