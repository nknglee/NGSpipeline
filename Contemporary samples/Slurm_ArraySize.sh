#!/bin/bash

# Calculate the array size
ARRAY_SIZE=$(ls /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/fastq/*_1.fastq.gz | wc -l)

# Replace ARRAY_SIZE in the SLURM script
sed "s/ARRAY_SIZE/${ARRAY_SIZE}/" slurm_script.sh > Slurm_ArraySize.sh

# Submit command: sbatch ./Slurm_ArraySize.sh
