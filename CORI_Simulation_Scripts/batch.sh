#!/bin/sh
#SBATCH -N 122 -c 64
##SBATCH -q debug
##SBATCH -q regular 
#SBATCH --qos=premium
#SBATCH -t 00:60:00
#SBATCH -C haswell

cd $SLURM_SUBMIT_DIR
export PATH=$PATH:/usr/common/tig/taskfarmer/1.5/bin:$(pwd)
export THREADS=32
runcommands.sh inputlist.txt

python3 createLogFile.py

##module load matlab
##srun -n 1 -c 32 matlab -nodisplay -r < output_CORI.m -logfile output_CORI.log

