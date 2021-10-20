% **********************************************************************
% TCtracker - Tropical Storm Detection
% Copyright (C) 1997-2008, 2021 Frederic Vitart, Joe Sirutis, Ming Zhao,
% Kyle Olivo, Keren Rosado and Seth Underwood
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
% 02110-1301, USA.
% **********************************************************************

function startup

% nc64startup -- Startup script for the NetCDF/MEXNC/SNCTools Toolbox.
% nc64startup (no argument) adjusts the Matlab path
% to include the components of the NetCDF Toolbox.
%
% Remik dot Ziemlinski at noaa dot gov
% 2.03.2004 Created for cdf1.
% 9.01.2006 Added nc64bit support and new mexnc tools. Tested all cases.

%Paidemwoyo dot Munhutu at noaa.gov
%12.15.2009 Added netcdf-4 read support using mexnc and opendap

% Find operating system to adjust path.
os = system_dependent('getos');
% SGI 230, Dell workstations, and IA64 emulation.
i686 = ~isempty(findstr('i686', lower(os)));
% xc1.
x86_64 = ~isempty(findstr('x86_64', lower(os)));
% onyx/anc.
irix = ~isempty(findstr('irix', lower(os)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MEXNC.
% Make sure that the mex-file precedes the m-file "mexnc.m".

%mexncdir = '/net/pem/Matlab/Mex_nc/mexnc';
mexncdir = '/usr/local/mexcdf/mexnc';
if (i686)
path(path, fullfile(mexncdir, 'i686'));
setpref('MEXNC','USE_TMW',false);
elseif (x86_64)
path(path, fullfile(mexncdir, 'x86_64'));
setpref('MEXNC','USE_TMW',false);
elseif ('irix')
% Skip. Mexnc not supported.
[];
else
error('ERROR (ncstartup.m): NetCDF interface not loaded. Found unsupported operating system.');
return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NetCDF Toolbox.
% Make sure that mexnc precedes the netcdf_toolbox in your matlab path.

mexcdfdir = '/usr/local/mexcdf/netcdf_toolbox/';
if (i686)
path(path, fullfile(mexcdfdir, 'netcdf'));
elseif (x86_64)
path(path, fullfile(mexcdfdir, 'netcdf'));
elseif (irix)
% Still uses netcdf-3.5.1.
mexcdfdir = '/home/rsz/matlab/irix/mexcdf/mexcdf53';
else
error('ERROR (startup.m): NetCDF interface not loaded. Found unsupported operating system.');
return;
end

path(path, fullfile(mexcdfdir, 'netcdf', ''));
path(path, fullfile(mexcdfdir, 'netcdf', 'nctype', ''));
path(path, fullfile(mexcdfdir, 'netcdf', 'ncutility', ''));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SNCTOOLS
path(path, '/usr/local/mexcdf/snctools');
disp('NetCDF Toolbox Initialized.');

javaaddpath('/usr/local/mexcdf/netcdfAll-4.0.jar');
setpref ( 'SNCTOOLS', 'USE_JAVA', true );
disp('SNCTOOLS with Java Support (includes netcdf-4).');
opengl software
disp('OpenGL set to Software Rendering');

addpath('/home/miz/matlab/tools');
addpath('/home/miz/matlab/thermlib');
addpath('/home/miz/matlab/m_map');
