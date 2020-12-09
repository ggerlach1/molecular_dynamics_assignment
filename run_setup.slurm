#!/bin/bash

#SBATCH --job-name=simulation_setup

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
##SBATCH --nodelist=n141
#SBATCH --time=24:00:00
#SBATCH --partition=dept_cpu
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=None
#SBATCH --error=sbatch.stderr
#SBATCH --output=sbatch.stdout
##SBATCH --exclude=n017,n004,n003
#----PARAMETERS------------------------------------------------------------

#scratch drive folder to work in
JOBID=$(echo $SLURM_JOB_ID| grep -oP '^\d+')
SCRATCH_DIR=/scr/$USER/$SLURM_JOB_NAME/$JOBID
BASE_SCR=/scr/$USER/
#if the scratch drive doesn't exist (it shouldn't) make it.
if [[ ! -e ${SCRATCH_DIR} ]]; then
    mkdir -p ${SCRATCH_DIR} && echo "scratch drive ${SCRATCH_DIR}"
fi



# change to scratch directory so job runs locally isntead of over the network
# (slows everyone down)
cd ${SCRATCH_DIR}


rsync -av \
      ${SLURM_SUBMIT_DIR}/*   \
      ${SCRATCH_DIR}


#copy files on exit or interrupt
trap clean_up EXIT

#define clean_up
clean_up(){
    echo 'copying files'
    rsync -av ${SCRATCH_DIR}/ ${SLURM_SUBMIT_DIR}

}
#-----Running Jobs --------
module load amber/18-cluster

tleap -f tleap.input 


#--------------------------------------------------------------------------
# Leave this line to tell slurm that the script finished correctly
exit 0
