vcf='test.vcf'
#vcf='bcfnorm.test.vcf'
bcftools norm -f /data/fulongfei/database/ref/hg19/hg19.fasta -m - -c w $vcf >test.bcfnorm.vcf
