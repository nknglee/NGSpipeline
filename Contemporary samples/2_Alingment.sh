#2_Alighnemt: Mapping, filtering, deduplicating

#!/bin/bash
#SBATCH --verbose
#SBATCH -c 14
#SBATCH -p short
#SBATCH -J read_processing_farmers
#SBATCH -t 0-24:00:00
#SBATCH -o /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/read_processing_farmers3.log
#SBATCH -e /data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/read_processing_farmers3.err

#module load & libraries
module purge
eval "$(conda shell.bash hook)"
conda activate ngs

#variables
DAT=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers/fastq
REF=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/ref
HOM=/data/users_area/yky10kg/GREENrice/Cons_Gen/datasets/farmers

#code
#mapping-bwa mem
#cat ${HOM}/sample_list | parallel --gnu -j 14 "bwa mem ${REF}/IRGSP-1.0_genome.fasta ${HOM}/trim/{}_1_paired.fastq.gz ${HOM}/trim/{}_2_paired.fastq.gz > ${HOM}/mapping/{}.sam"

#deduplication of mapped&unmapped reads-samtools,picard
#mapped
cat ${HOM}/sample_list | parallel --gnu -j 14 "/home/yky10kg/anaconda3/envs/ngs/bin/samtools view -bS -F 4 ${HOM}/mapping/{}.sam > ${HOM}/mapped/{}.mapped.bam"

cat ${HOM}/sample_list | parallel --gnu -j 14 "java -Xmx3G -jar /home/yky10kg/anaconda3/pkgs/picard-3.2.0-hdfd78af_0/share/picard-3.2.0-0/picard.jar AddOrReplaceReadGroups I=${HOM}/mapped/{}.mapped.bam O=${HOM}/mapped/{}.mapped.RG.bam RGID={} RGLB=lib1 RGPL=Illumina RGPU=unit1 RGSM={}"

cat ${HOM}/sample_list | parallel --gnu -j 14 "/home/yky10kg/anaconda3/envs/ngs/bin/samtools sort ${HOM}/mapped/{}.mapped.RG.bam -o ${HOM}/mapped/{}.mapped.RG.sort.bam"

cat ${HOM}/sample_list | parallel --gnu -j 14 "java -Xmx3G -jar /home/yky10kg/anaconda3/pkgs/picard-3.2.0-hdfd78af_0/share/picard-3.2.0-0/picard.jar MarkDuplicates I=${HOM}/mapped/{}.mapped.RG.sort.bam O=${HOM}/mapped/{}.mapped.RG.sort.rmdup.bam M=${HOM}/mapped/{}.metrics.txt REMOVE_DUPLICATES=true"

#unmapped
cat ${HOM}/sample_list | parallel --gnu -j 14 "/home/yky10kg/anaconda3/envs/ngs/bin/samtools view -bS -f 4 ${HOM}/mapping/{}.sam > ${HOM}/unmapped/{}.unmapped.bam"

cat ${HOM}/sample_list | parallel --gnu -j 14 "java -Xmx3G -jar /home/yky10kg/anaconda3/pkgs/picard-3.2.0-hdfd78af_0/share/picard-3.2.0-0/picard.jar AddOrReplaceReadGroups I=${HOM}/unmapped/{}.unmapped.bam O=${HOM}/unmapped/{}.unmapped.RG.bam RGID={} RGLB=lib1 RGPL=Illumina RGPU=unit1 RGSM={}"

cat ${HOM}/sample_list | parallel --gnu -j 14 "/home/yky10kg/anaconda3/envs/ngs/bin/samtools sort ${HOM}/unmapped/{}.unmapped.RG.bam -o ${HOM}/unmapped/{}.unmapped.RG.sort.bam"

cat ${HOM}/sample_list | parallel --gnu -j 14 "java -Xmx3G -jar /home/yky10kg/anaconda3/pkgs/picard-3.2.0-hdfd78af_0/share/picard-3.2.0-0/picard.jar MarkDuplicates I=${HOM}/unmapped/{}.unmapped.RG.sort.bam O=${HOM}/unmapped/{}.unmapped.RG.sort.rmdup.bam M=${HOM}/unmapped/{}.metrics.txt REMOVE_DUPLICATES=true"
