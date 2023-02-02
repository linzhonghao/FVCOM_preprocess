%%
% Debugged by Zhonghao Lin.
% linzhonghao761@163.com.
% *.2dm file put in the ./input folder.
% grd.dat dep.dat obc.dat cor.dat in the ./output folder.
clc;clear all;
nobc =91;  % nobc = numbers of OBC. nodes
cartesian = 0 ;  % Mobj.nativeCoords = ['spherical'] else ['cartesian'] =1
Casename = 'Taihai';  % Your FVCOM case name
two_dm = 'fin8'; % Your .2dm file name
utmZone = {'50 U'}; %Your UTM zone (only for cartesian)
%%
global ftbverbose
ftbverbose = true;
addpath('./toolboxs');

if cartesian == 1
   Coords = 'cartesian';
   Mobj.nativeCoords = 'cartesian';
else
    Coords = 'spherical';
end

Mobj = read_sms_mesh('2dm',['.\input\',two_dm,'.2dm'],'coordinate' ,Coords);  % read 2dm file

Mobj = add_obc_nodes_list(Mobj,[1:nobc],'OpenOcean',1,1);  %  figure

if cartesian == 0
Mobj = add_coriolis(Mobj,'uselatitude');  %  The Coriolis force is defined by latitude
write_FVCOM_cor(Mobj,['./output/',Casename,'_cor.dat']);
end

write_FVCOM_grid(Mobj,['./output/',Casename,'_grd.dat']);
write_FVCOM_bath(Mobj,['./output/',Casename,'_dep.dat']);
write_FVCOM_obc(Mobj,['./output/',Casename,'_obc.dat']);



%%

if cartesian == 1

utmZones = cellfun(@(x) repmat(x, length(Mobj.x), 1), utmZone, 'uni', false);
[Mobj.lat, Mobj.lon] = utm2deg(Mobj.x, Mobj.y, utmZones{1});
Mobj.have_lonlat = 1;
[Mobj] = add_coriolis(Mobj,'uselatitude');
write_FVCOM_cor(Mobj,['./output/',Casename,'_cor.dat']);
end


