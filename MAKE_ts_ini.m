%  This  program is used to do HYCOM initial and obc. temperature and
%  salinity.
%  written by LinZhonghao 2022/04/25
%%
clc;clear all;

addpath './toolboxs';
% Read FVCOM grid and sigma

Mobj = read_sms_mesh('2dm','.2dm','coordinate' ,'spherical');

load '50522-50902.mat';

%Model Start time
year = 2021;
month = 5;
day = 6;
hour = 0;

hycom_datastrtime = 522;
model_strtime = 524;
str = model_strtime - hycom_datastrtime+1;
%%

f = f_load_grid(Mobj.lon, Mobj.lat, Mobj.tri, Mobj.h);%read fvcom mesh
fout = 'Taihai_ini_ts.nc';

lon0 = hycom.lon;
lat0 = hycom.lat;

ix = find(lon0>=min(f.x) & lon0<=max(f.x));
iy = find(lat0>=min(f.y) & lat0<=max(f.y));
x1 = ix(1);
nx = length(ix);
y1 = iy(1);
ny = length(iy);
%%
lon0 = lon0(x1:x1+nx-1);
lat0 = lat0(y1:y1+ny-1);

depth0 = hycom.depth;


s0 = hycom.salinity(:,:,:,str);s0 = s0(x1:x1+nx-1,y1:y1+ny-1,:);
t0 = hycom.temperature(:,:,:,str);t0 = t0(x1:x1+nx-1,y1:y1+ny-1,:);



[yy0, xx0] = meshgrid(lat0, lon0);
nz = length(depth0);

time0 = datenum(year, month, day, hour, 0, 0)
%%
% Interpolation
[xxx0,yyy0,utmzone2,utmhemi2] = wgs2utm(xx0,yy0,50,'N');
t = nan(f.node, nz);
s = nan(f.node, nz);
for iz = 1 : nz
    disp(['Interpolating the ' num2str(iz) 'th layer of ' num2str(nz) ' layers.'])
    % t
    kt = ~isnan(t0(:,:,iz));
    Ft = scatteredInterpolant(xx0(kt), yy0(kt), t0(kt), 'linear', 'nearest');
    t(:,iz) = Ft(f.x, f.y);
    % s
    ks = ~isnan(s0(:,:,iz));
    Fs = scatteredInterpolant(xx0(kt), yy0(kt), s0(kt), 'linear', 'nearest');
    s(:,iz) = Fs(f.x, f.y);
end

%%
% Write initial TS output
write_initial_ts(fout, -depth0, t, s, time0);

