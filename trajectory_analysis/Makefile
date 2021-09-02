include mkmf_template

.DEFAULT:
	-touch $@
all: trajectory_analysis_csc.exe

trajectory.o: trajectory.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c $<
ts_tools.o: ts_tools.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c $<
OBJ = ts_tools.o trajectory.o
clean: neat
	-rm -f .cppdefs $(OBJ) trajectory_analysis_csc.exe *.mod
neat:
	-rm -f $(TMPFILES)
trajectory_analysis_csc.exe: $(OBJ) 
	$(LD) $(OBJ) -o trajectory_analysis_csc.exe  $(LDFLAGS)
