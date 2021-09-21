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
