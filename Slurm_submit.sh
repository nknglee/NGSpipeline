#!/bin/bash

# Output directory
mkdir -p /path/to/HOM/fastqc
mkdir -p /path/to/HOM/trim
mkdir -p /path/to/HOM/mapping
mkdir -p /path/to/HOM/mapped
mkdir -p /path/to/HOM/unmapped
mkdir -p /path/to/HOM/QC
mkdir -p /path/to/HOM/gvcf
mkdir -p /path/to/HOM/vcf

# Calculate the array size
ARRAY_SIZE=$(ls /path/to/fastq/*_1.fastq.gz | wc -l)

# Replace ARRAY_SIZE in the original script and generate modified script
sed "s/ARRAY_SIZE/${ARRAY_SIZE}/" script.sh > Modified_script.sh

# Submit the job using modified script and extract JOB_ID for Array job
ARRAY_JOB_ID=$(sbatch ./Modified_script.sh | awk '{print $4}')

#Submit command: sbatch ./Slurm_submit.sh

# Job records
cd "$SLURM_SUBMIT_DIR"
echo "SLURM_JOB_ID: $SLURM_JOB_ID" >> /path/to/log/Slurm_Record.log
echo "SLURM_JOB_ID for ARRAY_JOB: $ARRAY_JOB_ID" >> /path/to/log/Slurm_Record.log
echo "Date: $(date)" >> /path/to/log/Slurm_Record.log
echo "Array Size: $ARRAY_SIZE" >> /path/to/log/Slurm_Record.log
echo "--------------------------------------------" >> /path/to/log/Slurm_Record.log
