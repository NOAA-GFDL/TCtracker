# **********************************************************************
# TCtracker - Tropical Storm Detection
# Copyright (C) 1997-2008, 2021 Frederic Vitart, Joe Sirutis, Ming Zhao,
# Kyle Olivo, Keren Rosado and Seth Underwood
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
# **********************************************************************

# Basic lightweight container
FROM alpine:3.13 as baseos
RUN apk update
RUN apk add --no-cache automake autoconf bash bison build-base coreutils curl-dev expat-dev findutils \
    flex git gfortran hdf5-dev libcurl libexecinfo-dev libtool m4 perl tcsh texinfo util-linux zlib-dev
RUN apk add --no-cache bash build-base vim

FROM baseos as ncpkgs

# NetCDF-c
WORKDIR /
RUN git clone -b v4.7.4 https://github.com/Unidata/netcdf-c.git
WORKDIR netcdf-c
RUN ./configure --prefix=/usr
RUN make -j4 install

# NetCDF-fortran
WORKDIR /
RUN git clone -b v4.5.3 https://github.com/Unidata/netcdf-fortran.git
WORKDIR netcdf-fortran
RUN ./configure --prefix=/usr
RUN make -j4 install

# UDUNITS
WORKDIR /
RUN git clone https://github.com/Unidata/UDUNITS-2.git
WORKDIR UDUNITS-2
RUN autoreconf -if
RUN ./configure --prefix=/usr
RUN make -j4 install

# NCO Utilities
WORKDIR /
RUN git clone -b 4.9.0 https://github.com/nco/nco.git
WORKDIR nco
RUN ./configure --prefix=/usr
RUN make -j4 install

# Remove source codes to keep image size down
WORKDIR /
RUN rm -fR netcdf-c netcdf-fortran nco UDUNITS-2


FROM ncpkgs

# Copy in model source code and put it in the container
WORKDIR /
RUN git clone -b autoconf.build https://github.com/underwoo/TCtracker.git
WORKDIR TCtracker
RUN autoreconf -if
RUN ./configure --prefix=/usr/local
RUN make install

# Launch a shell when the container is started
ENTRYPOINT ["/bin/bash"]
