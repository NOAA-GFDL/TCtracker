do_subst = $(SED) \
  -e 's,[@]datadir[@],$(datadir),g' \
  -e 's,[@]pkglibexecdir[@],$(pkglibexecdir),g' \
  -e 's,[@]EXEEXT[@],$(EXEEXT),g'

