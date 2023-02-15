%  This  program is used to do FVCOM npz phytoplankton and zooplankton initial files
%  Zhonghao Lin , NUIST
%  2023/2/15
%  linzhonghao761@163.com
%  KSL (the total number of depth layers)
%  depth1 depth2 depth3...  (from shallow to deep)
%  1st.mesh.ele.value1 1st.mesh.ele.value2 1st.mesh.ele.value3...
%  2nd.mesh.ele.value1 2nd.mesh.ele.value2 2nd.mesh.ele.value3...
%  .
%  .
%  .
%%
clc;clear all;

addpath './toolboxs'

Mobj = read_sms_mesh('2dm','./input/fin8.2dm','coordinate' ,'spherical');

KSL = 1;
depth = 0.0;
[Mobj.x,Mobj.y,utmzone2,utmhemi2] = wgs2utm(Mobj.lat,Mobj.lon,50,'N');
%%
modisfile = './Chla/AQUA_MODIS.20210401_20210430.L3m.MO.CHL.chlor_a.4km.nc';
ncdisp(modisfile);
chal = ncread(modisfile,'chlor_a');
cha.lon = ncread(modisfile,'lon');
cha.lat = ncread(modisfile,'lat');

value = chal';


Chal_i.domain_cols = length(cha.lon);
Chal_i.domain_rows = length(cha.lat);

[Chal_i.lon, Chal_i.lat] = meshgrid(cha.lon, cha.lat);
[Chal_i.x, Chal_i.y] = wgs2utm(Chal_i.lat, Chal_i.lon, 50, 'N');

Chal_i.x = reshape(Chal_i.x, Chal_i.domain_rows, Chal_i.domain_cols);
Chal_i.y = reshape(Chal_i.y, Chal_i.domain_rows, Chal_i.domain_cols);
%%


kk =  ~isnan(value(:,:));
Ft = scatteredInterpolant(Chal_i.x(kk), Chal_i.y(kk), value(kk),  'linear', 'nearest');
cha_inter = Ft(Mobj.x, Mobj.y);

%%
fid=fopen('PHYTOPLANKTON_INI_1.dat','w');
fprintf(fid,'KSL = %g\n',KSL);
fprintf(fid,'DPTHSL = %g\n',depth);
fprintf(fid,'TEMPB = %g');
for i = 1:length(cha_inter)
        fprintf(fid,'%g\n',cha_inter(i)*0.5);
end

fclose(fid);

fid=fopen('ZOOPLANKTON_INI_1.dat','w');
fprintf(fid,'KSL = %g\n',KSL);
fprintf(fid,'DPTHSL = %g\n',depth);
fprintf(fid,'TEMPB = %g');
for i = 1:length(cha_inter)
        fprintf(fid,'%g\n',cha_inter(i)*0.2);
end

fclose(fid);


