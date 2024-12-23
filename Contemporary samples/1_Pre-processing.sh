#1_Pre-processing: Quality check and adapter/quality trimming step

#!/bin/bash
#SBATCH --verbose
#SBATCH -c 14
#SBATCH -p all
#SBATCH -J read_pre-processing
#SBATCH -t 0-24:00:00

#module load & libraries
module purge
eval "$(conda shell.bash hook)"
conda activate ngs

#variables
DAT=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/fastq
REF=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/ref
HOM=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers

#code
#Quality check - FastQC
#cat ${HOM}/sample_list | parallel --gnu -j 14 "fastqc ${DAT}/{}_1.fastq.gz ${DAT}/{}_2.fastq.gz -o ${HOM}/fastqc"

#Adapter/quality trimming - Trimmomatic
#cat ${HOM}/sample_list | parallel --gnu -j 14 "trimmomatic PE -phred33 ${DAT}/{}_1.fastq.gz ${DAT}/{}_2.fastq.gz ${HOM}/trim/{}_1_paired.fastq.gz ${HOM}/trim/{}_1_unpaired.fastq.gz ${HOM}/trim/{}_2_paired.fastq.gz ${HOM}/trim/{}_2_unpaired.fastq.gz ILLUMINACLIP:./share/trimmomatic-0.39-2/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:50"
