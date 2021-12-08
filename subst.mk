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

do_subst = $(SED) \
  -e 's,[@]PACKAGE_NAME[@],$(PACKAGE_NAME),g' \
  -e 's,[@]VERSION[@],$(VERSION),g' \
  -e 's,[@]EXEEXT[@],$(EXEEXT),g' \
  -e 's,[@]GRACEBAT[@],$(GRACEBAT),g' \
  -e 's,[@]NCRCAT[@],$(NCRCAT),g' \
  -e 's,[@]PYTHON[@],$(PYTHON),g' \
  -e 's,[@]prefix[@],$(prefix),g' \
  -e 's,[@]exec_prefix[@],$(exec_prefix),g' \
  -e 's,[@]libdir[@],$(libdir),g' \
  -e 's,[@]libexecdir[@],$(libexecdir),g' \
  -e 's,[@]datarootdir[@],$(datarootdir),g' \
  -e 's,[@]datadir[@],$(datadir),g' \
  -e 's,[@]pkgdatadir[@],$(pkgdatadir),g' \
  -e 's,[@]pkglibdir[@],$(pkglibdir),g' \
  -e 's,[@]pkglibexecdir[@],$(pkglibexecdir),g' \
  -e 's,[@]pythondir[@],$(pythondir),g' \
  -e 's,[@]pkgpythondir[@],$(pkgpythondir),g' \
  -e 's,[@]ibtracs_dir[@],$(ibtracs_dir),g'

%.f90: %.f90.in Makefile
	$(do_subst) < $< > $@
%.py: %.py.in Makefile
	$(do_subst) < $< > $@
