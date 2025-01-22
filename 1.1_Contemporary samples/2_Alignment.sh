#!/bin/bash
#SBATCH --verbose
#SBATCH --mem=20G
#SBATCH -c 12
#SBATCH -p all
#SBATCH -J 2_Alighnemt
#SBATCH -t 0-24:00:00
#SBATCH -o /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/trial/log/2_Alignment_%A_%a.log
#SBATCH -e /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/trial/log/2_Alignment_%A_%a.err
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
DAT=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/fastq
REF=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/ref
HOM=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/trial
SAMPLE=$(ls ${DAT}/*_1.fastq.gz | rev | cut -d "/" -f 1 | rev | cut -f 1 -d "_" | sed -n "${SLURM_ARRAY_TASK_ID}p")

#Output directory
if [ "${SLURM_ARRAY_TASK_ID}" -eq 1 ]; then
    mkdir -p ${HOM}/mapping
    mkdir -p ${HOM}/mapped
    mkdir -p ${HOM}/unmapped
fi

#code
#mapping-bwa mem
bwa mem ${REF}/IRGSP-1.0_genome.fasta ${HOM}/trim/${SAMPLE}_1_paired.fastq.gz ${HOM}/trim/${SAMPLE}_2_paired.fastq.gz > ${HOM}/mapping/${SAMPLE}.sam


# Deduplication of mapped reads - samtools, picard
# Mapped
${BIN}/samtools view -bS -F 4 ${HOM}/mapping/${SAMPLE}.sam > ${HOM}/mapped/${SAMPLE}.mapped.bam

java -Xmx8G -jar ~/anaconda3/pkgs/picard-3.2.0-hdfd78af_0/share/picard-3.2.0-0/picard.jar AddOrReplaceReadGroups I=${HOM}/mapped/${SAMPLE}.mapped.bam O=${HOM}/mapped/${SAMPLE}.mapped.RG.bam RGID=${SAMPLE} RGLB=lib1 RGPL=Illumina RGPU=unit1 RGSM=${SAMPLE}

${BIN}/samtools sort ${HOM}/mapped/${SAMPLE}.mapped.RG.bam -o ${HOM}/mapped/${SAMPLE}.mapped.RG.sort.bam

java -Xmx8G -jar ~/anaconda3/pkgs/picard-3.2.0-hdfd78af_0/share/picard-3.2.0-0/picard.jar MarkDuplicates I=${HOM}/mapped/${SAMPLE}.mapped.RG.sort.bam O=${HOM}/mapped/${SAMPLE}.mapped.RG.sort.rmdup.bam M=${HOM}/mapped/${SAMPLE}.metrics.txt REMOVE_DUPLICATES=true


# Unmapped
${BIN}/samtools view -bS -f 4 ${HOM}/mapping/${SAMPLE}.sam > ${HOM}/unmapped/${SAMPLE}.unmapped.bam

java -Xmx3G -jar ~/anaconda3/pkgs/picard-3.2.0-hdfd78af_0/share/picard-3.2.0-0/picard.jar AddOrReplaceReadGroups I=${HOM}/unmapped/${SAMPLE}.unmapped.bam O=${HOM}/unmapped/${SAMPLE}.unmapped.RG.bam RGID=${SAMPLE} RGLB=lib1 RGPL=Illumina RGPU=unit1 RGSM=${SAMPLE}

${BIN}/samtools sort ${HOM}/unmapped/${SAMPLE}.unmapped.RG.bam -o ${HOM}/unmapped/${SAMPLE}.unmapped.RG.sort.bam

java -Xmx3G -jar ~/anaconda3/pkgs/picard-3.2.0-hdfd78af_0/share/picard-3.2.0-0/picard.jar MarkDuplicates I=${HOM}/unmapped/${SAMPLE}.unmapped.RG.sort.bam O=${HOM}/unmapped/${SAMPLE}.unmapped.RG.sort.rmdup.bam M=${HOM}/unmapped/${SAMPLE}.metrics.txt REMOVE_DUPLICATES=true
