#!/bin/bash
#SBATCH --verbose
#SBATCH --mem=20G
#SBATCH -c 12
#SBATCH -p all
#SBATCH -J 3_QualityCheck
#SBATCH -t 0-3:00:00
#SBATCH -o /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/trial/log/3_QualityCheck_%A_%a.log
#SBATCH -e /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/trial/log/3_QualityCheck_%A_%a.err
#SBATCH --array=1-ARRAY_SIZE

#module load & libraries
module purge
eval "$(conda shell.bash hook)"
conda activate ngs

#Submit command: sbatch 3_QualityCheck.sh (or use Slurm_submit.sh for automated ARRAY_SIZE calculation)

#Print the task ID
cd "$SLURM_SUBMIT_DIR"
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_JOB_ID $SLURM_ARRAY_TASK_ID ${SAMPLE}

#Variables
BIN=/home/yky10kg/anaconda3/envs/ngs/bin
DAT=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/fastq
REF=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/ref
HOM=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/trial
SAMPLE=$(ls ${DAT}/*_1.fastq.gz | rev | cut -d "/" -f 1 | rev | cut -f 1 -d "_" | sed -n "${SLURM_ARRAY_TASK_ID}p")

#Output directory
if [ "${SLURM_ARRAY_TASK_ID}" -eq 1 ]; then
    mkdir -p ${HOM}/QC
fi

#Code
# Raw fastq reads
echo "Raw fastq reads:" > ${HOM}/QC/quality_check_${SAMPLE}.txt
zcat ${DAT}/${SAMPLE}.fastq.gz | wc -l | awk '{print $1/4}' >> ${HOM}/QC/quality_check_${SAMPLE}.txt

# Mapped reads
echo -e "\nMapped reads:" >> ${HOM}/QC/quality_check_${SAMPLE}.txt
${BIN}/samtools flagstat ${HOM}/mapped/${SAMPLE}.mapped.RG.sort.rmdup.bam >> ${HOM}/QC/quality_check_${SAMPLE}.txt

# Unmapped reads
echo -e "\nUnmapped reads:" >> ${HOM}/QC/quality_check_${SAMPLE}.txt
${BIN}/samtools flagstat ${HOM}/unmapped/${SAMPLE}.unmapped.RG.sort.rmdup.bam >> ${HOM}/QC/quality_check_${SAMPLE}.txt

# Read stats
echo -e "\nRead stats:" >> ${HOM}/QC/quality_check_${SAMPLE}.txt
echo "SAMPLE=${HOM}/mapped/${SAMPLE}.mapped.RG.sort.rmdup.bam" >> ${HOM}/QC/quality_check_${SAMPLE}.txt
${BIN}/samtools stats ${HOM}/mapped/${SAMPLE}.mapped.RG.sort.rmdup.bam | grep ^SN | cut -f 2- >> ${HOM}/QC/quality_check_${SAMPLE}.txt
