# 统计SVN/InDel灵敏度、阳性预测值PPV


## 背景
使用Agilent捕获V6 + Ion测序，评估394个InDel热点的灵敏度、PPV指标

## 运行环境
* Unix/Linux
* Perl (无需安装Perl模块)

## 程序运行方式
```
perl Stat_Sensitivity_PPV_Main.pl -vcf <*.vcf> -fa <*.fasta|fa> -QUAL <INT> -s <sample_name> -gvcf <*.vcf> -od <outdir>

-vcf  : TSVC_variants.vcf文件
-fa   : reference fasta file
-QUAL : VCF QUAL Column. (Default:10) 用于过滤低质量变异位点
-s    : sample name 样本名称
-gvcf : gold vcf. All the variants in this vcf are seen as True (Default: /Path/raw_394_indel_hs_file/hs_vcf_from_new_rs.vcf) 金标准VCF文件. 比较TSVC_variants.vcf和该文件,统计灵敏度和PPV
-od   : outdir
```

运行完主脚本`perl Stat_Sensitivity_PPV_Main.pl ...`之后，会在指定的输出目录生成一个`<sample_name>.sens.ppv.sh`文件，该文件内容如下：
```
bcftools norm -f /data/fulongfei/database/ref/hg19/hg19.fasta -m - -c w /data/fulongfei/git_repo/wes_cap_ion/test/chip1.TSVC_variants.vcf >/data/fulongfei/git_repo/wes_cap_ion/test/NA12878_GIAB/chip1.TSVC_variants.bcfnorm.vcf

perl /data/fulongfei/git_repo/wes_cap_ion/script/filter_bcfnorm_vcf.pl /data/fulongfei/git_repo/wes_cap_ion/test/NA12878_GIAB/chip1.TSVC_variants.bcfnorm.vcf /data/fulongfei/git_repo/wes_cap_ion/test/NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.vcf

perl /data/fulongfei/git_repo/wes_cap_ion/script/filter_QUAL.pl /data/fulongfei/git_repo/wes_cap_ion/test/NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.vcf 10 /data/fulongfei/git_repo/wes_cap_ion/test/NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf >/data/fulongfei/git_repo/wes_cap_ion/test/NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.qual_nopass.vcf

perl /data/fulongfei/git_repo/wes_cap_ion/script/For_giab_NA12878_WES_Sens_PPV.pl /data/fulongfei/git_repo/wes_cap_ion/test/NA12878_GIAB/chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf /data/fulongfei/git_repo/wes_cap_ion/agilent_v6_giab_vcf/agilent_v6_var_giab.vcf chip1 /data/fulongfei/git_repo/wes_cap_ion/test/NA12878_GIAB
```
直接`sh *.sens.ppv.sh`，可以得到最终最终结果。


## 测试
`cd /path/wes_cap_ion/test/NA12878_GIAB/`

`sh cmd.sh`

`sh chip1.sens.ppv.sh`


## 统计方法
1) bcftools norm将TSVC_variants.vcf进行标准化处理

2) 过滤掉`./.`和`0/0`基因型

3) 过滤低质量QUAL位点

4) 根据提供的金标准VCF文件，统计灵敏度、PPV



## 结果文件说明
```
./
├── chip1.PPV.xls
├── chip1.Sensitivity.xls
├── chip1.sens.ppv.sh
├── chip1.TSVC_variants.bcfnorm.gt_filter.qual_nopass.vcf
├── chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf
├── chip1.TSVC_variants.bcfnorm.gt_filter.vcf
├── chip1.TSVC_variants.bcfnorm.vcf
└── cmd.sh
```

* `chip1.TSVC_variants.bcfnorm.vcf`：bcf norm之后的vcf文件
* `chip1.TSVC_variants.bcfnorm.gt_filter.vcf`：bcf norm结果文件经过genotype过滤后的vcf文件
* `chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf`：gt过滤后的文件经过QUAL过滤后的文件
* `chip1.TSVC_variants.bcfnorm.gt_filter.qual_nopass.vcf`：低质量QUAL的位点
* `chip1.Sensitivity.xls`：统计灵敏度的中间结果文件，方便核实位点
* `chip1.PPV.xls`：统计PPV的中间结果文件


**`*.Sensitivity.xls`文件格式如下：**

```
Called  SNV     chr1    808922  G       A       1       808922  rs6594027       G       A       50      PASS
    platforms=3;platformnames=PacBio,Illumina,10X;datasets=3;datasetnames=CCS15kb_20kb,HiSeqPE300x,10XChromiumLR;callsets=5;callsetnames=CCS15kb_20kbDV,CCS15kb_20kbGATK4,HiSeqPE300xGATK,10XLRGATK,HiSeqPE300xfreebayes;datasetsmissingcall=CGnormal,IonExome,SolidSE75bp;callable=CS_CCS15kb_20kbDV_callable,CS_CCS15kb_20kbGATK4_callable;difficultregion=HG001.hg37.300x.bam.bilkentuniv.010920.dups,hg19.segdups_sorted_merged,lowmappabilityall_GRCh38equivalent,mm-2-merged  GT:PS:DP:ADALL:AD:GQ    1/1:.:608:0,242:0,52:153
Called  SNV     chr1    808928  C       T       1       808928  rs11240780      C       T       50      PASS
    platforms=3;platformnames=PacBio,Illumina,10X;datasets=3;datasetnames=CCS15kb_20kb,HiSeqPE300x,10XChromiumLR;callsets=5;callsetnames=CCS15kb_20kbDV,CCS15kb_20kbGATK4,HiSeqPE300xGATK,10XLRGATK,HiSeqPE300xfreebayes;datasetsmissingcall=CGnormal,IonExome,SolidSE75bp;callable=CS_CCS15kb_20kbDV_callable,CS_CCS15kb_20kbGATK4_callable;difficultregion=HG001.hg37.300x.bam.bilkentuniv.010920.dups,hg19.segdups_sorted_merged,lowmappabilityall_GRCh38equivalent,mm-2-merged  GT:PS:DP:ADALL:AD:GQ    1/1:.:603:0,236:0,52:157
NotCalled       InDel   chr1    874950  T       TCCCTGGAGGACC   1       874950  rs79212057      T       TCCCTGGAGGACC   50      PASS    platforms=4;platformnames=Illumina,PacBio,CG,10X;datasets=4;datasetnames=HiSeqPE300x,CCS15kb_20kb,CGnormal,10XChromiumLR;callsets=6;callsetnames=HiSeqPE300xGATK,CCS15kb_20kbDV,CCS15kb_20kbGATK4,CGnormal,HiSeqPE300xfreebayes,10XLRGATK;datasetsmissingcall=IonExome,SolidSE75bp;callable=CS_HiSeqPE300xGATK_callable,CS_CCS15kb_20kbDV_callable,CS_10XLRGATK_callable,CS_CCS15kb_20kbGATK4_callable,CS_CGnormal_callable,CS_HiSeqPE300xfreebayes_callable;filt=CS_CCS15kb_20kbGATK4_filt     GT:PS:DP:ADALL:AD:GQ    0/1:.:675:125,127:186,180:587
```

* 第一列为`Called`或`NotCalled`
* 第二列为`SNV`或`InDel`
* 第三列之后为金标准VCF信息，没有变化
>标注第一列、第二列是为了方便核实结果，快速查找哪些没检出


**`*.PPV.xls`文件格式如下：**

```
FP      SNV     chr1    14907   A       G       chr1    14907   .       A       G       1448.65 PASS    AF=0.935484;AO=172;DP=185;FAO=174;FDP=186;FDVR=5;FR=.;FRO=12;FSAF=96;FSAR=78;FSRF=9;FSRR=3;FWDB=0.0130824;FXX=0.00534731;HRUN=2;HS_ONLY=0;LEN=1;MLLD=69.5713;OALT=G;OID=.;OMAPALT=G;OPOS=14907;OREF=A;PB=0.5;PBP=1;QD=31.1537;RBI=0.0239989;REFB=-0.0141307;REVB=0.0201196;RO=11;SAF=94;SAR=78;SRF=8;SRR=3;SSEN=0;SSEP=0;SSSB=-0.02086;STB=0.512964;STBP=0.168;TYPE=snp;VARB=0.00512409 GT:GQ:DP:FDP:RO:FRO:AO:FAO:AF:SAR:SAF:SRF:SRR:FSAR:FSAF:FSRF:FSRR       1/1:18:185:186:11:12:172:174:0.935484:78:94:8:3:78:96:9:3
FP      SNV     chr1    14930   A       G       chr1    14930   .       A       G       1886.14 PASS    AF=0.9375;AO=225;DP=242;FAO=225;FDP=240;FDVR=10;FR=.;FRO=15;FSAF=120;FSAR=105;FSRF=9;FSRR=6;FWDB=0.0033383;FXX=0.00826412;HRUN=2;HS_ONLY=0;LEN=1;MLLD=140.61;OALT=G;OID=.;OMAPALT=G;OPOS=14930;OREF=A;PB=0.5;PBP=1;QD=31.4356;RBI=0.016784;REFB=-0.022664;REVB=-0.0164486;RO=15;SAF=120;SAR=105;SRF=9;SRR=6;SSEN=0;SSEP=0;SSSB=-0.00796051;STB=0.504187;STBP=0.587;TYPE=snp;VARB=0.00138538     GT:GQ:DP:FDP:RO:FRO:AO:FAO:AF:SAR:SAF:SRF:SRR:FSAR:FSAF:FSRF:FSRR
       1/1:23:242:240:15:15:225:225:0.9375:105:120:9:6:105:120:9:6
TP      SNV     chr1    762273  G       A       chr1    762273  .       G       A       346.704 PASS    AF=0.725;AO=23;DP=38;FAO=29;FDP=40;FDVR=5;FR=.,.;FRO=1;FSAF=15;FSAR=14;FSRF=1;FSRR=0;FWDB=0.0781881;FXX=0.0243843;HRUN=2;HS_ONLY=0;LEN=1;MLLD=72.6161;OALT=A,C;OID=.,.;OMAPALT=A,C;OPOS=762273,762273;OREF=G,G;PB=0.5;PBP=1;QD=34.6704;RBI=0.078401;REFB=-0.150984;REVB=0.0057741;RO=1;SAF=14;SAR=9;SRF=1;SRR=0;SSEN=0;SSEP=0;SSSB=-0.0319244;STB=0.516118;STBP=0.525;TYPE=snp;VARB=0.00340131  GT:GQ:DP:FDP:RO:FRO:AO:FAO:AF:SAR:SAF:SRF:SRR:FSAR:FSAF:FSRF:FSRR
       1/0:22:38:40:1:1:23:29:0.725:9:14:1:0:14:15:1:0
```

* 第一列为`TP`或`FP`，即TP：真阳性，FP：假阳性
* 第二列为`SNV`或`InDel`


### 最终结果格式（输出到屏幕）
> 注：该例是NA12878 WES统计结果，包含了SNV信息。如果只统计371个INDEL位点，结果格式略有差异。
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


## 程序文件说明
```
fulongfei@ion-bfx:/data/fulongfei/git_repo/wes_cap_ion$ ll
total 64
drwxrwxr-x 11 fulongfei fulongfei 4096 Dec 22 16:54 ./
drwxr-xr-x  9 fulongfei fulongfei 4096 Dec 20 15:10 ../
drwxrwxr-x  2 fulongfei fulongfei 4096 Dec 21 10:35 agilent_v6_giab_vcf/
drwxrwxr-x  3 fulongfei fulongfei 4096 Dec 14 14:20 bed_files/
drwxrwxr-x  2 fulongfei fulongfei 4096 Dec 22 14:41 data/
drwxrwxr-x  8 fulongfei fulongfei 4096 Dec 22 16:54 .git/
-rw-rw-r--  1 fulongfei fulongfei   39 Dec 21 15:23 .gitignore
drwxrwxr-x  2 fulongfei fulongfei 4096 Dec 21 11:00 indel_hs_files/
-rw-rw-r--  1 fulongfei fulongfei 1060 Dec 14 14:12 LICENSE
drwxrwxr-x  2 fulongfei fulongfei 4096 Dec 21 11:01 raw_394_indel_hs_file/
-rw-rw-r--  1 fulongfei fulongfei 3536 Dec 22 16:54 README.md
drwxrwxr-x  2 fulongfei fulongfei 4096 Dec 22 14:53 script/
-rw-rw-r--  1 fulongfei fulongfei  522 Dec 21 15:18 Seq_Depth_Stat.QC.pl
-rw-rw-r--  1 fulongfei fulongfei 3097 Dec 22 15:44 Stat_Sensitivity_PPV_Main.pl
drwxrwxr-x  4 fulongfei fulongfei 4096 Dec 22 15:36 test/
drwxrwxr-x  2 fulongfei fulongfei 4096 Dec 17 12:03 tvc_json/
lrwxrwxrwx  1 fulongfei fulongfei   40 Dec 16 16:11 wes_cap_plus_ion -> /data/fulongfei/bam/fsz/wes_cap_plus_ion/
```

**目录agilent_v6_giab_vcf/包含：**
```
├── agilent_v6_var_giab.vcf
├── cmd.sh
└── get_wes_var_from_giab_vcf.pl
```
* `agilent_v6_var_giab.vcf`是从NA12878 giab vcf文件中提取的仅出现在Agilent V6 BED区域内的SNV、InDel位点.

**目录bed_files/包含：**
```
├── merge_bed
│   ├── cmd.sh
│   ├── combind.tmp.bed
│   ├── V6.3Col.bed
│   └── YH_plus_Agilent_V6.bed
├── V6_S07604514_Covered_chr.bed
└── YH.bed
```
* `V6_S07604514_Covered_chr.bed`是FSZ提供的Agilent V6 BED文件。大约60M区域。
* `YH.bed`是雪红提供的中检院WES考察范围BED文件，大约20M+区域。
* `YH_plus_Agilent_V6.bed`是将上面两个BED合并之后的BED文件。

**data/目录包含：**
```
./
└── TSVC_variants.vcf

```
* 该文件是一个测试数据，流程不需要用到

**indel_hs_files/目录包含：**
```
./
├── cmd.sh
├── dbSNP.5000rs.random.vcf
├── dbSNP_in_bed_region.vcf
├── extract_dbSNP_in_BED.pl
├── hs_vcf_from_new_rs.vcf
├── merge_394indelHS_and_wes_randomHS.pl
├── tvc.hs.make.log
├── wes.hs.2021_12_17.bed
└── wes_snv_indel_hs.vcf
```

* `extract_dbSNP_in_BED.pl`是从dbSNP build 155数据库中提取指定BED区域内的变异位点的脚本
* `dbSNP_in_bed_region.vcf`是从指定BED提取出的dbSNP vcf文件
* `dbSNP.5000rs.random.vcf`是从`dbSNP_in_bed_region.vcf`文件中随机抽取的5000个SNV/InDel位点
* `hs_vcf_from_new_rs.vcf`是371个InDel热点文件的变异信息，根据indel rs号从dbSNP v155中提取得到。（原始indel位点有394个，有23个没有在dbSNP build v155中找到）
* `wes_snv_indel_hs.vcf`是合并`hs_vcf_from_new_rs.vcf`和`dbSNP.5000rs.random.vcf`之后的vcf文件，用于TVC热点vcf
* `wes.hs.2021_12_17.bed`是将`wes_snv_indel_hs.vcf`转化为BED文件，这个BED文件需要上传到TS的TVC插件中，作为热点文件

**raw_394_indel_hs_file/目录包含：**
```
./
├── hs.txt
├── hs_vcf_from_new_rs.vcf
└── old_rs_new_rs.xls
```
* `hs.txt`是雪红提供的原始的394个indel位点信息

**script/目录包含：**
```
./
├── cmd.sh
├── filter_bcfnorm_vcf.pl
├── filter_QUAL.pl
├── For_giab_NA12878_WES_Sens_PPV.pl
├── high_pop_alt_freq_from_dbSNP.InDel.vcf
├── Only_InDel_Sens_PPV.pl
├── prepare_indel_hs_vcf.pl
└── stat_dbSNP_v155_db_source.pl
```

* 程序用到的脚本在这个目录

**test/目录包含：**
```
./
├── chip1.filtered.vcf -> /data/fulongfei/bam/fsz/wes_cap_plus_ion/chip1/variantCaller_out.6/small_variants_filtered.vcf
├── chip1.TSVC_variants.vcf
├── NA12878_GIAB
│   ├── chip1.PPV.xls
│   ├── chip1.Sensitivity.xls
│   ├── chip1.sens.ppv.sh
│   ├── chip1.TSVC_variants.bcfnorm.gt_filter.qual_nopass.vcf
│   ├── chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf
│   ├── chip1.TSVC_variants.bcfnorm.gt_filter.vcf
│   ├── chip1.TSVC_variants.bcfnorm.vcf
│   └── cmd.sh
├── not_NA12878_GIAB
│   ├── chip1.PPV.xls
│   ├── chip1.Sensitivity.xls
│   ├── chip1.sens.ppv.sh
│   ├── chip1.TSVC_variants.bcfnorm.gt_filter.qual_nopass.vcf
│   ├── chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf
│   ├── chip1.TSVC_variants.bcfnorm.gt_filter.vcf
│   ├── chip1.TSVC_variants.bcfnorm.vcf
│   └── cmd.sh
└── TSVC_variants.vcf -> /data/fulongfei/bam/fsz/wes_cap_plus_ion/chip1/variantCaller_out.6/TSVC_variants.vcf
```

* `test/`目录下包含两个测试目录：`NA12878_GIAB/`目录和`not_NA12878_GIAB/`目录。

**tvc_json/目录包含：**
```
./
└── ampliseqexome_germline_lowstringency_540_550_parameters_5.8.json
```
* 该json文件是参数优化之后的tvc json参数文件，雪红提供


## FAQ
* 如果只要统计371个InDel位点的灵敏度和特异性，主脚本不必指明`-gvcf`参数
* 如果要统计NA12878样本的SNV、InDel位点的灵敏度、特异性，主脚本请指明`-gvcf`.该git库已经提供了NA12787样本在Agilent V6捕获区间的SNV、InDel位点，具体在：`/path/agilent_v6_giab_vcf/agilent_v6_var_giab.vcf`
* 该repo目前只提供2个文件的统计信息：
1) 371个InDel热点的灵敏度、特异性指标；
2) NA12787 Agilent V6 WES位点灵敏度、特异性指标；

>如果要统计其他BED区域的这两个指标，请自行制作`-gvcf`参数对应的vcf文件（从金标准VCF文件中提取指定BED区域内的变异位点）