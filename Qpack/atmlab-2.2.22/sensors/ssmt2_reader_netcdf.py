#! /usr/bin/python

# Written by James @ MetOffice, pending permission to publish

import string,xdrlib,os,sys,re
import numpy as np
import netCDF4 as nc

#np.set_printoptions(precision=15)

if len(sys.argv) < 3:
	print "Usage: read_test.py [input file name] [output file name]"
	sys.exit(1)

f_in=sys.argv[1]

pattern="\S+.T2"
compiled=re.compile(pattern)

if not re.search(pattern,f_in):	
	print "Input data file not *.T2"
	sys.exit(1)

# Read data file in
		
f=open(f_in,"rb")
data=f.read()

# Find end of header and extract header
		
for i in range(len(data)):
	if i == 0: pass
	if data[i] == " " and data[i+1] == " " and data[i-1] == " ":
		head_end = i-2
		break
	if i == (len(data)-1):
		print "No header found, quitting"
		sys.exit(1)

hdr=string.split(data[0:head_end],"\n")

if len(hdr) == 0:
	print "Header is empty, quitting"
	sys.exit(1)


# Set key header variables

try:
    nhdr=int(string.split([s for s in hdr if "number of header records" in s][0],": ")[1])
    nbytes=int(string.split([s for s in hdr if "record bytes" in s][0],": ")[1])
    if "number of data records" in s:
        ndata=int(string.split([s for s in hdr if "number of data records" in s][0],": ")[1])
    else:
        nrec=int([s for s in hdr if "number of records" in s][0].split(":")[1].strip())
        ndata = nrec - nhdr
        print >>sys.stderr, ("Warning: "
            "didn't find number of data records directly.\n"
            "Using number of records - number of header records ({} - {}) "
            "instead").format(nrec, nhdr)
except IndexError:
    print >>sys.stderr, "Failed to determine record sizes from header, exiting"
    sys.exit(1)

nrec=nhdr+ndata
fsize=nrec*nbytes
data_start=nhdr*nbytes

# Set up unpacker

p=xdrlib.Unpacker
x=p(data[data_start:])

# Create arrays to store data

ancil_arr=np.zeros((ndata,10),dtype=np.float64)
tb_arr=np.zeros((ndata,28,5),dtype=np.float32)
lon_arr=np.zeros((ndata,28),dtype=np.float32)
lat_arr=np.zeros((ndata,28),dtype=np.float32)
qflag_arr=np.zeros((ndata,28,5),dtype=np.float32)
gain_ctrl_arr=np.zeros((ndata,5),dtype=np.float32)
gain_arr=np.zeros((ndata,5),dtype=np.float32)
offset_arr=np.zeros((ndata,5),dtype=np.float32)
thermal_ref_arr=np.zeros((ndata,),dtype=np.float32)
temps_arr=np.zeros((ndata,18),dtype=np.float32)
warm_counts_arr=np.zeros((ndata,5,4),dtype=np.float32)
cold_counts_arr=np.zeros((ndata,5,4),dtype=np.float32)

# Create netCDF, add header into description and create dimensions/variables.

net_out = nc.Dataset(sys.argv[2], 'w', format='NETCDF4')

## Edit GH 2013-01-16: set global attributes in a nicer way
for (k, v) in ([x.strip(' :') for x in f.split(':', 1)]
                    for f in hdr if ':' in f):
    k = k.replace(' ', '_').replace('/', '_')
    setattr(net_out, k, v)

#net_out.description = string.join(hdr)

net_out.createDimension('time_step', ndata)
net_out.createDimension('scan_position', 28)
net_out.createDimension('channel', 5)
net_out.createDimension('housekeeping', 18)
net_out.createDimension('calib_number', 4)
net_out.createDimension('ancil_data:Year_DayofYear_SecondsofDay_SatLat_SatLong_SatAlt_SatHeading_Year_DayofYear_SecondsofDay', 10)

ancil=net_out.createVariable('ancil_data','f8',('time_step','ancil_data:Year_DayofYear_SecondsofDay_SatLat_SatLong_SatAlt_SatHeading_Year_DayofYear_SecondsofDay'))
tb=net_out.createVariable('tb','f4',('time_step','scan_position','channel'))
lon=net_out.createVariable('lon','f4',('time_step','scan_position'))
lat=net_out.createVariable('lat','f4',('time_step','scan_position'))
qflag=net_out.createVariable('channel_quality_flag','f4',('time_step','scan_position','channel'))
gain_ctrl=net_out.createVariable('gain_control','f4',('time_step','channel'))
gain=net_out.createVariable('counts_to_tb_gain','f4',('time_step','channel'))
offset=net_out.createVariable('counts_to_tb_offset','f4',('time_step','channel'))
thermal_ref=net_out.createVariable('thermal_reference','f4',('time_step'))
temps=net_out.createVariable('Temperature_misc_housekeeping','f4',('time_step','housekeeping'))
warm_counts=net_out.createVariable('warm_counts','f4',('time_step','channel','calib_number'))
cold_counts=net_out.createVariable('cold_counts','f4',('time_step','channel','calib_number'))

# Read data into arrays

ii=0
while x.get_position() != (nrec-nhdr)*1688:
	ancil_arr[ii,:]=x.unpack_farray(2,x.unpack_int)+x.unpack_farray(1,x.unpack_double)+x.unpack_farray(4,x.unpack_float)+x.unpack_farray(2,x.unpack_int)+x.unpack_farray(1,x.unpack_double)
	lat_arr[ii,:]=x.unpack_farray(28,x.unpack_float)
	lon_arr[ii,:]=x.unpack_farray(28,x.unpack_float)
	for jj in range(5):
		tb_arr[ii,:,jj]=x.unpack_farray(28,x.unpack_float)
	for kk in range(5):
		qflag_arr[ii,:,kk]=x.unpack_farray(28,x.unpack_uint)
	gain_ctrl_arr[ii,:]=x.unpack_farray(5,x.unpack_uint)
	gain_arr[ii,:]=x.unpack_farray(5,x.unpack_float)
	offset_arr[ii,:]=x.unpack_farray(5,x.unpack_float)
	thermal_ref_arr[ii]=x.unpack_farray(1,x.unpack_uint)[0]
	temps_arr[ii,:]=x.unpack_farray(18,x.unpack_uint)
	for qq in range(5):
		warm_counts_arr[ii,qq,:]=x.unpack_farray(4,x.unpack_uint)
	for zz in range(5):
		cold_counts_arr[ii,zz,:]=x.unpack_farray(4,x.unpack_uint)
	ii+=1

# Arrays into netCDF variables. Looks strange, but it is faster (as far as I can tell) to 
# unpack data into array then set NC variables equal to the data in the array than
# unpack straight to NC variable.
	
ancil[:]=ancil_arr
tb[:]=tb_arr
lon[:]=lon_arr
lat[:]=lat_arr
qflag[:]=qflag_arr
gain_ctrl[:]=gain_ctrl_arr
gain[:]=gain_arr
offset[:]=offset_arr
thermal_ref[:]=thermal_ref_arr
temps[:]=temps_arr
warm_counts[:]=warm_counts_arr
cold_counts[:]=cold_counts_arr

# Close netCDF

net_out.close()



# Unpack sequence, just commented as a reference in case needed.

#print x.unpack_farray(2,x.unpack_int)
#print x.unpack_farray(1,x.unpack_double)
#print x.unpack_farray(4,x.unpack_float)
#print x.unpack_farray(2,x.unpack_int)
#print x.unpack_farray(1,x.unpack_double)
#print x.unpack_farray(196,x.unpack_float)
#print x.unpack_farray(145,x.unpack_uint)
#print x.unpack_farray(10,x.unpack_float)
#print x.unpack_farray(59,x.unpack_uint)
