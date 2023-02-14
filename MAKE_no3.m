%  This  program is used to do FVCOM npz no3 initial files
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
no3_lon = [118.0 
118.0 
118.6 
118.9 
119.1 
117.4 
117.4 
117.7 
119.6 
119.9 
120.1 
120.2 
120.4 
118.3 
118.8 
118.3 
118.5 
119.1 
119.3 
119.8 
120.0 
];
no3_lat = [23.5 
23.5 
22.9 
22.5 
22.4 
23.1 
23.1 
22.8 
25.0 
26.0 
25.8 
25.7 
25.6 
23.5 
24.8 
24.2 
24.1 
24.3 
24.5 
24.9 
25.2 
 ];

%%
no3_i = [3.5497
2.0078
4.1525
0.4579
0.4599
0.546
51.9862
3.5477
3.6739
11.8841
5.1457
11.3635
2.176
13.0296
2.0399
1.6033
2.152
0.1735
0.586
0.4539
0.7002
];  % umol/L



%%


f = f_load_grid(Mobj.lon, Mobj.lat, Mobj.tri, Mobj.h);

Ft = scatteredInterpolant(no3_lon, no3_lat, no3_i, 'linear', 'nearest');

no3 = Ft(f.x, f.y);

%%
fid=fopen('NUTRIENT_INI_2.dat','w');
fprintf(fid,'KSL = %g\n',KSL);
fprintf(fid,'DPTHSL = %g\n',depth);
fprintf(fid,'TEMPB = %g');
for i = 1:length(no3)
        fprintf(fid,'%g\n',no3(i));
end

fclose(fid);