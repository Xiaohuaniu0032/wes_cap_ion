bcftools norm -f /data/fulongfei/database/ref/hg19/hg19.fasta -m - -c w /data/fulongfei/git_repo/wes_cap_ion/test/chip1.TSVC_variants.vcf >/data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.vcf

perl /data/fulongfei/git_repo/wes_cap_ion/script/filter_bcfnorm_vcf.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.vcf /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.vcf

perl /data/fulongfei/git_repo/wes_cap_ion/script/filter_QUAL.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.vcf 10 /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf >/data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.qual_nopass.vcf

perl /data/fulongfei/git_repo/wes_cap_ion/script/stat_394_indel_hs_Sens_PPV.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf /data/fulongfei/git_repo/wes_cap_ion/raw_394_indel_hs_file/hs_vcf_from_new_rs.vcf chip1 /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB

