#!/bin/bash
#PBS -N S2_soils
#PBS -q casper
#PBS -l walltime=12:00:00
#PBS -A P93300641
#PBS -j oe
#PBS -k eod
#PBS -l select=1:ncpus=1:mem=30GB

sim='S2'
trendy='/glade/campaign/cgd/tss/projects/TRENDY/v12/'$sim

d0=$trendy'/lnd/proc/tseries/month_1/'
d1=$trendy'/lnd/proc/trendy/'

cd $d1

echo "copying TSOI"
ncrename -D 2 -v TSOI,tsl $d0"TRENDY2023_f09_"$sim".clm2.h0.TSOI.170101-202212.nc" "CLM5.0_"$sim"_tsl.nc"

echo "prepping SOILICE"
ncks -v SOILICE $d0"TRENDY2023_f09_"$sim".clm2.h0.SOILICE.170101-202212.nc" SOILICE.nc
ncrename -v SOILICE,msl SOILICE.nc msl_ice.nc

echo "prepping SOILLIQ"
ncks -v SOILLIQ $d0"TRENDY2023_f09_"$sim".clm2.h0.SOILLIQ.170101-202212.nc" SOILLIQ.nc
ncrename -v SOILLIQ,msl SOILLIQ.nc msl_liq.nc

echo "adding them together"
ncbo --op_typ=+ msl_ice.nc msl_liq.nc msl.nc

echo "grafting msl onto good metadata"
ncks -O -x -v SOILICE $d0"TRENDY2023_f09_"$sim".clm2.h0.SOILICE.170101-202212.nc" tmp.nc
ncks -3 tmp.nc msl3.nc
ncks -A -v msl msl.nc msl3.nc
ncks -4 msl3.nc "CLM5.0_"$sim"_msl.nc" 

rm msl_ice.nc 
rm msl_liq.nc
rm msl.nc
rm msl3.nc
rm tmp.nc
rm SOILICE.nc
rm SOILLIQ.nc


