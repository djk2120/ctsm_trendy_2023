#!/bin/bash
cimeroot='/glade/work/djk2120/trendy2022/cime/scripts/'
trendy='/glade/u/home/djk2120/ctsm_trendy_2023/'
compset='I1850Clm50BgcCropCru'
res='f09_g17'
project='P93300041'
casedir=$trendy'sims/'
caseroot=$casedir'TRENDY2023_f09_spinAD'

cd $cimeroot
./create_newcase --case $caseroot --compset $compset  --res $res --project $project

cd $caseroot
./xmlchange CLM_ACCELERATED_SPINUP="on"
./xmlchange JOB_QUEUE="regular"
./xmlchange JOB_WALLCLOCK_TIME="12:00:00"
./xmlchange PROJECT=$project
./xmlchange RUN_STARTDATE="0000-01-01"
./xmlchange STOP_OPTION="nyears"
./xmlchange STOP_N=40
./xmlchange RESUBMIT=9
./xmlchange DOUT_S=TRUE
./xmlchange CLM_BLDNML_OPTS="-bgc bgc -crop -co2_ppmv 276.59"

./case.setup
cp $trendy'user_datm.streams/PI/user_datm.streams'* ./
cp $trendy'namelists/spinAD/user_nl'* ./


