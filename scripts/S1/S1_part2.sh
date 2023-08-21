#!/bin/bash
casedir='/glade/u/home/djk2120/ctsm_trendy_2023/sims/'
exp='S1'
caseroot=$casedir'TRENDY2023_f09_'$exp

#running from 1851-2022
cd $caseroot
./xmlchange STOP_N=86
./xmlchange RESUBMIT=1
cp user_nl_clm.1851-2022 user_nl_clm  #adding transient pop dens


