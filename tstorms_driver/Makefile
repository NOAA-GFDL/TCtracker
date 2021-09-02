include mkmf_template

CPPDEFS = -DTIMING -Duse_libMPI -Duse_netCDF -DSPMD -DLAND_BND_TRACERS

.DEFAULT:
	-touch $@
all: tstorms_driver.exe
get_date.o: time_manager.o utilities.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	get_date.f90
indata.o: get_date.o vorcomp.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	indata.f90
spline.o: spline.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	spline.f90
time_manager.o: time_manager.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	time_manager.f90
tsgpad.o: tsgpad.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	tsgpad.f90
tstorms.o: tstorms.f90 tsgpad.o spline.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	tstorms.f90
tstorms_drive.o: tstorms_drive.f90 tstorms.o indata.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	tstorms_drive.f90
utilities.o: utilities.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	utilities.f90
vorcomp.o: vorcomp.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	vorcomp.f90
OBJ = time_manager.o utilities.o get_date.o indata.o tstorms.o vorcomp.o tstorms_drive.o spline.o tsgpad.o

clean: neat
	-rm -f .cppdefs $(OBJ) tstorms_driver.exe *.mod
neat:
	-rm -f $(TMPFILES)
tstorms_driver.exe: $(OBJ) 
	$(LD) $(OBJ) -o tstorms_driver.exe  $(LDFLAGS)
