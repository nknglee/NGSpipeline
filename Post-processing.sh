#!/bin/bash
#SBATCH --verbose
#SBATCH --mem=20G
#SBATCH -c 12
#SBATCH -p all
#SBATCH -J 6_Post-processing
#SBATCH -t 0-48:00:00
#SBATCH -o /path/to/log/Post-processing_%j.log
#SBATCH -e /path/to/log/Post-processing_%j.err

#module load & libraries
module purge
eval "$(conda shell.bash hook)"
conda activate ngs
module load vcftools plink

#Submit command: sbatch 6_Post-processing.sh

#Print the task ID
cd "$SLURM_SUBMIT_DIR"
echo "My SLURM_JOB_ID: " $SLURM_JOB_ID

#Variables
REF=/path/to/ref
HOM=/path/to/working/directory
JAR=/path/to/snpEff/jar

#Code
#Compress and index - ONLY IF NEEDED
#bgzip ${HOM}/vcf/combined.vcf
#tabix -p vcf ${HOM}/vcf/combined.vcf.gz

#SNP filtering - vcftools
vcftools --gzvcf ${HOM}/vcf/combined.vcf.gz --remove-indels --maf 0.05 --max-missing 0.75 --minQ 30 --minDP 4 --mac 1 --max-alleles 2 --recode --recode-INFO-all --out ${HOM}/vcf/output.SNPs.maf005.MM075.q30.d4.biallele

#Compress and index
bgzip ${HOM}/vcf/output.SNPs.maf005.MM075.q30.d4.biallele.recode.vcf
tabix -p vcf ${HOM}/vcf/output.SNPs.maf005.MM075.q30.d4.biallele.recode.vcf.gz

#Annotattion
java -jar ${JAR}/snpEff.jar download -v Oryza_sativa
java -Xmx16g -jar ${JAR}/snpEff.jar -v IRGSP ${HOM}/vcf/output.SNPs.maf005.MM075.q30.d4.biallele.recode.vcf.gz > ${HOM}/vcf/output.SNPs.maf005.MM075.q30.d4.biallele.IRGSP.annotated.recode.vcf.gz

#SNP filtering - plink
