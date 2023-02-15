%  This  program is used to do FVCOM heat flux input.
%  Zhonghao Lin , NUIST
%  2023/2/9
%  linthonghao761@163.com
%%
clc;clear all;

addpath './toolboxs'

Mobj = read_sms_mesh('2dm','./input/fin8.2dm','coordinate' ,'spherical');

%%
%-----------------------------------------------------
%Firstly -------> heat forcing


Cfsr.time = [ 20210501 : 20210531, 20210601 : 20210630, 20210701 : 20210731, ...
   20210801 : 20210831, 20210901 : 20210930, 20211001 : 20211031, 20211101 : 20211130, ...
   20211201 : 20211231,  20220101 : 20220131, 20220201 : 20220228, 20220301 : 20220331, ...
   20220401 : 20220429];

Cfsr.lon =ncread( ['./heat_data/cdas1.',num2str(Cfsr.time(1)),'.sfluxgrbf.grb2.nc'],'lon');
Cfsr.lat =ncread( ['./heat_data/cdas1.',num2str(Cfsr.time(1)),'.sfluxgrbf.grb2.nc'],'lat');
Cfsr.truetime = ncread( ['./heat_data/cdas1.',num2str(Cfsr.time(1)),'.sfluxgrbf.grb2.nc'],'time');
Cfsr.timestep = ncread( ['./heat_data/cdas1.',num2str(Cfsr.time(1)),'.sfluxgrbf.grb2.nc'],'forecast_hour');

timestep=Cfsr.timestep(1);

a=1;
k=1;

for i = 1 : length(Cfsr.time)  
        dswrf=ncread( ['./heat_data/cdas1.',num2str(Cfsr.time(i)),'.sfluxgrbf.grb2.nc'],'DSWRF_L1');                                                  %           west
        dlwrf=ncread( ['./heat_data/cdas1.',num2str(Cfsr.time(i)),'.sfluxgrbf.grb2.nc'],'DLWRF_L1');%Dimensions of NCEP data is  %north            south
        lhtfl = ncread( ['./heat_data1/cdas1.',num2str(Cfsr.time(i)),'.sfluxgrbf.grb2.nc'],'LHTFL_L1');
        shtfl = ncread( ['./heat_data1/cdas1.',num2str(Cfsr.time(i)),'.sfluxgrbf.grb2.nc'],'SHTFL_L1');
        uswrf = ncread( ['./heat_data1/cdas1.',num2str(Cfsr.time(i)),'.sfluxgrbf.grb2.nc'],'USWRF_L1');
        ulwrf = ncread( ['./heat_data1/cdas1.',num2str(Cfsr.time(i)),'.sfluxgrbf.grb2.nc'],'ULWRF_L1');
    for j=1:length(Cfsr.truetime)                                                       %         west                                                                              %           east
        dswrf(:,:,j) = fliplr(dswrf(:,:,j));dlwrf(:,:,j)= fliplr(dlwrf(:,:,j));%south          north
        lhtfl(:,:,j) = fliplr(lhtfl(:,:,j));shtfl(:,:,j)= fliplr(shtfl(:,:,j));%          east       
        uswrf(:,:,j) = fliplr(uswrf(:,:,j));ulwrf(:,:,j)= fliplr(ulwrf(:,:,j));
                                                                                                                                                                %        north                                       
        Cfsr.dswrf.data(:,:,i*4-4+j)=rot90(dswrf(:,:,j),1);Cfsr.dlwrf.data(:,:,i*4-4+j)=rot90(dlwrf(:,:,j),1);%west          east
        Cfsr.lhtfl.data(:,:,i*4-4+j)=rot90(lhtfl(:,:,j),1);Cfsr.shtfl.data(:,:,i*4-4+j)=rot90(shtfl(:,:,j),1);%       south 
        Cfsr.uswrf.data(:,:,i*4-4+j)=rot90(uswrf(:,:,j),1);Cfsr.ulwrf.data(:,:,i*4-4+j)=rot90(ulwrf(:,:,j),1);
    end
    a=a+1;
    if a > 4
        k=k+1;
        a=1;
    end
end

    vars = {'nswrs', 'nlwrs'};
    up = {'uswrf', 'ulwrf'};
    down = {'dswrf', 'dlwrf'};
%%




for i = 1:length(vars)
    
    Cfsr.(vars{i}).data = Cfsr.(down{i}).data - Cfsr.(up{i}).data;
    
end
    









%%
heat_i.domain_cols = length(Cfsr.lon);
heat_i.domain_rows = length(Cfsr.lat);

[heat_i.lon, heat_i.lat] = meshgrid(Cfsr.lon, Cfsr.lat);
[heat_i.x, heat_i.y] = wgs2utm(heat_i.lat, heat_i.lon, 50, 'N');

heat_i.x = reshape(heat_i.x, heat_i.domain_rows, heat_i.domain_cols);
heat_i.y = reshape(heat_i.y, heat_i.domain_rows, heat_i.domain_cols);

% heat_i.dswrf.data = Cfsr.dswrf.data;
% heat_i.dlwrf.data = Cfsr.dlwrf.data;
heat_i.lhtfl.data = Cfsr.lhtfl.data;
heat_i.shtfl.data = Cfsr.shtfl.data;
heat_i.nswrs.data = Cfsr.uswrf.data;
heat_i.nlwrs.data = Cfsr.ulwrf.data;
%%
[Mobj.x,Mobj.y,utmzone2,utmhemi2] = wgs2utm(Mobj.lat,Mobj.lon,50,'N');


modelYear=2021;         %-----|
month=05;day=01;hour=06;%-----|
timestep = 6;tt = length(Cfsr.dswrf.data(1,1,:));

Cfsr.juliantime = changetime(modelYear,month,day,hour,timestep,tt);

[sYr, sMon, sDay, sHr, sMin, sSec] = mjulian2greg(Cfsr.juliantime(1))
[sYr, sMon, sDay, sHr, sMin, sSec] = mjulian2greg(Cfsr.juliantime(end))%check
%%
interpfields = {'nswrs', 'nlwrs','lhtfl','shtfl'};


heat_i.time = Cfsr.juliantime;

heat_i.x=double(heat_i.x);heat_i.y=double(heat_i.y);
% double(heat_i.lhtfl.data);double(heat_i.lhtfl.data);double(heat_i.shtfl.data);double(heat_i.shtfl.data);
% double(heat_i.nswrs.data);double(heat_i.nswrs.data);double(heat_i.nlwrs.data);double(heat_i.nlwrs.data);

nt = length(heat_i.time);
%%
kk = 1;
for it = 1 : nt
    disp(['Interpolating the ' num2str(it) 'th time of ' num2str(nt)])
    if sum(heat_i.nswrs.data(:,:,it) ==0)
        disp(['Wait ...'])
        disp(['Sorry for the ' num2str(it) 'th time nswrs data is all zero'])
        continue
    elseif sum(heat_i.nlwrs.data(:,:,it) ==0)
        disp(['Wait ...'])
        disp(['Sorry for the ' num2str(it) 'th time nlwrs data is all zero'])
        continue
    elseif sum(heat_i.lhtfl.data(:,:,it) ==0)
        disp(['Wait ...'])
        disp(['Sorry for the ' num2str(it) 'th time lhtfl data is all zero'])
        continue        
    elseif sum(heat_i.shtfl.data(:,:,it) ==0)
        disp(['Wait ...'])
        disp(['Sorry for the ' num2str(it) 'th time shtfl data is all zero'])
        continue    
    else
        % nswrs 
        knswrs = (heat_i.nswrs.data(:,:,it) ~= 0);
        nswrs.data = heat_i.nswrs.data(:,:,it);
        Ft = scatteredInterpolant(heat_i.x(knswrs), heat_i.y(knswrs), nswrs.data(knswrs),  'linear', 'nearest');
        heat_inter.nswrs.node(:,kk) = Ft(Mobj.x, Mobj.y);
        
        % nlwrs 
        knlwrs = (heat_i.nlwrs.data(:,:,it) ~= 0);
        nlwrs.data = heat_i.nlwrs.data(:,:,it);
        Ft = scatteredInterpolant(heat_i.x(knlwrs), heat_i.y(knlwrs), nlwrs.data(knlwrs),  'linear', 'nearest');
        heat_inter.nlwrs.node(:,kk) = Ft(Mobj.x, Mobj.y);
%         
        % lhtfl
        klhtfl = (heat_i.lhtfl.data(:,:,it) ~= 0);
        lhtfl_data = heat_i.lhtfl.data(:,:,it);
        Ft = scatteredInterpolant(heat_i.x(klhtfl), heat_i.y(klhtfl), lhtfl_data(klhtfl),  'linear', 'nearest');   
        heat_inter.lhtfl.node(:,kk) = Ft(Mobj.x, Mobj.y);
%         
        
        % shtfl
        kshtfl = (heat_i.shtfl.data(:,:,it)~=0);
        shtfl_data = heat_i.shtfl.data(:,:,it);
        Ft = scatteredInterpolant(heat_i.x(kshtfl), heat_i.y(kshtfl), shtfl_data(kshtfl),  'linear', 'nearest');   
        heat_inter.shtfl.node(:,kk) = Ft(Mobj.x, Mobj.y);
        %-------------------------------------------------------------
    
        heat_inter.time(kk) = heat_i.time(it);
        kk = kk+1;
    end
end
%%

write_FVCOM_forcing(Mobj,'ncep', heat_inter, ...
                'hfx', ...
                '5.0');