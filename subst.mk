do_subst = $(SED) \
  -e 's,[@]PACKAGE_NAME[@],$(PACKAGE_NAME),g' \
  -e 's,[@]VERSION[@],$(VERSION),g' \
  -e 's,[@]EXEEXT[@],$(EXEEXT),g' \
  -e 's,[@]GRACEBAT[@],$(GRACEBAT),g' \
  -e 's,[@]PYTHON[@],$(PYTHON),g' \
  -e 's,[@]prefix[@],$(prefix),g' \
  -e 's,[@]exec_prefix[@],$(exec_prefix),g' \
  -e 's,[@]libdir[@],$(libdir),g' \
  -e 's,[@]libexecdir[@],$(libdir),g' \
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
