vcf='YH-indel.vcf'
fa='/data/fulongfei/database/ref/hg19/hg19.fasta'

# -a perform left-alignment of indels
# -s do not filter out block substitution hotspots
# -d output left-aligned hotspots in BED format

# 去除有多个alt allele的位点
# 这些位点处理起来比较复杂
#less YH-indel.vcf|awk '$5~/,/' >multi_alt_allele.vcf

#tvcutils prepare_hotspots -v $vcf -r $fa -a -s -d YH-indel.bed

perl process_raw_YH-indel-vcf.pl YH-indel.vcf $fa YH-indel.2021-1-6.vcf YH-indel.2021-1-6.bed
