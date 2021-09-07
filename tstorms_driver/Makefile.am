pkglibexec_PROGRAMS = tstorms_driver

AM_FCFLAGS = $(FC_MODINC). $(FC_MODOUT)$(MODDIR) $(NETCDF_FCFLAGS)
LDADD = $(NETCDF_FCLDFLAGS) $(NETCDF_FCLIBS)

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
