#perl extract_dbSNP_in_BED.pl /data/fulongfei/database/annot/dbSNP/hg19/2021-5-25/GCF_000001405.25.gz /data/fulongfei/git_repo/wes_cap_ion/bed_files/merge_bed/YH_plus_Agilent_V6.bed > dbSNP_in_bed_region.vcf &

#less dbSNP_in_bed_region.vcf |grep "^#" >vcf.header
#less dbSNP_in_bed_region.vcf |grep -v "^#" | shuf -n 5000 >dbSNP.5000.rs.vcf
#cat vcf.header dbSNP.5000.rs.vcf >dbSNP.5000rs.random.vcf
#rm vcf.header
#rm dbSNP.5000.rs.vcf

#perl merge_394indelHS_and_wes_randomHS.pl hs_vcf_from_new_rs.vcf dbSNP.5000rs.random.vcf wes_snv_indel_hs.vcf

# vcf to hs bed
vcf='wes_snv_indel_hs.vcf'
fa='/data/fulongfei/database/ref/hg19/hg19.fasta'
# -a perform left-alignment of indels
# -s do not filter out block substitution hotspots
# -d output left-aligned hotspots in BED format
tvcutils prepare_hotspots -v $vcf -r $fa -a -s -d wes.hs.2021_12_17.bed >tvc.hs.make.log
