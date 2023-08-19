#!/bin/bash
cimeroot='/glade/work/djk2120/trendy2022/cime/scripts/'
trendy='/glade/u/home/djk2120/ctsm_trendy_2023/'
compset='I1850Clm50BgcCropCru'
res='f09_g17'
project='P93300641'
casedir='/glade/u/home/djk2120/ctsm_trendy_2023/sims/'
caseroot=$casedir'TRENDY2023_f09_spinPostAD'


cd $cimeroot
./create_newcase --case $caseroot --compset $compset  --res $res --project $project

cd $caseroot
./xmlchange RUN_TYPE="hybrid"
./xmlchange RUN_REFCASE="TRENDY2023_f09_spinAD"
./xmlchange RUN_REFDIR="/glade/scratch/djk2120/archive/TRENDY2023_f09_spinAD/rest/0400-01-01-00000"
./xmlchange RUN_REFDATE="0400-01-01"
./xmlchange GET_REFCASE=TRUE
./xmlchange NTASKS_CPL=2520
./xmlchange NTASKS_LND=2520 
./xmlchange NTASKS_ICE=2520 
./xmlchange NTASKS_OCN=2520 
./xmlchange NTASKS_ROF=2520
./xmlchange NTASKS_GLC=2520
./xmlchange NTASKS_WAV=2520
./xmlchange JOB_QUEUE="regular"
./xmlchange JOB_WALLCLOCK_TIME="12:00:00"
./xmlchange RUN_STARTDATE="0000-01-01"
./xmlchange STOP_OPTION="nyears"
./xmlchange STOP_N=100
./xmlchange RESUBMIT=9
./xmlchange DOUT_S=TRUE
./xmlchange CLM_BLDNML_OPTS="-bgc bgc -crop -co2_ppmv 276.59"


./case.setup
cp $trendy'user_datm.streams/PI/user_datm.streams'* ./
cp $trendy'namelists/spinPostAD/user_nl'* ./


