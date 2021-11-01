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
# Ensure the $(MODDIR) exists
$(shell test -d $(MODDIR) || mkdir -p $(MODDIR))

SUFFIXES = .$(FC_MODEXT) _mod.$(FC_MODEXT)
.F90.$(FC_MODEXT) .F90_mod.$(FC_MODEXT) .f90.$(FC_MODEXT) .f90_mod.$(FC_MODEXT):
	$(FCCOMPILE) -c $<
	@cp $(MODDIR)/$@ .

CLEANFILES = *.$(FC_MODEXT) $(BUILT_SOURCES:%=$(MODDIR)/%) *__genmod.$(FC_MODEXT) *__genmod.f90
