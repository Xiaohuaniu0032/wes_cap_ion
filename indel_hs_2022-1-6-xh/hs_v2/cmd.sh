cat YH-indel.over-write.params.bed wes.blist.bed >YH.indel.v2.bed


#hsbed="$PWD/FSZ_202A_hotspots.210906.bed"
#hsbed='../YH-indel.bed'
hsbed='YH.indel.v2.bed'
ref='/data/fulongfei/database/ref/hg19/hg19.fasta'

/data/fulongfei/git_repo/ion-tvc/bin/5.8/tvcutils prepare_hotspots -b $hsbed -r $ref --left-alignment on --allow-block-substitutions on -o YH-indel.hs.v2.vcf
