
function [ts]=rdtraj_new(indir,outc15,outc35,outc45,yr,opt,v,wind_th)

cat15=33;   cat35=50;  cat45=59;
slp15=1050; slp35=964; slp45=944;
cat15=wind_th;

orin = strcat('ori_', num2str(yr));
occu = strcat('occ_', num2str(yr));

if (strcmp(opt,'mod'))
  traj = strcat('trav_',num2str(yr));
  fnin = strcat(indir, traj)
  traj = strcat('traj_',num2str(yr));
  ft15 = strcat(outc15,traj);
  ft35 = strcat(outc35,traj);
  ft45 = strcat(outc45,traj);
  fo15 = strcat(outc15,orin);
  fo35 = strcat(outc35,orin);
  fo45 = strcat(outc45,orin);
  fh15 = strcat(outc15,occu);
  fh35 = strcat(outc35,occu);
  fh45 = strcat(outc45,occu);
else
  if (yr>2016); yr=2016; disp('obs stopped at 2016!!!'); end;
  traj = strcat('traj_',num2str(yr));
  fnin = strcat(indir, traj);
  ft15 = strcat(outc15,traj,'_obs');
  ft35 = strcat(outc35,traj,'_obs');
  ft45 = strcat(outc45,traj,'_obs');
  fo15 = strcat(outc15,orin,'_obs');
  fo35 = strcat(outc35,orin,'_obs');
  fo45 = strcat(outc45,orin,'_obs');
  fh15 = strcat(outc15,occu,'_obs');
  fh35 = strcat(outc35,occu,'_obs');
  fh45 = strcat(outc45,occu,'_obs');
end

fid=fopen(fnin,'r');
n=1;
while (1 > 0)
  start=fscanf(fid,'%s',1);
  if (~strcmp(start,'start'))
    break;
  end
  num  =fscanf(fid,'%d',1);
  yyy  =fscanf(fid,'%d',1); 
  mmm  =fscanf(fid,'%d',1);
  ddd  =fscanf(fid,'%d',1);
  hrs  =fscanf(fid,'%d',1);
  ts(n).start = start;
  ts(n).num = num;
  ts(n).yyy = yyy;
  ts(n).mmm = mmm;
  ts(n).ddd = ddd;
  ts(n).hrs = hrs; %disp(num);
  for i=1:num
    ts(n).lon  (i) =fscanf(fid,'%f',1); 
    ts(n).lat  (i) =fscanf(fid,'%f',1); 
    ts(n).wind (i) =fscanf(fid,'%f',1); 
    ts(n).pres (i) =fscanf(fid,'%f',1); 
    ts(n).land (i) =landfall(ts(n).lat(i),ts(n).lon(i),v);
    ts(n).year (i) =fscanf(fid,'%f',1); 
    ts(n).month(i) =fscanf(fid,'%f',1); 
    ts(n).day  (i) =fscanf(fid,'%f',1); 
    ts(n).hour (i) =fscanf(fid,'%f',1); 
    if (strcmp(opt,'mod'))
%      ts(n).iii  (i) =fscanf(fid,'%d',1); 
%      ts(n).jjj  (i) =fscanf(fid,'%d',1);
%      ts(n).vort (i) =fscanf(fid,'%f',1); 
%      ts(n).twc  (i) =fscanf(fid,'%f',1);
    end
  end
  ts(n).landf=(max(ts(n).land)>0);
  ts(n).hur=0; 
  windmax  =max(ts(n).wind);
  presmin  =min(ts(n).pres);
  lentraj  =length(ts(n).wind);
  n=n+1;
end
fclose(fid);

if(strcmp(opt,'mod'))
  for n=1:length(ts)
    for i=2:length(ts(n).lat)-1
      ts(n).lon(i)=(ts(n).lon(i-1)+2.*ts(n).lon(i)+ts(n).lon(i+1))/4.;
      ts(n).lat(i)=(ts(n).lat(i-1)+2.*ts(n).lat(i)+ts(n).lat(i+1))/4.;
    end
  end
  for n=1:length(ts)
    for i=2:length(ts(n).lat)-1
      ts(n).lon(i)=(ts(n).lon(i-1)+2.*ts(n).lon(i)+ts(n).lon(i+1))/4.;
      ts(n).lat(i)=(ts(n).lat(i-1)+2.*ts(n).lat(i)+ts(n).lat(i+1))/4.;
    end
  end
end

t15=fopen(ft15,'w'); %t35=fopen(ft35,'w'); %t45=fopen(ft45,'w');
o15=fopen(fo15,'w'); %o35=fopen(fo35,'w'); %o45=fopen(fo45,'w');
h15=fopen(fh15,'w'); %h35=fopen(fh35,'w'); %h45=fopen(fh45,'w');
for n=1:length(ts)
  ts(n).hur=0; 
  windmax  =max(ts(n).wind);
  presmin  =min(ts(n).pres);
  lentraj  =length(ts(n).wind);
  num      =ts(n).num;
  if (windmax >= cat15)
    fprintf(o15,'%7.2f %7.2f %7d %7d %7d %7d\n',...
	    ts(n).lon(1),  ts(n).lat(1), ...
	    ts(n).year(1), ts(n).month(1),...
	    ts(n).day(1),  ts(n).hour(1));
    
    for i=1:lentraj
      if (ts(n).wind(i) >= cat15)
	fprintf(h15,'%7.2f %7.2f %7d %7d %7d %7d\n',...
		ts(n).lon(i),  ts(n).lat(i), ...
		ts(n).year(i), ts(n).month(i),...
		ts(n).day(i),  ts(n).hour(i));
      end
    end
    fprintf(t15,'%s %7d %7d %7d %7d %7d\n',...
	    ts(n).start,ts(n).num,ts(n).yyy,ts(n).mmm,ts(n).ddd,ts(n).hrs);
    for i=1:num
      fprintf(t15,'%7.2f %7.2f %7.2f %7.2f %7d %7d %7d %7d\n',...
	      ts(n).lon(i),  ts(n).lat(i), ...
	      ts(n).wind(i), ts(n).pres(i), ...
	      ts(n).year(i), ts(n).month(i),...
	      ts(n).day(i),  ts(n).hour(i));
    end
    ts(n).hur=1;
  end
% $$$%  if (((presmin~=-999.00) & (presmin < slp35)) | (windmax >= cat35))
% $$$   if (windmax >= cat35)
% $$$     
% $$$     fprintf(o35,'%7.2f %7.2f %7d %7d %7d %7d\n',...
% $$$ 	    ts(n).lon(1),  ts(n).lat(1), ...
% $$$ 	    ts(n).year(1), ts(n).month(1),...
% $$$ 	    ts(n).day(1),  ts(n).hour(1));
% $$$     
% $$$     for i=1:lentraj
% $$$       if (((ts(n).pres(i)~=-999.00)&(ts(n).pres(i)<slp35))|(ts(n).wind(i)>=cat35))
% $$$ 	fprintf(h35,'%7.2f %7.2f %7d %7d %7d %7d\n',...
% $$$ 		ts(n).lon(i),  ts(n).lat(i), ...
% $$$ 		ts(n).year(i), ts(n).month(i),...
% $$$ 		ts(n).day(i),  ts(n).hour(i));
% $$$       end
% $$$     end
% $$$ 
% $$$     fprintf(t35,'%s %7d %7d %7d %7d %7d\n',...
% $$$ 	    ts(n).start,ts(n).num,ts(n).yyy,ts(n).mmm,ts(n).ddd,ts(n).hrs);
% $$$     for i=1:num
% $$$       fprintf(t35,'%7.2f %7.2f %7.2f %7.2f %7d %7d %7d %7d\n',...
% $$$ 	      ts(n).lon(i),  ts(n).lat(i), ...
% $$$ 	      ts(n).wind(i), ts(n).pres(i), ...
% $$$ 	      ts(n).year(i), ts(n).month(i),...
% $$$ 	      ts(n).day(i),  ts(n).hour(i));
% $$$     end
% $$$     ts(n).hur=3;
% $$$   end
% $$$   
% $$$ %  if (((presmin~=-999.00) & (presmin < slp45)) | (windmax >= cat45))
% $$$   if (windmax >= cat45)
% $$$     
% $$$     fprintf(o45,'%7.2f %7.2f %7d %7d %7d %7d\n',...
% $$$ 	    ts(n).lon(1),  ts(n).lat(1), ...
% $$$ 	    ts(n).year(1), ts(n).month(1),...
% $$$ 	    ts(n).day(1),  ts(n).hour(1));
% $$$ 
% $$$     for i=1:length(ts(n).wind)
% $$$       if (((ts(n).pres(i)~=-999.00)&(ts(n).pres(i)<slp45))|(ts(n).wind(i)>=cat45))
% $$$ 	fprintf(h45,'%7.2f %7.2f %7d %7d %7d %7d\n',...
% $$$ 		ts(n).lon(i),  ts(n).lat(i), ...
% $$$ 		ts(n).year(i), ts(n).month(i),...
% $$$ 		ts(n).day(i),  ts(n).hour(i));
% $$$       end
% $$$     end
% $$$ 
% $$$     fprintf(t45,'%s %7d %7d %7d %7d %7d\n',...
% $$$ 	    ts(n).start,ts(n).num,ts(n).yyy,ts(n).mmm,ts(n).ddd,ts(n).hrs);
% $$$     for i=1:num
% $$$       fprintf(t45,'%7.2f %7.2f %7.2f %7.2f %7d %7d %7d %7d\n',...
% $$$ 	      ts(n).lon(i),  ts(n).lat(i), ...
% $$$ 	      ts(n).wind(i), ts(n).pres(i), ...
% $$$ 	      ts(n).year(i), ts(n).month(i),...
% $$$ 	      ts(n).day(i),  ts(n).hour(i));
% $$$     end
% $$$     ts(n).hur=4;
% $$$   end
end
fclose(t15); %fclose(t35); fclose(t45);
fclose(o15); %fclose(o35); fclose(o45);

return










pms=[ 0, 0, 800, 550]*1.8; 
handle = figure('Position', pms);
for n=1:length(ts)
  if (ts(n).month>=6 & ts(n).month<=8)
    for i=1:ts(n).num
      plot(ts(n).lon, ts(n).lat,'b.-'); hold on;
    end
  end
end

return

pms=[ 0, 0, 800, 550]*1.8; 
handle = figure('Position', pms);

for n=1:length(ts)
  for i=1:ts(n).num
    plot(ts(n).wind(i), ts(n).pres(i),'b.-'); hold on;
  end
end
fsize=16; opt='reverse';
%legend(s1,s2,s3); xy=[150 250 298 306]; 
axis([0 90 860 1030]);
ylabel('minimum sea level pressure (HPa)','FontSize',fsize); 
xlabel('maximum wind speed (m/s)','FontSize',fsize);
set(gca,'YDir','reverse','FontSize',fsize);

return


