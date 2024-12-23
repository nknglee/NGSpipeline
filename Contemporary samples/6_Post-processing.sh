#6_Post-processing: SNP filtering, annotation

#!/bin/bash
#SBATCH --verbose
#SBATCH -c 14
#SBATCH -p all
#SBATCH -J 6_Post-processing
#SBATCH -t 48:00:00
#SBATCH -o 
#SBATCH -e 

#module load & libraries
module purge
eval "$(conda shell.bash hook)"
conda activate ngs

#variables
DAT=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/fastq
REF=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/ref
HOM=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers

#code
#Compress and index
bgzip ${HOM}/combined.vcf
tabix -p ${HOM}/combined.vcf.gz

#SNP filtering - vcftools
vcftools --gzvcf ${HOM}/combined.vcf.gz --remove-indels --maf 0.05 --max-missing 0.75 --minQ 30 --minDP 4 --mac 1 --max-alleles 2 --recode --recode-INFO-all --out ${HOM}/output.SNPs.maf005.MM075.q30.d4.biallele

#Compress and index
bgzip ${HOM}/output.SNPs.maf005.MM075.q30.d4.biallele.vcf
tabix -p ${HOM}/output.SNPs.maf005.MM075.q30.d4.biallele.vcf.gz

#Annotattion
java -jar ~/snpEff/snpEff.jar build -gff3 -v IRGSP
java -Xmx16g -jar ~/snpEff/snpEff.jar -v IRGSP ${HOM}/output.SNPs.maf005.MM075.q30.d4.biallele.vcf.gz > ${HOM}/output.SNPs.maf005.MM075.q30.d4.biallele.IRGSP.annotated.vcf.gz
