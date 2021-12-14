less /data/fulongfei/bam/fsz/wes_cap_plus_ion/xuehong/V6_S07604514_Covered_chr.bed | awk '{print $1"\t"$2"\t"$3}' >V6.3Col.bed
cat V6.3Col.bed /data/fulongfei/bam/fsz/wes_cap_plus_ion/xuehong/YH.bed >combind.tmp.bed
bedtools merge -i combind.tmp.bed >YH_plus_Agilent_V6.bed

