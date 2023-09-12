import numpy as np
import xarray as xr
import glob
import sys
from datetime import date
import os

sim=sys.argv[1]
pft=sys.argv[2]

d0='/glade/scratch/djk2120/archive/TRENDY2023_f09_{}/lnd/hist/' #sim will replace {}
dout='/glade/campaign/cgd/tss/projects/TRENDY/v12/S0/lnd/proc/trendy/'
logs='/glade/scratch/djk2120/logs/'
dvs=['GPP','NPP','AGNPP','TOTVEGC','TLAI',
     'FSH','TV','FCTR','FGEV','pfts1d_wtgcell']


tvars={'GPP':'gpp',
       'NPP':'npp',
       'AGNPP':'agnpp',
       'TOTVEGC':'cVeg',
       'TLAI':'lai',
       'FSH':'shflx',
       'TV':'tskin',
       'FCTR':'trans',
       'FGEV':'evapo',
       'pfts1d_wtgcell':'landCoverFrac'}

tunits={'gpp':'kg m-2 s-1',
        'npp':'kg m-2 s-1',
        'agnpp':'kg m-2 s-1',
        'cVeg':'kg m-2',
        'lai':'-',
        'shflx':'W m-2',
        'tskin':'K',
        'trans':'W m-2',
        'evapo':'W m-2'}

tlongs={'gpp':'Gross Primary Production',
        'npp':'Net Primary Production',
        'agnpp':'Aboveground Net Primary Production',
        'lai':'Leaf Area Index',
        'shflx':'Sensible Heat Flux',
        'tskin':'Skin Temperature',
        'cVeg':'Carbon in Vegetation',
        'trans':'Transpiration',
        'evapo':'Soil Evaporation',
        'landCoverFrac':'Fractional Land Cover'}

cfs={'gC/m^2/s':{'kg m-2 s-1':1/1000},
     'gC/m^2':{'kg m-2':1/1000},
     'W/m^2':{'W m-2':1.},
     'm^2/m^2':{'-':1.}}

def pp(ds):
    return ds[dvs]
    

#read parameter names
p=xr.open_dataset('/glade/p/cesmdata/cseg/inputdata/lnd/clm2/paramdata/clm5_params.c190529.nc')
pftnames=xr.DataArray([str(p)[2:-1].strip() for p in p.pftname.values],dims='PFT')

#instantiate some useful variables
d=d0.format(sim)
tape='h1'
xs={dv:[] for dv in dvs}
f=sorted(glob.glob(d+'*.'+tape+'*.nc'))[0]
ds=xr.open_dataset(f)
nlat=len(ds.lat)
nlon=len(ds.lon)
nt=12
nan=xr.DataArray(np.zeros([nlat,nlon,1,nt])+np.nan,dims=['lat','lon','PFT','time'])
nan['lat']=ds.lat
nan['lon']=ds.lon
nan['PFT']=[pft]

yrs=np.unique([f.split('.')[-2][:4] for f in sorted(glob.glob(d+'*'+tape+'*'))]).astype(int)
#loop by year to manage memory
for yr in yrs:
    if yr%10==0:
        os.system('touch '+logs+'PFT'+str(pft).zfill(2)+'.'+str(yr)+'.log')

    #find the files
    files=sorted(glob.glob(d+'*.'+tape+'.'+str(yr)+'*.nc'))

    #load into dataset
    ds=xr.open_mfdataset(files,combine='by_coords',preprocess=pp)
    yr0=ds['time.year'][0].values
    ds['time']=xr.cftime_range(str(yr0),periods=len(ds.time),freq='MS',calendar='noleap')
    singles=['lat','lon','pfts1d_itype_veg','pfts1d_ixy','pfts1d_jxy','landfrac']
    tmp=xr.open_dataset(files[0])
    for s in singles:
        ds[s]=tmp[s]
        
    #regrid
    for v in dvs:
        ixpft=ds.pfts1d_itype_veg==pft
        ixy=ds.pfts1d_ixy.isel(pft=ixpft)
        jxy=ds.pfts1d_jxy.isel(pft=ixpft)
        x=nan.copy(deep=True).stack({'gridcell':['lat','lon']}) #flatten output array    
        x[0,:,jxy*nlon+ixy]=ds[v].isel(pft=ixpft)                 #copy from input
        x['time']=ds.time                                       #assign time dimension
        xs[v].append(x.unstack())                               #unflatten output and save

#write to netcdf, with appropriate attributes     
for v in dvs:
    tv=tvars[v]
    if 'units' in ds[v].attrs:
        u=ds[v].attrs['units']
        tu=tunits[tv]
        if u==tu:
            cf=1.
        else:
            cf=cfs[u][tu]
    else:
        u='-'
        tu='-'
        cf=1.

    xt=cf*xr.concat(xs[v],dim='time')
    xt.attrs={'long_name':'Vegtype level '+tlongs[tv],
              'units':tu,
              'orig_clm_var':v,
              'orig_clm_units':u,
              'conversion':cf}

    out=xr.Dataset()
    if tv=='landCoverFrac': #special case
        out[tv]=(ds.landfrac*xt).transpose('lat','lon','time','PFT')
        out[tv].attrs=xt.attrs
        out[tv].attrs['orig_clm_var']='landfrac * pfts1d_wtgcell'
        fout=dout+'CLM5.0_'+sim+'_'+tv+'_PFT'+str(pft).zfill(2)+'.nc'
    else:
        out[tv+'pft']=xt.transpose('lat','lon','time','PFT')
        fout=dout+'CLM5.0_'+sim+'_'+tv+'pft_PFT'+str(pft).zfill(2)+'.nc'
        
    out['pftname']=xr.DataArray([pftnames[pft].values],dims='PFT')
    out.attrs={'date_written':str(date.today()),
               'script':'/glade/u/home/djk2120/ctsm_trendy_2023/postp/pftgrid.py'}

    out.to_netcdf(fout,unlimited_dims='PFT')
