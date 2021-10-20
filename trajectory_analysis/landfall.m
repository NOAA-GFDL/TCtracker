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

function land=landfall(lat_ts,lon_ts,v)

jj=min(find(v.lat>=lat_ts)); jj=max(jj-1,1);jj=min(jj,v.nlat-1);
ii=min(find(v.lon>=lon_ts)); ii=max(ii-1,1);ii=min(ii,v.nlon-1);
if (isempty(ii)); ii=v.nlon-1; end;
if (lat_ts > v.lat(end))
  clat=1; alat=0; blat=1; jj=v.nlat-1;
else
  clat=1./(v.lat(jj+1)-v.lat(jj));
  alat=(v.lat(jj+1)-lat_ts   ) *clat;
  blat=(lat_ts     -v.lat(jj)) *clat;
end
clon=1./(v.lon(ii+1)-v.lon(ii));
alon=(v.lon(ii+1)-lon_ts   ) *clon;
blon=(lon_ts     -v.lon(ii)) *clon;
tmp1 =v.lm(ii,jj)  *alat + v.lm(ii,jj+1)  *blat;
tmp2 =v.lm(ii+1,jj)*alat + v.lm(ii+1,jj+1)*blat;
land =tmp1*alon+tmp2*blon;

return
