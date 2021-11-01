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
# This directory stores libtool macros, put there by aclocal.
ACLOCAL_AMFLAGS = -I m4

SUBDIRS = \
  plot_tc_csc \
  trajectory_analysis \
  tstorms_driver

nodist_bin_SCRIPTS = tropical_storms_wsfc
BUILT_SOURCES = tropical_storms_wsfc
EXTRA_DIST = tropical_storms_wsfc.in

tropical_storms_wsfc: tropical_storms_wsfc.in Makefile
	$(do_subst) < $< > $@

clean-local:
	-rm -rf tropical_storms_wsfc

include $(top_srcdir)/subst.mk
