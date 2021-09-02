bin_PROGRAMS = trajectory_analysis_csc

AM_FCFLAGS = $(FC_MODINC). $(FC_MODOUT)$(MODDIR) $(NETCDF_FCFLAGS)

trajectory_analysis_csc_SOURCES = \
  trajectory.f90 \
  ts_tools.f90

trajectory.o: ts_tools_mod.$(FC_MODEXT)

MODFILES = ts_tools_mod.$(FC_MODEXT)
BUILT_SOURCES = $(MODFILES)

include $(top_srcdir)/mkmods.mk
