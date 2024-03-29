%==========================================================================
% Write FVCOM TS initial NetCDF file
% 
% Input  : --- fini, initial ts file path and name
%          --- zsl, depths, (negative for ocean in the output)
%          --- tsl, temperature, degree C
%          --- ssl, salinity, psu
%          --- time0, time in MATLAB datenum format
%
% Output : \
% 
% Usage  : write_initial_ts(fini, zsl, tsl, ssl, datenum(2012, 10, 18, 0, 0, 0]));
%
% v1.0
%
% Siqi Li
% 2021-04-21
%
% Updates:
%
%==========================================================================
function write_initial_ts(fini, zsl, tsl, ssl,Nitrogen,p,z,time0)

ksl = length(zsl);

if ksl~=length(zsl(:))
    error('Wrong size of input zsl.')
end

dims1 = size(tsl);
dims2 = size(ssl);
if length(dims1)~=2
    error('Input tsl and ssl should be in size of [node, ksl]')
end
if dims1(1)~=dims2(1) || dims1(2)~=dims2(2)
    error('Inputs tsl and ssl should be in the same size.')
end

node = dims1(1);
if dims1(2)~=ksl
    error('The 2nd dimension of input tsl should be ksl.')
end

% Generate the four time variables
[time, Itime, Itime2, Times] = convert_fvcom_time(time0);
% mjd_ref=datenum(1858,11,17,0,0,0); 
% time = datenum(time0) - mjd_ref;
% Times = datestr(time0, 'yyyy-mm-ddTHH:MM:SS.000000');
% Itime = floor(time);
% Itime2 = (time-Itime) * 24 * 3600 * 1000;

% create the output file.
ncid=netcdf.create(fini, 'CLOBBER');

%define the dimension
node_dimid=netcdf.defDim(ncid, 'node', node);
time_dimid=netcdf.defDim(ncid,'time',netcdf.getConstant('NC_UNLIMITED'));
DateStrLen_dimid=netcdf.defDim(ncid,'DateStrLen',26);
ksl_dimid=netcdf.defDim(ncid, 'ksl', ksl);

%define variables
% time
time_varid = netcdf.defVar(ncid,'time','float',time_dimid);
netcdf.putAtt(ncid, time_varid, 'long_name','time');
netcdf.putAtt(ncid, time_varid, 'unit','days since 1858-11-17 00:00:00');
netcdf.putAtt(ncid, time_varid, 'format','modified julian dat (MJD)');
netcdf.putAtt(ncid, time_varid, 'time_zone','UTC');
% Itime
Itime_varid = netcdf.defVar(ncid, 'Itime','int',time_dimid);
netcdf.putAtt(ncid,Itime_varid, 'unit','days since 1858-11-17 00:00:00');
netcdf.putAtt(ncid,Itime_varid, 'format','modified julian dat (MJD)');
netcdf.putAtt(ncid,Itime_varid, 'time_zone','UTC');
% Itime2
Itime2_varid = netcdf.defVar(ncid, 'Itime2','int',time_dimid);
netcdf.putAtt(ncid,Itime2_varid, 'unit','mses since 1858-11-17 00:00:00');
netcdf.putAtt(ncid,Itime2_varid, 'format','modified julian dat (MJD)');
netcdf.putAtt(ncid,Itime2_varid, 'time_zone','UTC');
% Times
Times_varid = netcdf.defVar(ncid, 'Times','char',[DateStrLen_dimid time_dimid]);
netcdf.putAtt(ncid,Times_varid, 'time_zone','UTC');
% zsl
zsl_varid = netcdf.defVar(ncid, 'zsl', 'float', ksl_dimid);
netcdf.putAtt(ncid,zsl_varid, 'long_name', 'Standard Depths');
netcdf.putAtt(ncid,zsl_varid, 'unit', 'meter');
% tsl
tsl_varid = netcdf.defVar(ncid, 'tsl','float',[node_dimid ksl_dimid time_dimid]);
netcdf.putAtt(ncid,tsl_varid, 'long_name','Temperature');
% ssl
ssl_varid = netcdf.defVar(ncid, 'ssl','float',[node_dimid ksl_dimid time_dimid]);
netcdf.putAtt(ncid,ssl_varid, 'long_name','Salinity');

nsl_varid = netcdf.defVar(ncid, 'Nitrogen','float',[node_dimid ksl_dimid time_dimid]);
netcdf.putAtt(ncid,nsl_varid, 'long_name','Nitrogen');
netcdf.putAtt(ncid, nsl_varid, 'units', 'mmole N m-3');

psl_varid = netcdf.defVar(ncid, 'Phytoplankton','float',[node_dimid ksl_dimid time_dimid]);
netcdf.putAtt(ncid,psl_varid, 'long_name','Phytoplankton');
netcdf.putAtt(ncid, psl_varid, 'units', 'mmole C m-3');

zzsl_varid = netcdf.defVar(ncid, 'Zooplankton','float',[node_dimid ksl_dimid time_dimid]);
netcdf.putAtt(ncid,zzsl_varid, 'long_name','Zooplankton');
netcdf.putAtt(ncid, zzsl_varid, 'units', 'mmole C m-3');
%end define mode
netcdf.endDef(ncid);

%put data in the output file
netcdf.putVar(ncid,zsl_varid, zsl);
for i=1:1
    
    netcdf.putVar(ncid, time_varid, i-1, 1, time(i));
    netcdf.putVar(ncid, Itime_varid, i-1, 1, Itime(i));
    netcdf.putVar(ncid, Itime2_varid, i-1, 1, Itime2(i));
    netcdf.putVar(ncid, Times_varid, [0 i-1], [26 1], Times(i,:));
    netcdf.putVar(ncid, tsl_varid, [0 0 i-1], [node ksl 1], tsl);
    netcdf.putVar(ncid, ssl_varid, [0 0 i-1], [node ksl 1], ssl);
    netcdf.putVar(ncid, nsl_varid, [0 0 i-1], [node ksl 1], Nitrogen);
    netcdf.putVar(ncid, psl_varid, [0 0 i-1], [node ksl 1], p);
    netcdf.putVar(ncid, zzsl_varid, [0 0 i-1], [node ksl 1], z);
end

% close NC file
netcdf.close(ncid)
