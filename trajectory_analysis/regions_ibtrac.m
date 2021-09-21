
function [ts]=regions_ibtrac(ts,opt)

%load('/net/miz/hiram_runs/c180/c180_hiram_1987/analysis/tropical_storms_wsfc/c180_hiram_1987_traj.mat');
%ts=v.tr
ll=40; ll=48;
v.box(1).nm='GG'; v.box(1).xy =[0.    -90 360-0    180]; 
v.box(2).nm='NA'; v.box(2).xy =[260.   0  360-260  ll]; %plot([260 295],[20 0]);
v.box(3).nm='SA'; v.box(3).xy =[265. -ll  360-265  ll];
v.box(4).nm='WP'; v.box(4).xy =[100.   0  180-100  ll];
v.box(5).nm='EP'; v.box(5).xy =[180    0  260-180  ll];
v.box(6).nm='NI'; v.box(6).xy =[30.    0  100-30   ll];
v.box(7).nm='SI'; v.box(7).xy =[10.  -ll  135-10   ll];
v.box(8).nm='SP'; v.box(8).xy =[135. -ll  265-135  ll];

for n=1:length(ts)
  for i=1:ts(n).num
    if (ts(n).lon(i)     >= v.box(2).xy(1)                & ...
	ts(n).lon(i)     <= v.box(2).xy(1)+v.box(2).xy(3) & ...
	ts(n).lat(i)     >= v.box(2).xy(2)                & ...
	ts(n).lat(i)     <= v.box(2).xy(2)+v.box(2).xy(4))
      ts(n).nm(i) =               2;
    elseif (ts(n).lon(i) >= v.box(3).xy(1)                & ...
	    ts(n).lon(i) <  v.box(3).xy(1)+v.box(3).xy(3) & ...
	    ts(n).lat(i) >= v.box(3).xy(2)                & ...
	    ts(n).lat(i) <  v.box(3).xy(2)+v.box(3).xy(4))
      ts(n).nm(i) =               3;
    elseif (ts(n).lon(i) >= v.box(4).xy(1)                & ...
	    ts(n).lon(i) <  v.box(4).xy(1)+v.box(4).xy(3) & ...
	    ts(n).lat(i) >= v.box(4).xy(2)                & ...
	    ts(n).lat(i) <  v.box(4).xy(2)+v.box(4).xy(4))
      ts(n).nm(i) =               4;
    elseif (ts(n).lon(i) >= v.box(5).xy(1)                & ...
	    ts(n).lon(i) <  v.box(5).xy(1)+v.box(5).xy(3) & ...
	    ts(n).lat(i) >= v.box(5).xy(2)                & ...
	    ts(n).lat(i) <  v.box(5).xy(2)+v.box(5).xy(4))
      ts(n).nm(i) =               5;
    elseif (ts(n).lon(i) >= v.box(6).xy(1)                & ...
	    ts(n).lon(i) <  v.box(6).xy(1)+v.box(6).xy(3) & ...
	    ts(n).lat(i) >= v.box(6).xy(2)                & ...
	    ts(n).lat(i) <  v.box(6).xy(2)+v.box(6).xy(4))
      ts(n).nm(i) =               6;
    elseif (ts(n).lon(i) >= v.box(7).xy(1)                & ...
	    ts(n).lon(i) <  v.box(7).xy(1)+v.box(7).xy(3) & ...
	    ts(n).lat(i) >= v.box(7).xy(2)                & ...
	    ts(n).lat(i) <  v.box(7).xy(2)+v.box(7).xy(4))
      ts(n).nm(i) =               7;
    elseif (ts(n).lon(i) >= v.box(8).xy(1)                & ...
	    ts(n).lon(i) <  v.box(8).xy(1)+v.box(8).xy(3) & ...
	    ts(n).lat(i) >= v.box(8).xy(2)                & ...
	    ts(n).lat(i) <  v.box(8).xy(2)+v.box(8).xy(4))
      ts(n).nm(i) =               8;
    else
      ts(n).nm(i) =               1;
    end
    if (ts(n).nm(i)==2)
      if (ts(n).lon(i) <= 260-(min(ts(n).lat(i),20)-20)*(295-260)/20)
	ts(n).nm(i)=5;
      end
    end
  end
  
%  for m=1:10
%    aaa(m)=sum(ts(n).nm==m); %how many times it falls in box m
%  end
%  m=find(aaa==max(aaa)); clear aaa; %box m get the most hit, my method
  
  m=ts(n).nm(1);%to be consistent with Joe's method and standard
  
  ts(n).boxnumb=m;
  ts(n).boxname=v.box(m).nm;
  ts(n).yearmax=ts(n).year(1);
  
  for m=1:12
    aaa(m)=sum(ts(n).month==m); %how many times it falls in month m
  end
  m=find(aaa==max(aaa)); clear aaa; %month m get the most hit
  ts(n).monthmax=min(m);
  
  ts(n).monthmax=ts(n).month(1);%just pick the first time storm identified

  
  ts(n).windmax=max(ts(n).wind);
  ts(n).presmin=min(ts(n).pres);
  if (strcmp(opt,'mod'))
    ts(n).vortmax=max(ts(n).vort);
  end
  if (ts(n).num>=3)
    ts(n).delt = max(ts(n).hour(2)-ts(n).hour(1),ts(n).hour(3)-ts(n).hour(2))*3600.;
  else
    ts(n).delt = 6*3600.;
  end
  ts(n).dur_norm=ts(n).num*ts(n).delt;
  ts(n).dur_velw=0.;
  ts(n).pdi     =0.;
  ts(n).ace     =0.;
  ts(n).dur_s   =0;
  for i=1:ts(n).num
    ts(n).dur_velw=ts(n).dur_velw+ts(n).wind(i)  *ts(n).delt;
    if (ts(n).wind(i)>=17)
      ts(n).pdi     =ts(n).pdi     +ts(n).wind(i)^3;
      ts(n).ace     =ts(n).ace     +ts(n).wind(i)^2;
      ts(n).dur_s   =ts(n).dur_s   +1;
    end
  end
  ts(n).dur_velw=ts(n).dur_velw/ts(n).windmax;
  
end


return


figure;
fnstatic='/home/miz/AM2p12b/analysis/miztstorm/scripts/atmos.static.nc';
f =netcdf(fnstatic,'nowrite');
ncvars = var(f); latname='lat'; lonname='lon';
v.lat =f{latname}(:); v.lon=f{lonname}(:); 
v.lm=f{'land_mask'}(:,:); v.lm(v.lm>=0.5)=1; v.lm(v.lm<0.5)=0;
v.nlat=length(v.lat); v.nlon=length(v.lon); v.ngrid=v.nlat*v.nlon;
close(f); 
contour(v.lon, v.lat, v.lm); hold on;
%rectangle('Position',v.box(1).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(2).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(3).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(4).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(5).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(6).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(7).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(8).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(9).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(10).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(11).xy,'LineWidth',2,'LineStyle','-');
rectangle('Position',v.box(12).xy,'LineWidth',2,'LineStyle','-');

y=[0:1:40]; 
for i=1:length(y)
  x(i)= 260-(min(y(i),20)-20)*(295-260)/20;
end
plot(x,y,'s-'); return


plot([260 295],[20 0]);
return

% $$$ 
% $$$ 
% $$$ v.box(1).nm='GG';v.box(1).xb=0.;   v.box(1).xe=360.;  v.box(1).yb=90.;v.box(1).ye=-90.;
% $$$ v.box(2).nm='WA';v.box(2).xb=265.; v.box(2).xe=340.;  v.box(2).yb=48.;v.box(2).ye=0.;
% $$$ v.box(3).nm='EA';v.box(3).xb=340.; v.box(3).xe=360.;  v.box(3).yb=48.;v.box(3).ye=0.;
% $$$ v.box(4).nm='WP';v.box(4).xb=105.; v.box(4).xe=200.;  v.box(4).yb=48.;v.box(4).ye=0.;
% $$$ v.box(5).nm='EP';v.box(5).xb=200;  v.box(5).xe=265.;  v.box(5).yb=48.;v.box(5).ye=0.;
% $$$ v.box(6).nm='NI';v.box(6).xb=40.;  v.box(6).xe=105.;  v.box(6).yb=48.;v.box(6).ye=0.;
% $$$ v.box(7).nm='SI';v.box(7).xb=30.;  v.box(7).xe=105.;  v.box(7).yb=0.; v.box(7).ye=-48.;
% $$$ v.box(8).nm='AU';v.box(8).xb=105.; v.box(8).xe=165;   v.box(8).yb=0.; v.box(8).ye=-48.;
% $$$ v.box(9).nm='SP';v.box(9).xb=165.; v.box(9).xe=265;   v.box(9).yb=0.; v.box(9).ye=-48.;
% $$$ v.box(10).nm'SA';v.box(10).xb=265.;v.box(10).xe=360.; v.box(10).yb=0.;v.box(10).ye=-48.;
% $$$ v.box(11).nm'NH';v.box(11).xb=0.;  v.box(11).xe=360.; v.box(11).yb=48.;v.box(11).ye=0.;
% $$$ v.box(12).nm'SH';v.box(12).xb=0.;  v.box(12).xe=360.; v.box(12).yb=0.;v.box(12).ye=-48.;
% $$$ 
% $$$ 
