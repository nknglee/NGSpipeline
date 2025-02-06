#!/bin/bash

#Output directory
mkdir /path/to/HOM/fastqc
mkdir /path/to/HOM/trim
mkdir /path/to/HOM/mapping
mkdir /path/to/HOM/mapped
mkdir /path/to/HOM/unmapped
mkdir /path/to/HOM/QC
mkdir /path/to/HOM/gvcf
mkdir /path/to/HOM/vcf

# Calculate the array size
ARRAY_SIZE=$(ls /path/to/fastq/*_1.fastq.gz | wc -l)

# Replace ARRAY_SIZE in the original script and generate modified script
sed "s/ARRAY_SIZE/${ARRAY_SIZE}/" script.sh > Modified_script.sh

# Submit the job using modified script
sbatch ./Modified_script.sh

#Submit command: (change the script.sh first) sbatch ./Slurm_submit.sh
