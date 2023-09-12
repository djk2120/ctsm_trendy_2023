#!/bin/bash
#PBS -N S3
#PBS -q casper
#PBS -l walltime=12:00:00
#PBS -A P93300641
#PBS -j oe
#PBS -k eod
#PBS -l select=1:ncpus=1

source ~/.bashrc
conda activate trendy-py

sim='S3'

mkdir -p "/glade/campaign/cgd/tss/projects/TRENDY/v12/"$sim"/lnd/proc/trendy"
python make_gcp2022_output_files.py $sim
