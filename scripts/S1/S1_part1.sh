#!/bin/bash
cimeroot='/glade/work/djk2120/trendy2022/cime/scripts/'
trendy='/glade/u/home/djk2120/ctsm_trendy_2023/'
compset='HIST_DATM%CRUv7_CLM50%BGC-CROP_SICE_SOCN_MOSART_CISM2%NOEVOLVE_SWAV'
res='f09_g17'
project='P93300041'
casedir='/glade/u/home/djk2120/ctsm_trendy_2023/sims/'
exp='S1'
caseroot=$casedir'TRENDY2023_f09_'$exp

#need python 3.7.9 for cime
source ~/.bashrc
conda activate oldcime-py



cd $cimeroot
./create_newcase --case $caseroot --compset $compset  --res $res --project $project --mach cheyenne --run-unsupported

cd $caseroot
yr="0400"
./xmlchange RUN_TYPE="hybrid"
./xmlchange RUN_REFCASE="TRENDY2023_f09_spinPostAD"
./xmlchange RUN_REFDIR="/glade/scratch/djk2120/archive/TRENDY2023_f09_spinPostAD/rest/"$yr"-01-01-00000"
./xmlchange RUN_REFDATE=$yr"-01-01"
./xmlchange GET_REFCASE=TRUE
./xmlchange NTASKS_CPL=2520 #2520
./xmlchange NTASKS_LND=2520 # 
./xmlchange NTASKS_ICE=2520 # 
./xmlchange NTASKS_OCN=2520 # 
./xmlchange NTASKS_ROF=2520 #
./xmlchange NTASKS_GLC=2520 #
./xmlchange NTASKS_WAV=2520 #
./xmlchange JOB_QUEUE="regular"
./xmlchange JOB_WALLCLOCK_TIME="12:00:00"
./xmlchange PROJECT=$project
./xmlchange RUN_STARTDATE="1701-01-01"
./xmlchange STOP_OPTION="nyears"
./xmlchange STOP_N=75
./xmlchange RESUBMIT=1
./xmlchange DOUT_S=TRUE

./case.setup
./case.build
cp $trendy'user_datm.streams/PI/user_datm.streams'* ./                    #PI climate
cp $trendy'user_datm.streams/tx/user_datm.streams.txt.co2tseries.20tr' ./ #transient CO2
cp $trendy'namelists/'$exp'/user_nl'* ./
cp user_nl_clm.1701-1850 user_nl_clm



