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