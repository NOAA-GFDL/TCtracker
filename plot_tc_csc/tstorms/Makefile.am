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
SUBDIRS = templates

pkgpython_PYTHON = \
  __init__.py \
  argparse.py \
  graph_snap_shot.py \
  ori_stat.py \
  StormBox.py
nodist_pkgpython_PYTHON = \
  config.py \
  freq_ori$(PYTHON_EXTENSION_SUFFIX) \
  stat_ori_mask$(PYTHON_EXTENSION_SUFFIX)

BUILT_SOURCES = \
  config.py \
  freq_ori$(PYTHON_EXTENSION_SUFFIX) \
  stat_ori_mask$(PYTHON_EXTENSION_SUFFIX)

EXTRA_DIST = \
  config.py.in \
  freq_ori.f90 \
  stat_ori_mask.f90

%@PYTHON_EXTENSION_SUFFIX@: %.f90
	$(F2PY) -c -m $(basename $(notdir $<)) \
           --fcompiler=$(FC) \
           --f90flags="$(FCFLAGS)" \
           $(AM_LDFLAGS) $(LDFLAGS) \
           $<

include $(top_srcdir)/subst.mk

clean-local:
	-rm -rf $(BUILT_SOURCES)
