
function dotraj_new

% $$$ inmod ='/archive/miz2/GCM/omsk/c90l32_test2/analysis/tropical_storm/figures/'
% $$$ outdir='/archive/miz2/GCM/omsk/c90l32_test2/analysis/tropical_storm/figures/tropical_cyclone/'
% $$$ yr_beg=1981
% $$$ yr_end=2005
% $$$ expname='c90l32_test2';

fid     = fopen('dotraj_nml');
expname = fscanf(fid, '%s', 1)
inmod   = fscanf(fid, '%s', 1)
outc15  = fscanf(fid, '%s', 1)
outc35  = fscanf(fid, '%s', 1)
outc45  = fscanf(fid, '%s', 1)
yr_beg  = fscanf(fid, '%d', 1)
yr_end  = fscanf(fid, '%d', 1)
wind_th = fscanf(fid, '%d', 1)
fclose(fid);

%str=strcat('mkdir?',outdir); str(str=='?')=' '; system(str);
%path (path,'/home/miz/AM2p12b/analysis/miztstorm/mizscripts/matlab/')
path (path,'/home/miz/AM2p12b/mata_dotraj/')

%nc64startup; 
fnstatic='/home/miz/AM2p12b/analysis/miztstorm/scripts/atmos.static.nc';
f =netcdf(fnstatic,'nowrite');
ncvars = var(f); latname='lat'; lonname='lon';
v.lat =f{latname}(:); v.lon=f{lonname}(:); 
v.lm=f{'land_mask'}(:,:); v.lm(v.lm>=0.5)=1; v.lm(v.lm<0.5)=0;
v.nlat=length(v.lat); v.nlon=length(v.lon); v.ngrid=v.nlat*v.nlon;
close(f); 

%comment out to use ibtrac: inobs='/home/miz/AM2p12b/analysis/miztstorm/obs/';
inobs='/home/miz/AM2p12b/analysis/ibtracs/';

n2=0; m2=0;
for yr=yr_beg:yr_end
  ts   =rdtraj_new(inmod,outc15, outc35, outc45, yr, 'mod',v,wind_th);
  tsobs=rdtraj_new(inobs,outc15, outc35, outc45, yr, 'obs',v,33);
%  plottraj(v, ts, tsobs, inmod); 
%  plottraj_monthly(v, ts, tsobs, inmod); 
%  ts    = regions(ts,'mod');
%  tsobs = regions(tsobs,'obs');
  ts    = regions_ibtrac(ts,'mod');
  tsobs = regions_ibtrac(tsobs,'obs');
  n1=n2+1; n2=n1+length(ts)   -1; v.tr   (n1:n2)=ts;
  m1=m2+1; m2=m1+length(tsobs)-1; v.trobs(m1:m2)=tsobs;
  
end

savenam=strcat(inmod,strcat(expname,'_traj.mat')); save(savenam,'v');

n2=0;
for i=1:length(v.tr)
  n1=n2+1; n2=n1+v.tr(i).num-1;
  v.wind(n1:n2)=v.tr(i).wind;
  v.pres(n1:n2)=v.tr(i).pres;
end

m2=0;
for i=1:length(v.trobs)
  m1=m2+1; m2=m1+v.trobs(i).num-1;
  v.wind_obs(m1:m2)=v.trobs(i).wind;
  v.pres_obs(m1:m2)=v.trobs(i).pres;
end

id=v.pres_obs~=-999;
v.pres_obs=v.pres_obs(id);
v.wind_obs=v.wind_obs(id);

%savenam=strcat(inmod,strcat(expname,'_traj.mat')); save(savenam,'v');

%load(savenam);

pms=[ 0, 0, 800, 600]*0.8; visfig='off'; fsize=16; opt='reverse'; lw=3;
handle = figure('Position', pms,'visible',visfig);

pobs=polyfit(v.wind_obs, v.pres_obs, 2);
xobs=[0:0.5:90]; yobs=pobs(1)*xobs.^2+pobs(2)*xobs+pobs(3);
pmod=polyfit(v.wind, v.pres, 2);
xmod=[0:0.5:90]; ymod=pmod(1)*xmod.^2+pmod(2)*xmod+pmod(3);

plot(xobs, yobs,'k-','LineWidth',lw); hold on; 
plot(xmod, ymod,'r-','LineWidth',lw);
plot(v.wind_obs,v.pres_obs,'b.'); 
plot(v.wind,    v.pres,    'm.'); 
plot(xobs, yobs,'k-','LineWidth',lw); 
plot(xmod, ymod,'r-','LineWidth',lw);

expname(expname=='_')='-'; legend('OBS', expname,2);
axis([0 90 860 1030]);
ylabel('minimum sea level pressure (HPa)','FontSize',fsize); 
xlabel('maximum wind speed (m/s)','FontSize',fsize);
set(gca,'YDir','reverse','FontSize',fsize);

printit(visfig,inmod,'wind_pres','scatter');

exit


