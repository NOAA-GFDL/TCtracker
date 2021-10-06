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
