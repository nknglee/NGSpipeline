#!/bin/bash
#SBATCH --verbose
#SBATCH --mem=20G
#SBATCH -c 12
#SBATCH -p all
#SBATCH -J Genotyping
#SBATCH -t 0-72:00:00
#SBATCH -o /path/to/log/Genotyping_%j.log
#SBATCH -e /path/to/log/Genotyping_%j.err

#module load & libraries
module purge
eval "$(conda shell.bash hook)"
conda activate ngs

#Submit command: sbatch Genotyping.sh

#Print the task ID
cd "$SLURM_SUBMIT_DIR"
echo "My SLURM_JOB_ID: " $SLURM_JOB_ID

#Variables
REF=/path/to/ref
HOM=/path/to/working/directory


#Code
#Sample list for genotyping
ls ${HOM}/gvcf/*.mapped.RG.sort.rmdup.g.vcf.gz > ${HOM}/gvcf/gvcf.list

#Combine GVCFs
gatk --java-options "-Xmx32G" CombineGVCFs -R ${REF}/IRGSP-1.0_genome.fasta --variant ${HOM}/gvcf/gvcf.list -O ${HOM}/gvcf/combined.g.vcf.gz

# Validate Variants
gatk --java-options "-Xmx32G" ValidateVariants -V ${HOM}/gvcf/combined.g.vcf.gz

# Genotype GVCFs
gatk --java-options "-Xmx32G" GenotypeGVCFs -R ${REF}/IRGSP-1.0_genome.fasta -V ${HOM}/gvcf/combined.g.vcf.gz -O ${HOM}/vcf/combined.vcf.gz
