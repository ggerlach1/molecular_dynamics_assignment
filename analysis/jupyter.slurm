#!/bin/bash

#SBATCH --job-name=jn

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=8:00:00
#SBATCH --partition=dept_cpu
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=None
#SBATCH --error=sbatch.stderr
#SBATCH --output=sbatch.jupyter
## get tunneling info
XDG_RUNTIME_DIR=""
ipnport=$(shuf -i8000-9999 -n1)
ipnip=$(hostname -i)
## print tunneling instructions to jupyter-log-{jobid}.txt
echo -e "
Copy/Paste this in your local terminal to ssh tunnel with remote
-----------------------------------------------------------------
ssh -N -L $ipnport:$ipnip:$ipnport USER@cluster.csb.pitt.edu
-----------------------------------------------------------------
Then open a browser on your local machine to the following address
------------------------------------------------------------------
localhost:$ipnport  (prefix w/ https:// if using password)
------------------------------------------------------------------
"
## start an ipcluster instance and launch jupyter server
module load anaconda/3-cluster
jupyter-notebook --NotebookApp.iopub_data_rate_limit=100000000000000 \
   --port=$ipnport --ip=$ipnip --NotebookApp.password='' --NotebookApp.token='' --no-browser

