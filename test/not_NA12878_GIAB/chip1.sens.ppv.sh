bcftools norm -f /data/fulongfei/database/ref/hg19/hg19.fasta -m - -c w /data/fulongfei/git_repo/wes_cap_ion/test/chip1.TSVC_variants.vcf >/data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.vcf

perl /data/fulongfei/git_repo/wes_cap_ion/script/filter_bcfnorm_vcf.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.vcf /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.vcf

perl /data/fulongfei/git_repo/wes_cap_ion/script/filter_QUAL.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.vcf 10 /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf >/data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.qual_nopass.vcf

perl /data/fulongfei/git_repo/wes_cap_ion/script/Stat_Sensitivity.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf /data/fulongfei/git_repo/wes_cap_ion/indel_hs_2022-1-6-xh/YH-indel.vcf chip1 /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.Sensitivity.xls /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.Sens_PPV_Summary.xls

perl /data/fulongfei/git_repo/wes_cap_ion/script/Stat_PPV.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf /data/fulongfei/git_repo/wes_cap_ion/bed_files/YH.bed /data/fulongfei/git_repo/wes_cap_ion/indel_hs_2022-1-6-xh/YH-indel.vcf /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.PPV.xls /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.Sens_PPV_Summary.xls

perl /data/fulongfei/git_repo/wes_cap_ion/script/Check_Sens_TVC_Detail.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.Sensitivity.xls /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.vcf /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TVC.Info.Sens.xls

perl /data/fulongfei/git_repo/wes_cap_ion/script/Check_PPV_TVC_Detail.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.PPV.xls /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TSVC_variants.bcfnorm.vcf /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TVC.Info.PPV.xls

perl /data/fulongfei/git_repo/wes_cap_ion/script/HS_InDel_Depth_Summary.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TVC.Info.Sens.xls /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.HS.InDel.Depth.Summary.xls

perl /data/fulongfei/git_repo/wes_cap_ion/script/HS_InDel_NoCall_Reason_Summary.pl /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.TVC.Info.Sens.xls /data/fulongfei/git_repo/wes_cap_ion/test/not_NA12878_GIAB/chip1.HS.InDel.NoCall.Reason.Summary.xls

