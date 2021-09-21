# This directory stores libtool macros, put there by aclocal.
ACLOCAL_AMFLAGS = -I m4

SUBDIRS = \
  plot_tc_csc \
  trajectory_analysis \
  tstorms_driver

bin_SCRIPTS = tropical_storms_wsfc
EXTRA_DIST = tropical_storms_wsfc.in

do_subst = $(SED) \
  -e 's,[@]datadir[@],$(datadir),g' \
  -e 's,[@]pkglibexecdir[@],$(pkglibexecdir),g' \
  -e 's,[@]EXEEXT[@],$(EXEEXT),g'

tropical_storms_wsfc: tropical_storms_wsfc.in Makefile
	$(do_subst) < $(srcdir)/tropical_storms_wsfc.in > tropical_storms_wsfc
	chmod +x tropical_storms_wsfc

