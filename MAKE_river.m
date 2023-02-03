%  This  program is used to do FVCOM river input.
%  Zhonghao Lin , NUIST
%  2023/02/2
%  linzhonghao761@163.com
%%
clc;clear all;
addpath './toolboxs';
% Read FVCOM grid and sigma
Mobj = read_sms_mesh('2dm','./input/fin8.2dm','coordinate' ,'spherical');
%
%%
%  ---------------------------------------Taiwan Island------------------------------------------
%  --------------------------------------------------------------------------------------------------
%  Read the runoff data of Taiwan Island.
ncfile = 'coastal-stns-Vol-monthly.updated-May2019.nc';

%  ncdisp(ncfile);
%  Read the datas of rivers from Dai and Trenberth Global River Flow and Continental Discharg

Itime = ncread(ncfile,'time');
lon_sta = ncread(ncfile,'lon');
lat_sta = ncread(ncfile,'lat');
lon_mou = ncread(ncfile,'lon_mou');
lat_mou = ncread(ncfile,'lat_mou');
riv_name = ncread(ncfile,'riv_name');
vol_stn = ncread(ncfile,'vol_stn');%  units : km3/yr

% Find the rivers in the model area. 
is = find(lon_mou>=min(Mobj.lon) & lon_mou<=max(Mobj.lon) & ...
    lat_mou>=min(Mobj.lat) & lat_mou<=max(Mobj.lat));

%  Please confirm the rivers you need.
%  is(1) : Cho-Shui 
%  is(7) : Tan-Shui

%  flux
flux1 = vol_stn(is(1));flux2 = vol_stn(is(3));flux3 = vol_stn(is(7));
flux_taiwan = [flux1,flux2,flux3];
flux_tw = flux_taiwan.*10^9;
flux_sec = flux_tw./(365*24*3600);

%  salt

%  temp

%  ----------------------------------------------------------------------------------------------------------
%  ----------------------------------------------------------------------------------------------------------
%%
%  -----------------------------------------------Fujian----------------------------------------------------
%  ----------------------------------------------------------------------------------------------------------
%  1.volume of runoff
%  time : 2021/4 5 6 7 8 9 10 11 12
%  2022/ 1 2 3 4 
%  monthly average volume of runoff.
%  ---------------------------------------------Calculate runoff-------------------------------------------

mingjiang = [57.23,156.33,229.91,271.34,296.8,323.36,335.29,350.49,364.34,15.03,54.73,93.68,143.66];
jingjiang = [4.2,6.44,10.195,12.18,20.525,22.56,24.45,25.85,27.45,1.10,3.75,6.34,7.86];
jiulongjiang1 = [1.83,2.87,5.275,6.82,12.15,14.02,15.15,15.91,16.58,0.47,2.15,4.11,5.53];
jiulongjiang2 = [5.04,8.23,12.055,14.54,19.24,21.38,22.99,24.4,25.97,1.36,5.97,11.43,15.63];
tingjiang = [3.87,7.59,11.28,13.04,14.64,15.57,16.46,17.59,18.39,0.76,3.87,6.91,9.26];
jiaoxi = [2.73,10.42,16.73,19.41,26.06,28.18,31.46,33.37,34.29,0.84,4.20,7.87,11.58];
mulanxi = [0.44,1.22,2.315,2.75,5.72,6.67,7.18,7.51,7.78,0.27,0.95,1.49,2.04];

for i =1:12
    if i == 9
        mingjiang_flx(i) = mingjiang(i +1);  
        jingjiang_flx(i) = jingjiang(i +1);  
        jiulongjiang1_flx(i) = jiulongjiang1(i +1);  
        jiulongjiang2_flx(i) = jiulongjiang2(i +1); 
        tingjiang_flx(i) = tingjiang(i +1);  
        jiaoxi_flx(i) = jiaoxi(i +1);  
        mulanxi_flx(i) = mulanxi(i +1);  
    else 
        mingjiang_flx(i) = mingjiang(i+1) - mingjiang(i); 
        jingjiang_flx(i) = jingjiang(i+1) - jingjiang(i); 
        jiulongjiang1_flx(i) = jiulongjiang1(i+1) - jiulongjiang1(i); 
        jiulongjiang2_flx(i) = jiulongjiang2(i+1) - jiulongjiang2(i); 
        tingjiang_flx(i) = tingjiang(i+1) - tingjiang(i); 
        jiaoxi_flx(i) = jiaoxi(i+1) - jiaoxi(i); 
        mulanxi_flx(i) = mulanxi(i+1) - mulanxi(i); 
    end  
end 

%time : 2021/5 6 7 8 9 10 11 12 2022/1 2 3 4
day = [31,30,31,31,30,31,30,31,31,28,31,30];
for i = 1:length(day)
    sec(i) = day(i)*24*3600;
end

% flux m3/s
mingjiang_flx = mingjiang_flx*10^8./sec;
jingjiang_flx = jingjiang_flx*10^8./sec;
jiulongjiang1_flx = jiulongjiang1_flx*10^8./sec;
jiulongjiang2_flx = jiulongjiang2_flx*10^8./sec;
jiulongjiang_flx = jiulongjiang1_flx + jiulongjiang2_flx;
tingjiang_flx = tingjiang_flx*10^8./sec;
jiaoxi_flx = jiaoxi_flx*10^8./sec;
mulanxi_flx =  mulanxi_flx*10^8./sec;

%  -----------------------------------------End calculate runoff-------------------------------------------
%  salt


%  temp



%%
%  ----------------------------------------------data merge----------------------------------------------------
%  RiverName
RiverName = {'mingjiang','jingjiang','jiulongjiang','jiaoxi','mulanxi','ChoShui','TanShui'};

%------------------------------------------------------
%  time
time = [];
year = 2021;month = 5;day = 1;month1 = 1;
time(1) = datenum(year,month,day,6,00, 00);
month = month+1;
for i = 2:8
    time(i) = datenum(year,month,day,00,00, 00);
    month = month+1;
end
for i = 9:12
    time(i) = datenum(year,month1,day,00,00, 00);
    month1 = month1+1;
end

time(13) = datenum(2022,5,1,00,00, 00);
% time0 = datenum(year, month, day, hour, 0, 0);

%------------------------------------------------------------
%Location of river mouth
mingjiang_nodes = 10807;
jingjiang_nodes = 7226;
jiulongjiang_nodes = 5369;
jiaoxi_nodes = 5730;
mulanxi_nodes =  10776;
ChoShui_nodes = 1851;
TanShui_nodes = 353;

Mobj.river_nodes = [mingjiang_nodes;jingjiang_nodes;...
    jiulongjiang_nodes;jiaoxi_nodes;mulanxi_nodes;ChoShui_nodes;TanShui_nodes];

%------------------------------------------------------------
%  flux
chaoshui_flx(1:12) = [flux_sec(1)];
tanshui_flx(1:12) = [flux_sec(3)];
flux = [mingjiang_flx;jingjiang_flx;jiulongjiang_flx;jiaoxi_flx;mulanxi_flx;chaoshui_flx;tanshui_flx];

%  salt

salt = zeros(7,13);
salt(:) = 10;
salt(1,:) = 20;

%  temp
temp = zeros(7,13);




%%
% write nc file
Flux = flux;
for i = 1:7
    Flux(i,13) = Flux(i,12);
end


write_river('Taihai_riv.nc', RiverName, 'Time',time,'Flux',Flux,'Salinity',salt);

Mobj.river_names = RiverName;

write_FVCOM_river_nml(Mobj, './RIVERS_NAMELIST.nml', 'Taihai_riv.nc', 'uniform');
