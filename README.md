# 统计SNV/InDel灵敏度、阳性预测值PPV


## 背景
使用Agilent捕获V6 + Ion测序，评估394个InDel热点的灵敏度、PPV指标

## 运行环境
* Unix/Linux
* Perl (无需安装Perl模块)
* bcftools

## 程序运行方式
```
perl Stat_Sensitivity_PPV_Main.pl -vcf <*.vcf> -fa <*.fasta|fa> -QUAL <INT> -s <sample_name> -gvcf <*.vcf> -od <outdir>

-vcf  : TSVC_variants.vcf文件
-fa   : reference fasta file
-QUAL : VCF QUAL Column. (Default:10) 用于过滤低质量变异位点
-s    : sample name 样本名称
-gvcf : gold vcf. All the variants in this vcf are seen as True (Default: /Path/wes_cap_ion/indel_hs_2022-1-6-xh/YH-indel.vcf) 金标准VCF文件. 比较TSVC_variants.vcf和该文件,统计灵敏度和PPV
-od   : outdir
```

运行完主脚本`perl Stat_Sensitivity_PPV_Main.pl ...`之后，会在指定的输出目录生成一个`<sample_name>.sens.ppv.sh`文件。直接`sh *.sens.ppv.sh`，可以得到最终结果。也可分步骤测试。


## 测试
`cd /path/wes_cap_ion/test/NA12878_GIAB/`

`sh cmd.sh`

`sh chip1.sens.ppv.sh`


## 统计方法
1) bcftools norm将TSVC_variants.vcf进行标准化处理

2) 过滤掉`./.`和`0/0`基因型

3) 过滤低质量QUAL位点

4) 根据提供的金标准VCF文件，统计灵敏度、PPV

5) 输出热点深度信息、NoCall Reason



## 结果文件说明
```
chip1.sens.ppv.sh
chip1.TSVC_variants.bcfnorm.vcf
chip1.TSVC_variants.bcfnorm.gt_filter.vcf
chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf
chip1.TSVC_variants.bcfnorm.gt_filter.qual_nopass.vcf
chip1.Sensitivity.xls
chip1.Sens_PPV_Summary.xls
chip1.PPV.xls
chip1.TVC.Info.Sens.xls
chip1.TVC.Info.PPV.xls
chip1.HS.InDel.Depth.Summary.xls
chip1.HS.InDel.NoCall.Reason.Summary.xls
```

| 文件名 | 说明 |
| --- | --- |
| chip1.sens.ppv.sh | 待执行的shell脚本 |
| chip1.TSVC_variants.bcfnorm.vcf | `TSVC_variants.vcf`经过bcftools norm之后的文件|
| chip1.TSVC_variants.bcfnorm.gt_filter.vcf | `*.bcfnorm.vcf`文件经过GT过滤后的文件|
| chip1.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf | `*.bcfnorm.gt_filter.vcf`文件经过`QUAL`过滤
| chip1.Sensitivity.xls | 灵敏度文件
| chip1.PPV.xls | PPV文件 |
| chip1.Sens_PPV_Summary.xls | 灵敏度、PPV总结文件 |
| chip1.TVC.Info.Sens.xls | 金标准位点的TVC信息（深度、RBI、FR、AF等）|
| chip1.TVC.Info.PPV.xls | TVC阳性位点的TVC信息 |
| chip1.HS.InDel.Depth.Summary.xls | 热点测序深度总结文件 |
| chip1.HS.InDel.NoCall.Reason.Summary.xls | 未被TVC检出的金标准位点的FR |


##文件格式说明

`*.Sensitivity.xls`格式：

```
Called  chr1    17084536        .       TGGAACA T       .       PASS    platforms=5;platformnames=BGISEQ-500,MG
ISEQ-2000,NextSeq-CN500,NextSeq550Dx,NovaSeq6000;callsets=15;callsetnames=BGISEQ-500_HJ-1,BGISEQ-500_HJ-2,BGISE
Q-500_HJ-3,MGISEQ-2000_HJ-1,MGISEQ-2000_HJ-2,MGISEQ-2000_HJ-3,NextSeq-CN500_HJ-1,NextSeq-CN500_HJ-2,NextSeq-CN5
00_HJ-3,NextSeq550Dx_HJ-1,NextSeq550Dx_HJ-2,NextSeq550Dx_HJ-3,NovaSeq6000_HJ-1,NovaSeq6000_HJ-2,NovaSeq6000_HJ-
3;filt=0    GT:DP:ADALL:AD:GQ       0/1:3397:2578,817:2578,817:99
NotCalled       chr1    17086085        rs771454570     G       GC      .       PASS    platforms=5;platformnames=BGISEQ-500,MGISEQ-2000,NextSeq-CN500,NextSeq550Dx,NovaSeq6000;callsets=9;callsetnames=BGISEQ-500_HJ-1,BGISEQ-500_HJ-2,BGISEQ-500_HJ-3,MGISEQ-2000_HJ-1,MGISEQ-2000_HJ-2,MGISEQ-2000_HJ-3,NextSeq550Dx_HJ-1,NextSeq550Dx_HJ-3,NovaSeq6000_HJ-1;filt=0  GT:DP:ADALL:AD:GQ       0/1:477:329,148:329,148:99
NotCalled       chr1    17087541        rs113982165     GGTGCT  G       .       PASS    platforms=5;platformnames=BGISEQ-500,MGISEQ-2000,NextSeq-CN500,NextSeq550Dx,NovaSeq6000;callsets=15;callsetnames=BGISEQ-500_HJ-1,BGISEQ-500_HJ-2,BGISEQ-500_HJ-3,MGISEQ-2000_HJ-1,MGISEQ-2000_HJ-2,MGISEQ-2000_HJ-3,NextSeq-CN500_HJ-1,NextSeq-CN500_HJ-2,NextSeq-CN500_HJ-3,NextSeq550Dx_HJ-1,NextSeq550Dx_HJ-2,NextSeq550Dx_HJ-3,NovaSeq6000_HJ-1,NovaSeq6000_HJ-2,NovaSeq6000_HJ-3;filt=BGISEQ-500   GT:DP:ADALL:AD:GQ       0/1:3099:2664,435:2430,394:99
Called  chr1    17718671        rs10709483      AG      A       .       PASS    platforms=5;platformnames=BGISEQ-500,MGISEQ-2000,NextSeq-CN500,NextSeq550Dx,NovaSeq6000;callsets=13;callsetnames=BGISEQ-500_HJ-1,BGISEQ-500_HJ-2,BGISEQ-500_HJ-3,MGISEQ-2000_HJ-1,MGISEQ-2000_HJ-2,MGISEQ-2000_HJ-3,NextSeq-CN500_HJ-3,NextSeq550Dx_HJ-1,NextSeq550Dx_HJ-2,NextSeq550Dx_HJ-3,NovaSeq6000_HJ-1,NovaSeq6000_HJ-2,NovaSeq6000_HJ-3;filt=0  GT:DP:ADALL:AD:GQ
       1/1:1002:0,1002:0,1002:99
```

第一列：`Called` OR `NotCalled`。

第二列及之后的列是gold vcf的信息。该文件是为了方便筛选哪些位点没有检出，用于后续debug。

`*.PPV.xls`格式：

```
TP      chr1    153233488       rs150026164     C       CGGCGGT 19.9908 PASS    AF=0.214286;AO=9;DP=42;FAO=9;FD
P=42;FDVR=10;FR=.;FRO=33;FSAF=2;FSAR=7;FSRF=15;FSRR=18;FWDB=-0.042629;FXX=0.0232504;HRUN=2;HS_ONLY=0;LEN=6;MLLD
=260.833;OALT=GGCGGT;OID=rs150026164;OMAPALT=CGGCGGT;OPOS=153233489;OREF=-;PB=0.5;PBP=1;QD=1.90388;RBI=0.042750
8;REFB=0.000519032;REVB=0.0032245;RO=33;SAF=2;SAR=7;SRF=15;SRR=18;SSEN=0;SSEP=0;SSSB=-0.308492;STB=0.703653;STB
P=0.224;TYPE=ins;VARB=-0.00176386;HS        GT:GQ:DP:FDP:RO:FRO:AO:FAO:AF:SAR:SAF:SRF:SRR:FSAR:FSAF:FSRF:FSRR
       0/1:19:42:42:33:33:9:9:0.214286:7:2:15:18:7:2:15:18
FP      chr1    156354347       rs11303415      TCC     T       491.45  PASS    AF=0.545455;AO=25;DP=75;FAO=36;FDP=66;FDVR=0;FR=.,.;FRO=0;FSAF=24;FSAR=12;FSRF=0;FSRR=0;FWDB=0.103653;FXX=0.119984;HRUN=8;HS_ONLY=0;LEN=2;MLLD=13.0888;OALT=-,-;OID=.,rs11303415;OMAPALT=T,TC;OPOS=156354348,156354348;OREF=CC,C;PB=0.5;PBP=1;QD=29.7849;RBI=0.10779;REFB=0;REVB=0.0295782;RO=3;SAF=15;SAR=10;SRF=3;SRR=0;SSEN=0;SSEP=0;SSSB=-0.0841887;STB=0.5;STBP=1;TYPE=del;VARB=0.0666424;HS       GT:GQ:DP:FDP:RO:FRO:AO:FAO:AF:SAR:SAF:SRF:SRR:FSAR:FSAF:FSRF:FSRR       1/0:76:75:66:3:0:25:36:0.545455:10:15:3:0:12:24:0:0
TP      chr1    156354347       rs11303415      TC      T       491.45  PASS    AF=0.454545;AO=37;DP=75;FAO=30;FDP=66;FDVR=0;FR=.,.;FRO=0;FSAF=15;FSAR=15;FSRF=0;FSRR=0;FWDB=0.201798;FXX=0.119984;HRUN=8;HS_ONLY=0;LEN=1;MLLD=10.149;OALT=-,-;OID=.,rs11303415;OMAPALT=T,TC;OPOS=156354348,156354348;OREF=CC,C;PB=0.5;PBP=1;QD=29.7849;RBI=0.209722;REFB=0;REVB=0.0571024;RO=3;SAF=20;SAR=17;SRF=3;SRR=0;SSEN=0;SSEP=0;SSSB=-0.0652174;STB=0.5;STBP=1;TYPE=del;VARB=-0.0808103;HS      GT:GQ:DP:FDP:RO:FRO:AO:FAO:AF:SAR:SAF:SRF:SRR:FSAR:FSAF:FSRF:FSRR       0/1:76:75:66:3:0:37:30:0.454545:17:20:3:0:15:15:0:0
```

第一列：`TP` OR `FP` (TP: Ture Positive; FP: False Positive)

第二列及之后的列是`*.bcfnorm.gt_filter.qual_pass.vcf`文件中的信息，该文件中的位点是经过GT、QUAL过滤之后的阳性位点。

> 注：`*.PPV.xls`文件生成过程如下：

> 1）读取`*.bcfnorm.gt_filter.qual_pass.vcf`文件；

> 2）判断该位点是否在YH.bed区间中（~27M。在该区间内检出的InDel位点，除了390+个InDel热点，其余InDel位点均未FP）

> 3）如果该位点在gold vcf文件中，其alt allele数目大于等于2个，则跳过这个位点[不好统计multi alt allele的检出，需要同时考虑2个alt allele是否同时检出]（GIAB NA12878 vcf文件中，具有>=2个突变的变异数~1%，跳过这些点不会影响PPV的统计。）

> 4）根据Ref和Alt长度，判断是否是InDel位点

`*.Sens_PPV_Summary.xls`格式：
```
indel_called_num        indel_not_called_num    indel_total_num indel_sensitivity(%)
290     101     391     74.17

TP_indel_num    FP_indel_num    TP_FP_indel_num PPV
302     10      312     96.79
```

第一部分为灵敏度指标，第二部分为PPV指标。

`*.TVC.Info.Sens.xls`格式：

```
#If_Call        HS_Var  HS_GT   TVC_QUAL        TVC_MLLD        TVC_STB TVC_RBI TVC_RESULT      TVC_FR  TVC_AO
  TVC_FAO TVC_DP  TVC_FDP TVC_AF  TVC_GT
Called  chr1.1116188.CG.C       GT=0/1  GQ=327  MLLD=20.973     STB=0.525444    RBI=0.169021    PASS    FR=.
    AO=68   FAO=66  DP=126  FDP=111 AF=0.594595     GT=0/1
Called  chr1.1887091.CG.C       GT=0/1  GQ=187  MLLD=296.192    STB=0.52173     RBI=0.013748    PASS    FR=.
    AO=43   FAO=47  DP=113  FDP=104 AF=0.451923     GT=0/1
NotCalled       chr1.17086085.G.GC      GT=0/1  GQ=6    MLLD=18.3047    STB=0.991174    RBI=0.0754898   NOCALL
  FR=.&QualityScore<10    AO=1    FAO=1   DP=36   FDP=29  AF=0.0344828    GT=./.
```
该文件输出了gold vcf中每个位点在TVC中的一些QC指标。方便检查NotCalled位点的QC信息及FR原因。


`*.TVC.Info.PPV.xls`格式：

```
#TP_or_FP       HS_Var  HS_GT   TVC_QUAL        TVC_MLLD        TVC_STB TVC_RBI TVC_RESULT      TVC_FR  TVC_AO
  TVC_FAO TVC_DP  TVC_FDP TVC_AF  TVC_GT
TP      chr1.1116188.CG.C       GT=0/1  GQ=327  MLLD=20.973     STB=0.525444    RBI=0.169021    PASS    FR=.
    AO=68   FAO=66  DP=126  FDP=111 AF=0.594595     GT=0/1
FP      chr1.156354347.TCC.T    GT=1/0  GQ=491  MLLD=13.0888    STB=0.5 RBI=0.10779     PASS    FR=.,.  AO=25
   FAO=36  DP=75   FDP=66  AF=0.545455     GT=1/0
```
该文件输出了TVC检出的阳性位点的QC信息。方便检查假阳性的QC指标。

`*.Depth.Summary.xls`格式：

```
Chr     Pos     Ref     Alt     AO      FAO     DP      FDP
chr1    1116188 CG      C       68      66      126     111
chr1    1887091 CG      C       43      47      113     104
chr1    1887111 GC      G       55      55      124     113
chr1    1900106 T       TCTC    68      70      170     166
......
......
chrX    153149708       G       GC      51      51      53      51
chrX    153151280       G       GCC     2       2       2       2
###### Depth Summary Info ######
Depth(Raw_DP)   Num     Total_Num       Pct(%)
>=5X    372     391     95.14
>=10X   359     391     91.82
>=20X   333     391     85.17
```

该文件上部分列出了每个热点的深度，最底下列出了深度的统计信息。

`*.NoCall.Reason.Summary.xls`格式：

```
NoCallReason    Num     Total_Num       Pct(%)
Ref_Call        25      101     24.75
Low_Cov 46      101     45.54
NODATA  6       101     5.94
PREDICTIONSHIFT 4       101     3.96
Others  20      101     19.80



###### Other's FR ######
FR=.&QualityScore<10    9
FR=.&REJECTION  2
FR=.&QualityScore<10&REJECTION  1
FR=.&QualityScore<10,.  1
FR=.&QualityScore<10&STDBIAS0.996446>0.95&STDBIASPVAL0.07<1     1
FR=.&QualityScore<10&STDBIAS0.989266>0.95&STDBIASPVAL0.5<1      1
FR=.&QualityScore<10&STDBIAS0.998549>0.95&STDBIASPVAL0<1        1
FR=.&STRINGENCY&HPLEN,. 1
FR=.&QualityScore<10&STDBIAS0.98873>0.95&STDBIASPVAL0.485<1     1
FR=.&HPLEN      1
FR=.&QualityScore<10&STDBIAS0.986277>0.95&STDBIASPVAL0.532<1    1
```
该文件上部分列出了NoCall的分类，每个类别的数量，百分比。


下部分列出了`Others`部分（不好明确分类）的具体FR及其数量。


## FAQ

