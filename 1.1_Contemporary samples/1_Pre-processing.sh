#!/bin/bash
#SBATCH --verbose
#SBATCH --mem=20G
#SBATCH -c 12
#SBATCH -p all
#SBATCH -J 1_pre-processing
#SBATCH -t 0-24:00:00
#SBATCH -o /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/trial/log/1_pre-processing_%A_%a.log
#SBATCH -e /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/trial/log/1_pre-processing_%A_%a.err
#SBATCH --array=1-ARRAY_SIZE

#module load & libraries
module purge
eval "$(conda shell.bash hook)"
conda activate ngs

#Submit command: sbatch 1_Pre-processing.sh (or use Slurm_submit.sh for automated ARRAY_SIZE calculation)

#Print the task ID
cd "$SLURM_SUBMIT_DIR"
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_JOB_ID $SLURM_ARRAY_TASK_ID ${SAMPLE}

#Variables
DAT=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/fastq
REF=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/ref
HOM=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/trial
SAMPLE=$(ls ${DAT}/*_1.fastq.gz | rev | cut -d "/" -f 1 | rev | cut -f 1 -d "_" | sed -n "${SLURM_ARRAY_TASK_ID}p")

#Output directory
if [ "${SLURM_ARRAY_TASK_ID}" -eq 1 ]; then
    mkdir -p ${HOM}/fastqc
    mkdir -p ${HOM}/trim
fi

#code
#Quality check - FastQC
fastqc ${DAT}/${SAMPLE}_1.fastq.gz ${DAT}/${SAMPLE}_2.fastq.gz -o ${HOM}/fastqc

#Adapter/quality trimming - Trimmomatic
trimmomatic PE -phred33 ${DAT}/${SAMPLE}_1.fastq.gz ${DAT}/${SAMPLE}_2.fastq.gz ${HOM}/trim/${SAMPLE}_1_paired.fastq.gz ${HOM}/trim/${SAMPLE}_1_unpaired.fastq.gz ${HOM}/trim/${SAMPLE}_2_paired.fastq.gz ${HOM}/trim/${SAMPLE}_2_unpaired.fastq.gz ILLUMINACLIP:/home/yky10kg/anaconda3/env/ngs/share/trimmomatic-0.39-2/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:50
