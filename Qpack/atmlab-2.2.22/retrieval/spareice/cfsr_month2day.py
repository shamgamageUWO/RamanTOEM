#!/usr/bin/env python

"""Convert NCEP CFSR to nicer (smaller) files

"""

# $Id: cfsr_month2day.py 8862 2013-10-21 20:39:50Z gerrit $

import gzip
import bz2
import tempfile

import os
import os.path
from datetime import datetime
now = datetime.now

import numpy
import netCDF4

indir = "/storage3/user_data/gerrit/reanalysis/"
infile = "tmpsfc.cdas1.2013{:02d}.grb2.nc.bz2"
outdir = ("/storage3/user_data/gerrit/reanalysis_per_day/"
          "{year:04d}/{month:02d}/{day:02d}")
outfile = "{var}.nc"

def split_cfsr_by_day(fn, varname):
    with tempfile.NamedTemporaryFile() as ncfile_big:
        print(now(), "Unpacking", fn, "to", ncfile_big.name)
        if fn.endswith(".gz"):
            opener = gzip.GzipFile
        elif fn.endswith(".bz2"):
            opener = bz2.BZ2File
        else:
            raise RuntimeError("Don't know how to open %s" % fn)

        with opener(filename=fn, mode='r') as zfile:
            ncfile_big.write(zfile.read())
        print(now(), "Opening", ncfile_big)
        with netCDF4.Dataset(ncfile_big.name) as nc_big:
            tm = nc_big.variables["time"]
            vdt = nc_big.variables["valid_date_time"]
            tm_cp = tm[:]
            inds = numpy.r_[0, numpy.diff(tm[:] // 24).nonzero()[0]+1]
            for i in range(len(inds)-1):
                st = inds[i]
                end = inds[i+1]

                dt_obj = datetime.strptime(
                    vdt[st, :].tostring().decode('ascii'), "%Y%m%d%H")
                ncfile_small = os.path.join(
                    outdir.format(year=dt_obj.year, month=dt_obj.month,
                                  day=dt_obj.day),
                    outfile.format(var=varname))
                print(now(), "Creating", ncfile_small)
                os.makedirs(os.path.dirname(ncfile_small),
                    exist_ok=True)
                with netCDF4.Dataset(ncfile_small, format='NETCDF4',
                                     mode='w', clobber=True) as nc_small:

                    # copy global attributes
                    nc_small.setncatts({k: nc_big.getncattr(k)
                                        for k in nc_big.ncattrs()})

                    # copy all dimensions except time
                    for d in set(nc_big.dimensions.keys()) - set(['time']):
                        nc_small.createDimension(
                            d, len(nc_big.dimensions[d]))
                
                    # define time
                    nc_small.createDimension("time", end-st)

                    # create variables with dimensions
                    for k in nc_big.variables.keys():
                        print(now(), "Writing", k)
                        dims = nc_big.variables[k].dimensions

                        nc_small.createVariable(varname=k,
                            datatype=nc_big.variables[k].dtype,
                            dimensions=dims,
                            fill_value=getattr(nc_big.variables[k],
                                               "_FillValue", None),
                            zlib=True)

                        # copy attributes
                        for attr in nc_big.variables[k].ncattrs():
                            if attr.startswith("_"): # special case
                                continue
                            setattr(nc_small.variables[k], attr, getattr(nc_big.variables[k], attr))

                        # copy data
                        slicing = [slice(None)] * len(dims)
                        if "time" in dims:
                            slicing[dims.index("time")] = slice(st, end, 1)
                        nc_small.variables[k][...] = nc_big.variables[k][slicing]

def main():
    for i in range(1, 13):
        split_cfsr_by_day(
            os.path.join(indir, infile).format(i), "T_surf")

if __name__ == "__main__":
    main()
