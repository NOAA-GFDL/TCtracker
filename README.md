# Tropical Storms Detection

This code was designed to detect and track tropical cyclones in global
climate models (GCMs) using data that is typically archived by
GCMs. The code is based on an algorithm developed by Frederic Vitart
when he was a graduate student at GFDL. It has since been modified by
Joe Sirutis, Ming Zhao, Kyle Olivo, and Keren Rosado.  The code is
meant to be used with atmospheric or coupled models with resolutions
higher than 1 degree.

This software uses known physical features such as vorticity, vertical
temperature, and moisture structure, to detect storms and categorize
them by strength. TSTORMS is a single thread sequential program
written in Fortran.

Global climate models are now achieving resolutions where tropical
storms are seen in the resolved-scale flow. This is a recent
development, and has allowed modelers to answer complex questions of
great societal relevance such as: will the number of storms increase
or decrease in a warming world? Will there be more or fewer
destructive land-falling Atlantic hurricanes?

NOAA/GFDL is one of the world’s leading centers of research in the
study of tropical storms in a changing climate. In addition to the
climate models developed by GFDL, other key tools are needed.  TSTORMS
allows us to:

- Find storms in the global temperature, water, and wind fields output
  by a model
- Track such a storm as it travels and evolves 
- Count the gstorms that occur over a particular basin over a storm
  season

## Getting Started

### Environment Configuration

The following packages were used at GFDL to compile and run these
tools. Newer versions of these packages will likely work, but remain
untested.

- tcsh (6.14.00)
- Fortran compiler (gfortran 4.8.5 or Intel Compilers 11.1.073)
- NetCDF (4.2)
- NCO (4.0.3)
- Grace 2D plotting tool (5.1.22)
- Python (3.6) with Jinja2

### Compilation Instructions

This package uses GNU Build System (autoconf, automake) to build and
install the package files.  Please refer to the INSTALL.md file for
basic information on using the GNU Build system.

### IB Tracks data

This package requires additional data files to run properly.  These
files are maintained on the GFDL ftp site at the following location:

```
ftp://ftp.gfdl.noaa.gov/perm/GFDL_pubrelease/TSTORMS/tstorm_ibtracs_data.tar.gz
```

During install time, the location of these files can be specified with
the `configure` option `--with-ibtracs=<path>`.  If this option is not
given at configure time, the location can be specfied using either the
environment variable `IBTRACS_DIR`, or specfiying the
`tropical_storms_wsfc` `-O <path>` option.  The `-O` option takes
presedence over the `IBTRACS_DIR` environment variable.  Both the `-O`
option and the `IBTRACS_DIR` will override the default location set
during `configure`.

### Usage Instructions

To see the available options, just pass the `-h` flag to the main script.

```
NAME
   tropical_storms_wsfc

SYNOPSIS
   tropical_storms_wsfc [-W] -b <year> -e <year> -n <experiment> -i <input directory> -o <output directory>

DESCRIPTION
   Creates figures and statistics from atmospheric data.

OPTIONS
   -W    Enables the use of w850 input data instead of wsfc.
   -b    First year to start processing data.
   -e    Last year to stop processing data.
   -n    Experiment name.
   -O    Location of ibtracs data.
   -i    Location of post-processed input files.
   -o    Location for storing the analysis data and figures.
   -p    Generate plots only
   -w    Set wind threshold
   -V    Print version information
   -h    Print usage information```

The input filenames are expected to be in this format: `atmos.1981010100-1981123123.slp.nc`.

The script and associated Fortran applications will generate
trajectory information which you can then plot separately with the
tool of your choosing.

## Referenced Works

Knutson, Thomas R., Joseph J Sirutis, Stephen T Garner, Gabriel A
Vecchi, and Isaac M Held, 2008: Simulated reduction in Atlantic
hurricane frequency under twenty-first-century warming
conditions. *Nature Geoscience*, **1**, 359–364,
DOI:[10.1038/ngeo202](https://doi.org/10.1038/ngeo202)

Vitart, F., D. Anderson, and T. N. Stockdale, 2003: Seasonal
forecasting of tropical cyclone landfall over
Mozambique. *J. Climate*, **16**, 3932-3945,
DOI:[10.1175/1520-0442(2003)016<3932:SFOTCL>2.0.CO;2](https://doi.org/10.1175/1520-0442(2003)016<3932:SFOTCL>2.0.CO;2).

Vitart, F., J. L. Anderson, W. F. Stern, 1997: Simulation of
Interannual Variability of Tropical Storm Frequency in an Ensemble of
GCM Integrations. *J. Climate*, **10(4)**, 745-760,
DOI:[10.1175/1520-0442(1997)010%3C0745:SOIVOT%3E2.0.CO;2](https://doi.org/10.1175/1520-0442(1997)010%3C0745:SOIVOT%3E2.0.CO;2).

Vitart, F., T. N. Stockdale, 2001: Seasonal forecasting of tropical
storms using coupled GCM integrations. *MWR*, **129**, 2521-2537
DOI:[10.1175/1520-0493(2001)129%3C2521:SFOTSU%3E2.0.CO;2](https://doi.org/10.1175/1520-0493(2001)129%3C2521:SFOTSU%3E2.0.CO;2).

Zhao, Ming, Isaac M Held, Shian-Jiann Lin, and Gabriel A Vecchi,
December 2009: Simulations of global hurricane climatology,
interannual variability, and response to global warming using a 50km
resolution GCM. *Journal of Climate*, **22(24)**,
DOI:[10.1175/2009JCLI3049.1](https://doi.org/10.1175/2009JCLI3049.1)

## Contacts

This software is provided under the GPLv2 license (please see the
LICENSE.md file for more details). If you have questions about this
package, you may contact GFDL's climate model info mailing list:
gfdl.climate.model.info@noaa.gov
