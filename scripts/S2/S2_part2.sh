#!/bin/bash

## run the next 50 years of S2 (1851-1900)
## switching over to transient aerosol,urban,popdens,ndep

casedir='/glade/u/home/djk2120/ctsm_trendy_2023/sims/'
exp='S2'
casename='TRENDY2023_f09_'$exp
caseroot=$casedir$casename

cd $caseroot
./xmlchange STOP_N=50

cp user_nl_clm.1851-2022 user_nl_clm
cp user_nl_datm.1851-1900 user_nl_datm

cd '/glade/scratch/djk2120/'$caseroot'/run'
rm *.bin

cd $caseroot

