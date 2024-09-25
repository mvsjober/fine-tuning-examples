#!/bin/bash
#SBATCH --account=project_462000007
#SBATCH --partition=dev-g
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=56
#SBATCH --mem=480G
#SBATCH --time=0:15:00
#SBATCH --gpus-per-node=8

module purge
module use /appl/local/csc/modulefiles/
module load pytorch/2.4

# This will store all the Hugging Face cache such as downloaded models
# and datasets in the project's scratch folder
export HF_HOME=/scratch/${SLURM_JOB_ACCOUNT}/${USER}/hf-cache
mkdir -p $HF_HOME

# Path to where the trained model and logging data will go
OUTPUT_DIR=/scratch/${SLURM_JOB_ACCOUNT}/${USER}/hf-data
mkdir -p $OUTPUT_DIR

# Disable internal parallelism of huggingface's tokenizer since we
# want to retain direct control of parallelism options.
export TOKENIZERS_PARALLELISM=false


set -xv  # print the command so that we can verify setting arguments correctly from the logs

srun torchrun --standalone \
     --nnodes=1 \
     --nproc-per-node=$SLURM_GPUS_PER_NODE \
     finetuning.py $* \
     --output-path $OUTPUT_DIR \
     --num-workers 7
