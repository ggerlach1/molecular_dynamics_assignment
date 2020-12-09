#!/bin/bash

#SBATCH --job-name=minimization

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00
#SBATCH --partition=dept_gpu
#SBATCH --mail-type=None
#SBATCH --error=sbatch.%A.stderr
#SBATCH --output=sbatch.%A.stdout

#----PARAMETERS------------------------------------------------------------

#scratch drive folder to work in
JOBID=$(echo $SLURM_JOB_ID| grep -oP '^\d+')
SCRATCH_DIR=/scr/$USER/$SLURM_JOB_NAME/$JOBID

#if the scratch drive doesn't exist (it shouldn't) make it.
if [[ ! -e ${SCRATCH_DIR} ]]; then
    mkdir -p ${SCRATCH_DIR} && echo "scratch drive ${SCRATCH_DIR}"
fi

# change to scratch directory so job runs locally isntead of over the network
# (slows everyone down)
cd ${SCRATCH_DIR}

# copy files to working directory
SYSTEM=xxxNAMExxx
INIT=${SYSTEM}
ISTEP=xxxNAMExxx_mini
INPUT=1_mini
INITCOOR=xxxNAMExxx

rsync -av \
      ${SLURM_SUBMIT_DIR}/${INPUT}.mdin    \
      ${SLURM_SUBMIT_DIR}/${INIT}.parm7    \
      ${SLURM_SUBMIT_DIR}/${INITCOOR}.rst7 \
      ${SCRATCH_DIR}


#copy files on exit or interrupt
trap clean_up EXIT

#define clean_up
clean_up(){
    echo 'copying files'
    rsync -av ${SCRATCH_DIR}/ ${SLURM_SUBMIT_DIR}
}

#----FOR RUNNING AMBER--------------------------------------------------
module load amber/18-cluster

# executable of gpu amber
pmemd.cuda -O  -i ${INPUT}.mdin -o ${ISTEP}.mdout  -p  ${INIT}.parm7  -c ${INITCOOR}.rst7 -r ${ISTEP}.rst7 -x ${ISTEP}.nc -inf ${ISTEP}.mdinfo -ref ${INITCOOR}.rst7 > ${ISTEP}.amber.out


#--------------------------------------------------------------------------
# Leave this line to tell slurm that the script finished correctly
exit 0
