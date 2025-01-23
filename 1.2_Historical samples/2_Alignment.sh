#!/bin/bash
#SBATCH --verbose
#SBATCH --mem=20G
#SBATCH -c 12
#SBATCH -p all
#SBATCH -J 2_Alighnemt
#SBATCH -t 0-24:00:00
#SBATCH -o /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/herbarium/trial/log/2_Alignment_%A_%a.log
#SBATCH -e /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/herbarium/trial/log/2_Alignment_%A_%a.err
#SBATCH --array=1-ARRAY_SIZE

#module load & libraries
module purge
eval "$(conda shell.bash hook)"
conda activate ngs

#Submit command: sbatch 2_Alignment.sh (or use Slurm_submit.sh for automated ARRAY_SIZE calculation)

#Print the task ID
cd "$SLURM_SUBMIT_DIR"
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_JOB_ID $SLURM_ARRAY_TASK_ID ${SAMPLE}

#Variables
BIN=/home/yky10kg/anaconda3/envs/ngs/bin
DAT=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/herbarium/trial/fastq
REF=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/ref
HOM=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/herbarium/trial
SAMPLE=$(ls ${DAT}/*_1.fastq.gz | rev | cut -d "/" -f 1 | rev | cut -f 1 -d "_" | sed -n "${SLURM_ARRAY_TASK_ID}p")

#Output directory
if [ "${SLURM_ARRAY_TASK_ID}" -eq 1 ]; then
    mkdir -p ${HOM}/mapping
    mkdir -p ${HOM}/mapped
    mkdir -p ${HOM}/unmapped
fi

#Code
#Mapping - bwa
bwa aln -t 12 ${REF}/IRGSP-1.0_genome.fasta ${HOM}/trim/${SAMPLE}.collapsed.gz > ${HOM}/mapping/${SAMPLE}.collapsed.sai
bwa samse -r @RG\tID:${SAMPLE}\tSM:${SAMPLE} ${REF}/IRGSP-1.0_genome.fasta ${HOM}/mapping/${SAMPLE}.collapsed.sai ${HOM}/trim/${SAMPLE}.collapsed.gz > ${HOM}/mapping/${SAMPLE}.sam

#Filtering and sorting - samtools
${BIN}/samtools view -bShu -F 4 ${HOM}/mapping/${SAMPLE}.sam > ${HOM}/mapped/${SAMPLE}.mapped.bam
${BIN}/samtools sort ${HOM}/mapped/${SAMPLE}.mapped.bam -o ${HOM}/mapped/${SAMPLE}.mapped.sort.bam

# Deduplication of mapped reads - DeDup
# Mapped
dedup -i ${HOM}/mapped/${SAMPLE}.mapped.sort.bam -m -o ${HOM}/mapped/${SAMPLE}.mapped.sort.rmdup.bam
java -Xmx3G -jar /home/yky10kg/anaconda3/pkgs/picard-3.2.0-hdfd78af_0/share/picard-3.2.0-0/picard.jar BuildBamIndex I=${HOM}/mapped/${SAMPLE}.mapped.sort.rmdup.bam

# Unmapped
${BIN}/samtools view -bShu -f 4 ${HOM}/mapping/${SAMPLE}.sam > ${HOM}/unmapped/${SAMPLE}.unmapped.bam
${BIN}/samtools sort ${HOM}/unmapped/${SAMPLE}.unmapped.bam -o ${HOM}/unmapped/${SAMPLE}.unmapped.sort.bam

dedup -i ${HOM}/unmapped/${SAMPLE}.unmapped.sort.bam -m -o ${HOM}/unmapped/${SAMPLE}.unmapped.sort.rmdup.bam
java -Xmx3G -jar /home/yky10kg/anaconda3/pkgs/picard-3.2.0-hdfd78af_0/share/picard-3.2.0-0/picard.jar BuildBamIndex I=${HOM}/unmapped/${SAMPLE}.unmapped.sort.rmdup.bam
