%  This  program is used to do FVCOM npz nh4 initial files
%  Zhonghao Lin , NUIST
%  2023/2/14
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
%%
nh4_lon = [117.7 118.9 118.9 119.1 119.3 117.7 118.4 120.4 118.3 118.8 118.9 119.1 118.1 118.7 120.0 ]';
nh4_lat = [23.7 23.5 22.5 22.4 22.1 22.8 22.1 25.6 23.5 24.8 24.7 24.6 24.4 23.9 25.2 ]';

%%
nh4_i = [0.086514523,
2.706016598,
1.129875519,
0.330705394,
2.595020747,
0.042116183,
7.745228216,
0.930082988,
1.884647303,
0.841286307,
1.684854772,
0.175311203,
1.862448133,
0.552697095,
1.085477178,
];  % umol/L

% nh4_i = nh4_i';

%%


f = f_load_grid(Mobj.lon, Mobj.lat, Mobj.tri, Mobj.h);

Ft = scatteredInterpolant(nh4_lon, nh4_lat, nh4_i, 'linear', 'nearest');

nh4 = Ft(f.x, f.y);

%%
fid=fopen('NUTRIENT_INI_1.dat','w');
fprintf(fid,'KSL = %g\n',KSL);
fprintf(fid,'DPTHSL = %g\n',depth);
fprintf(fid,'TEMPB = %g');
for i = 1:length(nh4)
        fprintf(fid,'%g\n',nh4(i));
end

fclose(fid);
