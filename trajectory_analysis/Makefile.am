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
#
pkglibexec_PROGRAMS = trajectory_analysis_csc

matlabdir = $(pkglibexecdir)
dist_matlab_DATA = dotraj_new.m rdtraj_new.m landfall.m regions_ibtrac.m

mapfiledir = $(pkglibexecdir)
dist_mapfile_DATA = landsea.map imask_2

AM_FCFLAGS = $(FC_MODINC). $(FC_MODOUT)$(MODDIR) $(NETCDF_FCFLAGS)

trajectory_analysis_csc_SOURCES = \
  trajectory.f90 \
  ts_tools.f90

trajectory.o: ts_tools_mod.$(FC_MODEXT)

MODFILES = ts_tools_mod.$(FC_MODEXT)
BUILT_SOURCES = $(MODFILES)

include $(top_srcdir)/mkmods.mk
