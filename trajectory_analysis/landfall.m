
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
tmp1 =v.lm(jj,ii)  *alat + v.lm(jj+1,ii)  *blat;
tmp2 =v.lm(jj,ii+1)*alat + v.lm(jj+1,ii+1)*blat;
land =tmp1*alon+tmp2*blon;

return
