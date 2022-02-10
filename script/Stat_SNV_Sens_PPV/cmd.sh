gvcf='YH.vcf'
bed='/data/fulongfei/git_repo/wes_cap_ion/bed_files/YH.bed'
infile='/data/fulongfei/analysis/fsz/agilent_capture_plus_ion_seq_WES/second_seq_2021-12-30/tvc_Beijing_Demo/first_run_2022-1-13/chip1/TSVC_variants.vcf'
name='chip1'
sens=${name}.sens.xls
ppv=${name}.ppv.xls

perl cal_snv_sens_ppv.pl $gvcf $infile $bed $sens $ppv
