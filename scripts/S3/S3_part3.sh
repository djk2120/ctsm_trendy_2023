#!/bin/bash
## run the last bit (1901-2022)
## bring in transient climate
casedir='/glade/u/home/djk2120/ctsm_trendy_2023/sims/'
exp='S3'
casename='TRENDY2023_f09_'$exp
caseroot=$casedir$casename

cd $caseroot
./xmlchange STOP_N=61
./xmlchange RESUBMIT=1
cp user_nl_datm.1901-2022 user_nl_datm
./xmlchange DATM_CLMNCEP_YR_END=2022
cd '/glade/scratch/djk2120/'$casename'/run'
rm *.bin

cd $caseroot


