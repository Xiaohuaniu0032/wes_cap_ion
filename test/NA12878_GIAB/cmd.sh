vcf='/data/fulongfei/git_repo/wes_cap_ion/test/chip1.TSVC_variants.vcf'
fa='/data/fulongfei/database/ref/hg19/hg19.fasta'
sample='chip1'

giab_wes='/data/fulongfei/git_repo/wes_cap_ion/agilent_v6_giab_vcf/agilent_v6_var_giab.vcf'
perl ../../Stat_Sensitivity_PPV_Main.pl -vcf $vcf -fa $fa -s $sample -gvcf $giab_wes -od $PWD
