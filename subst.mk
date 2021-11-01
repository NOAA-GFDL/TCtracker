do_subst = $(SED) \
  -e 's,[@]datadir[@],$(datadir),g' \
  -e 's,[@]pkglibexecdir[@],$(pkglibexecdir),g' \
  -e 's,[@]EXEEXT[@],$(EXEEXT),g' \
  -e 's,[@]GRACEBAT[@],$(GRACEBAT),g'

%.f90: %.f90.in Makefile
	$(do_subst) < $< > $@
%.py: %.py.in Makefile
	$(do_subst) < $< > $@
