#!/bin/tcsh -f
#------------------------------------
# MOAB batch directives
#PBS -N tropical_storms_wsfc.csh
#PBS -l walltime=18:00:00
#PBS -l size=2
#PBS -j oe
#PBS -o $HOME/msub_output/
#PBS -r y

# Variables passed by frepp
set out_dir
set yr1
set yr2
set descriptor
set in_data_dir
set argu

set SCRIPT_ROOT = `dirname $0`
set SCRIPT_ROOT = `cd $SCRIPT_ROOT && pwd`

set year_beg = $yr1
set year_end = $yr2
set expname = $descriptor
set data_dir = $in_data_dir
set analysis_dir = $out_dir
set do_wsfc = y
set wind_th = 29.5
set matlab = 1

set getopt_list = "b:e:n:i:o:Ww:h"
set argv = (`getopt $getopt_list $*`)
if ("$argv" == "--") then
   echo "To get help, use -h"; exit 1
endif
while ("$argv[1]" != "--")
  switch ($argv[1])
  case -b:
    set year_beg = "$argv[2]"; shift argv; breaksw
  case -e:
    set year_end = "$argv[2]"; shift argv; breaksw
  case -n:
    set expname = "$argv[2]"; shift argv; breaksw
  case -i:
    set data_dir = "$argv[2]"; shift argv; breaksw
  case -o:
    set analysis_dir = "$argv[2]"; shift argv; breaksw
  case -W:
    set do_wsfc = "n"; breaksw
  case -w:
    set wind_th = "$argv[2]"; shift argv; breaksw
  case -h:
    set help; breaksw
  endsw
  shift argv
end
shift argv

if ($?help) then
   cat <<EOF
NAME
   tropical_storms_wsfc

SYNOPSIS
   tropical_storms_wsfc.csh [-W] -b <year> -e <year> -n <experiment> -i <input directory> -o <output directory>

DESCRIPTION
   Creates figures and statistics from atmospheric data.

OPTIONS
   -W    Enables the use of w850 input data instead of wsfc.
   -b    First year to start processing data.
   -e    Last year to stop processing data.
   -n    Experiment name.
   -i    Location of post-processed input files.
   -o    Location for storing the analysis data and figures.

EOF
   exit 1
endif

# Certain scripts/commands are GFDL specific
set gfdl = 0
if (`hostname -d` == "princeton.rdhpcs.noaa.gov") then
    set gfdl = 1
endif

if ($year_beg == "" || $year_end == "" || $expname == "" || \
    $data_dir == "" || $analysis_dir == "") then
    echo "Error: These options need values -- please consult the help screen (-h):"
    echo "Beginning year (-b): $year_beg"
    echo "Ending year (-e): $year_end"
    echo "Experiment (-n): $expname"
    echo "Input directory (-i): $data_dir"
    echo "Output directory (-o): $analysis_dir"
    exit 1
endif

set analysis_dir = $analysis_dir/atmos_${year_beg}_${year_end}/Zhao.TC

if ($gfdl) then
    source $MODULESHOME/init/csh
    module use -a /home/fms/local/modulefiles
    module purge
    module load netcdf/4.2
    module load mpich2
    module load gcp
    module load nco
endif

set tstorms_driver = $SCRIPT_ROOT/tstorms_driver/tstorms_driver.exe
set plot_scripts = $SCRIPT_ROOT/plot_tc_csc
set hurricane_cat1to5_output = ${analysis_dir}/hurricanes_cat1-5_wsfc/
set hurricane_cat3to5_output = ${analysis_dir}/hurricanes_cat3-5_wsfc/
set hurricane_cat4to5_output = ${analysis_dir}/hurricanes_cat4-5_wsfc/

if ( "$do_wsfc" == "y" ) then
    set cyclones_dir = $analysis_dir/cyclones_wsfc
    set tstorms_dir = $analysis_dir/tropical_storms_wsfc/
    if ( ! -e $tstorms_dir  ) mkdir -p $tstorms_dir
else
    set cyclones_dir = $analysis_dir/cyclones_w850
endif

if ( ! -e $cyclones_dir  ) mkdir -p $cyclones_dir

set TSTORM_TEMP = $TMPDIR/$analysis_dir
if ($gfdl) then
    set TSTORM_TEMP = $FTMPDIR/$analysis_dir
endif
mkdir -p $TSTORM_TEMP
cd $TSTORM_TEMP

# For arbitrary years less than the smallest observation year (1980),
# we need to add the observation year to the current_year
# Discussed this with Ming.Zhao on 8/3/2013 - keo.
@ obs_first_year = ${year_beg}
@ obs_last_year = ${year_end}
if (${year_beg} < 100) then
    @ obs_first_year = ${year_beg} + 1980
    @ obs_last_year = ${year_end} + 1980
endif

@ last_completed_year = `find $cyclones_dir -name cyclones_\* -xtype f -exec basename {} \; | awk -F "." '{print $1}' | tail -1 | awk -F "_" '{print $NF}'`

if ($last_completed_year == 0) then
    @ next_year_to_process = $year_beg
else
    @ next_year_to_process += $last_completed_year + 1
endif

set file = `find ${data_dir} -name \*.nc -xtype f -printf "%f\n" | head -n 1`
set pp_type = `echo $file | awk -F "." '{print $1}'`
set file_first_year = `echo $file | awk -F "." '{print $2}' | awk -F "-" '{print $1}' | cut -c 1-4`
set file_last_year = `echo $file | awk -F "." '{print $2}' | awk -F "-" '{print $2}' | cut -c 1-4`
set start_month = `echo $file | awk -F "." '{print $2}' | awk -F "-" '{print $1}' | cut --complement -c 1-4`
set end_month = `echo $file | awk -F "." '{print $2}' | awk -F "-" '{print $2}' | cut --complement -c 1-4`

# === Copy input files ===

echo "copying input files..."
# List of input variables
if ( "$do_wsfc" == "y" ) then
   set varlist = "u_ref v_ref"
else
   set varlist = "u850 v850"
endif
set varlist = "${varlist} vort850 tm slp"

# List of input files
cd ${data_dir}
set filelist = ()
foreach var (${varlist})

    #echo Processing variable ${var}

    foreach file (`ls -1 ${pp_type}.????010100-????123123.${var}.nc`)

	#echo Processing file ${file}

	# First year
	set yra = `echo $file | awk -F "." '{print $2}' | awk -F "-" '{print $1}' | cut -c 1-4`
	# Last year
	set yrb = `echo $file | awk -F "." '{print $2}' | awk -F "-" '{print $2}' | cut -c 1-4`
     
	# Does the time span of file overlap with desired period year_beg,year_end?
	# Note: use "bc -l" to remove any leading zeroes, otherwise numbers may be 
	# interpreted as octals instead of decimals
	set n_yra = `echo "${yra}" | bc -l`
	set n_yrb = `echo "${yrb}" | bc -l`
	set n_year_beg = `echo "${year_beg}" | bc -l`
	set n_year_end = `echo "${year_end}" | bc -l`
	if ( ${n_yra} <= ${n_year_end} && ${n_yrb} >= ${n_year_beg} ) then
	    set filelist = (${filelist} ${file})
	    #echo Including file ${file}
	endif 

	if ($#filelist > 500) then
	    if ($gfdl) then
		dmget ${filelist}
		gcp -cd ${filelist} $TSTORM_TEMP/tmp/ 
	    else
		mkdir -p $TSTORM_TEMP/tmp/
		cp ${filelist} $TSTORM_TEMP/tmp/
	    endif
	    set filelist = ()
	endif

    end
  
end

if ( $#filelist != 0 ) then
    if ($gfdl) then
	dmget ${filelist}
	gcp -cd ${filelist} $TSTORM_TEMP/tmp/ 
    else
	mkdir -p $TSTORM_TEMP/tmp/
	cp ${filelist} $TSTORM_TEMP/tmp/
    endif
endif

echo "creating one year chunks, if needed..."
# Loop over years and create 1 year chunk files if necessary
cd $TSTORM_TEMP/tmp
foreach current_year (`seq $next_year_to_process 1 $year_end`)

    @ next_year = $current_year
    # Check if this is a non-January start date
    if ($start_month != "010100") then
        @ next_year = $current_year + 1
    endif

    # Padding year with initial zeroes, if needed
    set padded_current_year = `echo $current_year | awk '{printf "%04d\n", $0;}'`
    set padded_next_year = `echo $next_year | awk '{printf "%04d\n", $0;}'`

    set prefix = ${pp_type}.${padded_current_year}${start_month}-${padded_next_year}${end_month}

    foreach var (${varlist})
	test -e ${prefix}.${var}.nc
	set file_exist = $?
        if ( $file_exist ) then
            if ( $start_month == "010100" ) then
              # File with desired 1 year chunk length does not exist, create it.
              @ yra = $current_year
              @ yrb = $current_year + 1
              ncrcat -d time,"${yra}-01-01 06:00:00","${yrb}-01-01 00:00:00" \
                     -o ../${prefix}.${var}.nc ${pp_type}.*.${var}.nc
            else
              echo " ERROR: cannot create 1 year chunk files for non-January start date"
              exit
            endif
        else
            # File with 1 year chunk length exists, simply move it.
            mv ${prefix}.${var}.nc ..
        endif
    endif

    end
end

# Clean up tmp subdir
cd $TSTORM_TEMP
rm -rf tmp

# === Loop over years and process data ===
foreach current_year (`seq $next_year_to_process 1 $year_end`)

    echo "beginning process for year: $current_year"

    @ next_year = $current_year
    # Check if this is a non-January start date
    if ($start_month != "010100") then
        @ next_year = $current_year + 1
    endif

    # Padding year with initial zeroes, if needed
    set padded_current_year = `echo $current_year | awk '{printf "%04d\n", $0;}'`
    set padded_next_year = `echo $next_year | awk '{printf "%04d\n", $0;}'`

    set filename_prefix = ${pp_type}.${padded_current_year}${start_month}-${padded_next_year}${end_month}
    if ( "$do_wsfc" == "y" ) then
        set u_ref_filename        = ${filename_prefix}.u_ref.nc
        set v_ref_filename        = ${filename_prefix}.v_ref.nc
        set use_sfc_wnd = .true.
    else
        set u_ref_filename        = ${filename_prefix}.u850.nc
        set v_ref_filename        = ${filename_prefix}.v850.nc
        set use_sfc_wnd = .false.
    endif

    cat << eof > nml_input
 &nml_tstorms
   crit_vort  =  3.5E-5,   
   crit_twc   =  0.0,   
   crit_thick =  50.0,  
   crit_dist  =   4.0,   
  lat_bound_n =  70.0
  lat_bound_s = -70.0
  do_spline   = .false.
  do_thickness= .false.
 &end
 &input
   fn_u    = '$u_ref_filename',
   fn_v    = '$v_ref_filename',
   fn_vort = '${filename_prefix}.vort850.nc',
   fn_tm   = '${filename_prefix}.tm.nc',
   fn_slp  = '${filename_prefix}.slp.nc',
   use_sfc_wnd = $use_sfc_wnd
 &end
eof
    echo "beginning storm code..."
    cp $tstorms_driver tstorms_driver 
    ./tstorms_driver < nml_input
    if ($gfdl) then
	gcp nml_input $cyclones_dir
    else
	cp nml_input $cyclones_dir
    endif

    # To compare against obs data, we need to increase
    # the value of small start years (conversation with 
    # Ming.Zhao 8/2/2013 - keo)
    @ obs_year = ${current_year}
    if (${current_year} < 100) then
        @ obs_year = ${current_year} + 1980
    endif

    echo "moving files to proper place..."
    if ( -e cyclones ) then
        mv cyclones cyclones_${obs_year}
	if ($gfdl) then
	    gcp cyclones_${obs_year} ${cyclones_dir}
	else
	    cp cyclones_${obs_year} ${cyclones_dir}
	endif	
        echo "OUTPUT ADDED TO: " ${cyclones_dir}/cyclones_${obs_year}
    else
        echo "ERROR: JOB FAILED"
        exit
    endif
end

if ( "$do_wsfc" == "y" ) then
    echo "beginning hurricane trajectory code..."
    set trajectory_analysis  = $SCRIPT_ROOT/trajectory_analysis/trajectory_analysis_csc.exe

    cat << eof > nml_traj
 &input
    rcrit      =  1500.0
    wcrit      =  15.2
    vcrit      =  3.5e-5
    twc_crit   =  1.
    thick_crit =  0.
    nwcrit     =  3
    do_filt    = .true.
    nlat       = 70.
    slat       =-70.
    do_spline  = .false.
    do_thickness = .false.
 &end
eof

    if ($gfdl) then
	gcp nml* $tstorms_dir
    else
	cp nml* $tstorms_dir
    endif

    set cyclone_files = `find $cyclones_dir -name cyclones_\* -xtype f`
    if ($#cyclone_files == 0) then
        echo "ERROR: No files to process."
    endif

    echo "running trajectory analysis for each cyclone file..."
    foreach cyclone_file ($cyclone_files)
         if (-e cyclones) then 
             rm -f cyclones
         endif
	
	if ($gfdl) then
	    gcp $cyclone_file cyclones
	else
	    cp $cyclone_file cyclones
	endif
        set cyclone_filename = $cyclone_file:t
        set year = `echo $cyclone_filename | awk -F "_" '{print $NF}'`
        $trajectory_analysis < nml_traj

        mv ori_filt   ${tstorms_dir}/ori_${year}
        mv traj_filt  ${tstorms_dir}/traj_${year}
        mv trav_filt  ${tstorms_dir}/trav_${year}
        cat stats
        rm ori
        rm traj
        rm trav
        rm stats
    end

    if ($gfdl) then
	setenv ATW_UTIL $SCRIPT_ROOT/atw/util/

	set ori_stat             = ${plot_scripts}/ori_stat 
	set graph_snap_shot      = ${plot_scripts}/graph_snap_shot
	set graph_by_latitude    = ${plot_scripts}/graph_by_latitude
	set graph_by_longitude   = ${plot_scripts}/graph_by_longitude
	set graph_by_region      = ${plot_scripts}/graph_by_region
	set graph_seasonal_cycle = ${plot_scripts}/graph_seasonal_cycle
	set graph_time_series    = ${plot_scripts}/graph_time_series
	set graph_duration       = ${plot_scripts}/graph_duration
	set jmaps_freq           = ${plot_scripts}/jmaps_freq
	set jmaps_ori            = ${plot_scripts}/jmaps_ori
	set jmaps_traj           = ${plot_scripts}/jmaps_traj
	set jmaps_occu           = ${plot_scripts}/jmaps_occu                                                   

	set first_year = $obs_first_year
	set last_year = $year
    
	if ( ( $last_year < 1950 ) || ( $first_year > 2005 ) ) then
	    set experiment_type = clim
	else
	    set experiment_type = obs
	endif
	
	echo "generating stats and plots..."
	if ( $experiment_type == obs ) then
	    $ori_stat $tstorms_dir $first_year $last_year y
	else
	    $ori_stat $tstorms_dir $first_year $last_year n
	endif 

	set plot_option = tc

	if ( $experiment_type == obs ) then
	    $graph_snap_shot $tstorms_dir $tstorms_dir $first_year $last_year $expname obs $plot_option
	endif

	$graph_time_series     $tstorms_dir $tstorms_dir $first_year $last_year $expname obs $plot_option
	$graph_by_latitude     $tstorms_dir $tstorms_dir $first_year $last_year $expname $experiment_type  $plot_option
	$graph_by_longitude    $tstorms_dir $tstorms_dir $first_year $last_year $expname $experiment_type  $plot_option
	$graph_by_region       $tstorms_dir $tstorms_dir $first_year $last_year $expname $experiment_type  $plot_option
	$graph_seasonal_cycle  $tstorms_dir $tstorms_dir $first_year $last_year $expname $experiment_type  $plot_option
	$graph_duration        $tstorms_dir $tstorms_dir $first_year $last_year $expname $experiment_type  $plot_option
	$jmaps_freq            $tstorms_dir $tstorms_dir $first_year $last_year $expname $experiment_type  $plot_option
	$jmaps_ori             $tstorms_dir $tstorms_dir $first_year $last_year $expname $experiment_type  $plot_option

	if (! -e $hurricane_cat1to5_output) mkdir -p $hurricane_cat1to5_output
	cd $hurricane_cat1to5_output

	cp $SCRIPT_ROOT/trajectory_analysis/dotraj_new.m $hurricane_cat1to5_output 
	cp $SCRIPT_ROOT/trajectory_analysis/startup.m $hurricane_cat1to5_output 
	
	cat > dotraj_nml <<EOF
 $expname
 $tstorms_dir
 $hurricane_cat1to5_output
 $hurricane_cat3to5_output
 $hurricane_cat4to5_output
 $first_year
 $last_year
 $wind_th
EOF

	set graph_option = hur

	matlab79 -nodisplay -nosplash -r dotraj_new
     	
	echo "creating hurricane plots..."
	$plot_scripts/ori_stat $hurricane_cat1to5_output ${first_year} ${last_year} y $graph_option
	$plot_scripts/graph_snap_shot      $hurricane_cat1to5_output ${hurricane_cat1to5_output} ${first_year} ${last_year} ${expname} obs $graph_option
	$plot_scripts/graph_time_series    $hurricane_cat1to5_output ${hurricane_cat1to5_output} ${first_year} ${last_year} ${expname} obs $graph_option
	$plot_scripts/graph_by_latitude    $hurricane_cat1to5_output ${hurricane_cat1to5_output} ${first_year} ${last_year} ${expname} obs $graph_option
	$plot_scripts/graph_by_longitude   $hurricane_cat1to5_output ${hurricane_cat1to5_output} ${first_year} ${last_year} ${expname} obs $graph_option
	$plot_scripts/graph_by_region      $hurricane_cat1to5_output ${hurricane_cat1to5_output} ${first_year} ${last_year} ${expname} obs $graph_option
	$plot_scripts/graph_seasonal_cycle $hurricane_cat1to5_output ${hurricane_cat1to5_output} ${first_year} ${last_year} ${expname} obs $graph_option
	$plot_scripts/graph_duration       $hurricane_cat1to5_output ${hurricane_cat1to5_output} ${first_year} ${last_year} ${expname} obs $graph_option
	$plot_scripts/jmaps_freq           $hurricane_cat1to5_output ${hurricane_cat1to5_output} ${first_year} ${last_year} ${expname} obs $graph_option
    endif
endif

