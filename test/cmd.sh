vcf='/data/fulongfei/git_repo/wes_cap_ion/test/chip1.TSVC_variants.vcf'
fa='/data/fulongfei/database/ref/hg19/hg19.fasta'
sample='chip1'
hs_indel=''


perl ../Stat_Sensitivity_PPV_Main.pl -vcf $vcf -fa $fa -s $sample -od $PWD
