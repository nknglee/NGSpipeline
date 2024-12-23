#3_QualityCheck: QC of mapped/unmapped bam files

#!/bin/bash
#SBATCH --verbose
#SBATCH -c 14
#SBATCH -p all
#SBATCH -J 3_QualityCheck
#SBATCH -t 0-3:00:00
#SBATCH -o /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/read_count_farmers.log
#SBATCH -e /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/read_count_farmers.err

#module load & libraries
module purge
eval "$(conda shell.bash hook)"
conda activate ngs

#variables
DAT=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/fastq
REF=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/ref
HOM=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers

#code
#raw fastq reads
#zcat ${DAT}/*.fastq.gz | wc -l | awk '{print $1/4}'

#mapped reads
#cat ${HOM}/sample_list | parallel --gnu -j 14 "/home/yky10kg/anaconda3/envs/ngs/bin/samtools flagstat ${HOM}/mapped/{}.mapped.RG.sort.rmdup.bam"

#unmapped reads
#cat ${HOM}/sample_list | parallel --gnu -j 14 "/home/yky10kg/anaconda3/envs/ngs/bin/samtools flagstat ${HOM}/unmapped/{}.unmapped.RG.sort.rmdup.bam"

#read stats
cat ${HOM}/sample_list | echo "SAMPLE=${HOM}/mapped/{}.mapped.RG.sort.rmdup.bam\n" 
cat ${HOM}/sample_list | /home/yky10kg/anaconda3/envs/ngs/bin/samtools stats ${HOM}/mapped/{}.mapped.RG.sort.rmdup.bam | grep ^SN | cut -f 2-
