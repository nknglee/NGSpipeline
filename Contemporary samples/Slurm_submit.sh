#!/bin/bash

# Calculate the array size
ARRAY_SIZE=$(ls /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/fastq/*_1.fastq.gz | wc -l)

# Replace ARRAY_SIZE in the original script and generate modified script
sed "s/ARRAY_SIZE/${ARRAY_SIZE}/" script.sh > Modified_script.sh

# Submit the job using modified script
sbatch ./Modified_script.sh

#Submit command: (change the script.sh first) sbatch ./Slurm_submit.sh
