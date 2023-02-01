%------------------------------------------------------
%  This .m file is used to do wind forcing for FVCOM
%  Writed and debugged by Zhonghao Lin. 2022/11/4
%  e-mail:linzhonghao761@163.com
%  wind forcing datas are from NCEP.
%------------------------------------------------------
clc;clear all;

addpath './toolboxs'

%%
Mobj = read_sms_mesh('2dm','2dm','coordinate' ,'spherical');

%%
%-----------------------------------------------------
%Firstly -------> wind forcing


Cfsr.time = [ 20210501 : 20210531, 20210601 : 20210630, 20210701 : 20210731, ...
   20210801 : 20210831, 20210901 : 20210930, 20211001 : 20211031, 20211101 : 20211130, ...
   20211201 : 20211231,  20220101 : 20220131, 20220201 : 20220228, 20220301 : 20220331, ...
   20220401 : 20220430];

Cfsr.lon =ncread( ['./wnd/cdas1.',num2str(Cfsr.time(1)),'.sfluxgrbf.grb2.nc'],'lon');
Cfsr.lat =ncread( ['./wnd/cdas1.',num2str(Cfsr.time(1)),'.sfluxgrbf.grb2.nc'],'lat');
Cfsr.truetime = ncread( ['./wnd/cdas1.',num2str(Cfsr.time(1)),'.sfluxgrbf.grb2.nc'],'time');
Cfsr.timestep = ncread( ['./wnd/cdas1.',num2str(Cfsr.time(1)),'.sfluxgrbf.grb2.nc'],'forecast_hour');

timestep=Cfsr.timestep(1);

a=1;
k=1;

for i = 1 : length(Cfsr.time)  
        uwnd=ncread( ['./wnd/cdas1.',num2str(Cfsr.time(i)),'.sfluxgrbf.grb2.nc'],'U_GRD_L103');                                                  %           west
        vwnd=ncread( ['./wnd/cdas1.',num2str(Cfsr.time(i)),'.sfluxgrbf.grb2.nc'],'V_GRD_L103');%Dimensions of NCEP data is  %north            south
    for j=1:length(Cfsr.truetime)                                                       %         west                                                                              %           east
        uwnd(:,:,j) = fliplr(uwnd(:,:,j));vwnd(:,:,j)= fliplr(vwnd(:,:,j));%south          north
                                                                                                        %          east
                                                                                                                                                                %        north                                       
        Cfsr.uwnd.data(:,:,i*4-4+j)=rot90(uwnd(:,:,j),1);Cfsr.vwnd.data(:,:,i*4-4+j)=rot90(vwnd(:,:,j),1);%west          east
                                                                                                                                                                 %       south 
    end
    a=a+1;
    if a > 4
        k=k+1;
        a=1;
    end
end

%%

wnd_i.domain_cols = length(Cfsr.lon);
wnd_i.domain_rows = length(Cfsr.lat);

[wnd_i.lon, wnd_i.lat] = meshgrid(Cfsr.lon, Cfsr.lat);
[wnd_i.x, wnd_i.y] = wgs2utm(wnd_i.lat, wnd_i.lon, 50, 'N');

wnd_i.x = reshape(wnd_i.x, wnd_i.domain_rows, wnd_i.domain_cols);
wnd_i.y = reshape(wnd_i.y, wnd_i.domain_rows, wnd_i.domain_cols);

wnd_i.uwnd.data = Cfsr.uwnd.data;
wnd_i.vwnd.data = Cfsr.vwnd.data;
%%
%-----------------------------------------------------
%Convert time format
 
[Mobj.x,Mobj.y,utmzone2,utmhemi2] = wgs2utm(Mobj.lat,Mobj.lon,50,'N');


modelYear=2021;         %-----|
month=05;day=01;hour=06;%-----|
timestep = 6;tt = length(Cfsr.uwnd.data(1,1,:));

Cfsr.juliantime = changetime(modelYear,month,day,hour,timestep,tt);

[sYr, sMon, sDay, sHr, sMin, sSec] = mjulian2greg(Cfsr.juliantime(1))
[sYr, sMon, sDay, sHr, sMin, sSec] = mjulian2greg(Cfsr.juliantime(end))%check
         
%------------------------------------------------------
%Interpolated and written to a file

interpfields = {'uwnd','vwnd'};


wnd_i.time = Cfsr.juliantime;
wnd_inter=grid2fvcom(Mobj, interpfields, wnd_i);
wnd_inter.time = wnd_i.time;


write_FVCOM_forcing(Mobj,'ncep', wnd_inter, ...
                'NCEP atmospheric forcing data', ...
                '5.0');