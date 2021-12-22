# wes_cap_ion
WES Agilent V6 Capture + Ion Sequencing
This repo is used to calculate the SNV/InDel Sensitivity and PPV from TVC's TSVC_variants.vcf file, which is the final variant call results in Ion Torrent Platform (Torrent Suite Software) 

### Usage
```
perl Stat_Sensitivity_PPV_Main.pl -vcf <*.vcf> -fa <*.fasta|fa> -QUAL <INT> -s <sample_name> -gvcf <*.vcf> -od <outdir>

-vcf  : vcf file
-fa   : reference fasta file
-QUAL : VCF QUAL Column. (Default:10)
-s    : sample name
-gvcf : gold vcf. All the variants in this vcf are seen as True (Default: /Path/raw_394_indel_hs_file/hs_vcf_from_new_rs.vcf)
-od   : outdir
```

### Method
1) use `bcftools norm` to left-align the InDel variants. If one line in TSVC_variants.vcf has >=2 alt alleles, `bcftools norm`'s `-m` will split the alt alleles into multi lines.
2) filter out the `./.` and `0/0` genotype call.
3) filter out the variant which has a low QUAL value.
4) calculate the SNV/InDel Sensitivity and PPV

### Test
* `cd /git_repo/wes_cap_ion/test/not_NA12878_GIAB`
* `sh cmd.sh` will generate a file `*.sens.ppv.sh`
* `sh *.sens.ppv.sh`

The content in `cmd.sh` file are:
```
vcf='/data/fulongfei/git_repo/wes_cap_ion/test/chip1.TSVC_variants.vcf'
fa='/data/fulongfei/database/ref/hg19/hg19.fasta'
sample='chip1'

perl ../../Stat_Sensitivity_PPV_Main.pl -vcf $vcf -fa $fa -s $sample -od $PWD
```

after you `sh *.sens.ppv.sh`, you will find below files:
```
chip1.TSVC_variants.bcfnorm.vcf
chip1.TSVC_variants.bcfnorm.gt_filter.vcf
chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf
chip1.TSVC_variants.bcfnorm.gt_filter.qual_nopass.vcf
chip1.Sensitivity.xls
chip1.PPV.xls
```

##### File Spec
* `<sample_name>.TSVC_variants.bcfnorm.vcf`: the file generate by `bcftools norm`
* `<sample_name>.TSVC_variants.bcfnorm.gt_filter.vcf`: the file generate by filtering out `./.` and `0/0` genotypes
* `<sample_name>.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf`: the file generate by filter out low QUAL
* `<sample_name>.TSVC_variants.bcfnorm.gt_filter.qual_nopass.vcf`: this file contains the low QUAL variants
* `<sample_name>.Sensitivity.xls`: intermediate file used for check sensitivity
* `<sample_name>.PPV.xls`: intermediate file used for check PPV

#### 程序最后给出的统计结果如下（输出到屏幕）
```
[INFO] Check snv/indel sensitivity...
snv_called_num  snv_not_called_num      snv_total_num   snv_sensitivity(%)
39615   7532    47147   84.02
indel_called_num        indel_not_called_num    indel_total_num indel_sensitivity(%)
1723    2216    3939    43.74

[INFO] Check snv/indel PPV...
tvc_snv_tp      tvc_snv_fp      tvc_snv_tp_fp   tvc_snv_PPV(%)
39615   8116    47731   83.00
tvc_indel_tp    tvc_indel_fp    tvc_indel_tp_fp tvc_indel_PPV(%)
1726    894     2620    65.88
```

### FAQ
* 如果只要统计371个InDel位点的灵敏度和特异性，主脚本不必指明`-gvcf`参数
* 如果要统计NA12878样本的SNV、InDel位点的灵敏度、特异性，主脚本请指明`-gvcf`.该git库已经提供了NA12787样本在Agilent V6捕获区间的SNV、InDel位点，具体在：`/path/agilent_v6_giab_vcf/agilent_v6_var_giab.vcf`
* 该repo目前只提供2个文件的统计信息：
    1）371个InDel热点的灵敏度、特异性指标；
    2) NA12787 Agilent V6 WES位点灵敏度、特异性指标；
如果要统计其他BED区域的这两个指标，请自行制作`-gvcf`参数对应的vcf文件（从金标准VCF文件中提取指定BED区域内的变异位点）

