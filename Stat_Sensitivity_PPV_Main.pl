use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use FindBin qw/$Bin/;

my ($TSVC_variants_vcf_file,$fasta,$QUAL_cutoff,$sample_name,$gold_vcf_file,$outdir);

GetOptions(
	"vcf:s"  => \$TSVC_variants_vcf_file,             # Need
	"fa:s"   => \$fasta,                              # Need
	"QUAL:i" => \$QUAL_cutoff,                        # Optional <Default: 10>
	"s:s"    => \$sample_name,                        # Need
	"gvcf:s" => \$gold_vcf_file,                      # Optional <Default: Bin/indel_hs_2022-1-6-xh/YH-indel.vcf>
	"od:s"   => \$outdir,                             # Need
	) or die "unknown args\n";


# check args
if (not defined $TSVC_variants_vcf_file || not defined $fasta || not defined $sample_name || not defined $outdir){
	die "please check your args\n";
}

# default value
if (not defined $QUAL_cutoff){
	$QUAL_cutoff = 10;
}

if (not defined $gold_vcf_file){
	$gold_vcf_file = "$Bin/indel_hs_2022-1-6-xh/YH-indel.vcf";
}

if (!-e $gold_vcf_file){
	die "can not find gold vcf to compare: $gold_vcf_file\n";
}


# process steps
# 1. bcftools norm
# 2. remove 0/0 and ./. genotype <0/0 is ref call, and ./. is the NOCALL
# 3. filter by QUAL
# 4. stat sensitivity and PPV according the gold vcf file

my $runsh = "$outdir/$sample_name\.sens.ppv.sh";
open O, ">$runsh" or die;

# step0: remove dup vars in TSVC_variants.vcf
my $rmdup_vcf = "$outdir/$sample_name\.TSVC_variants.rmdup.vars.vcf";
my $log = "$outdir/rm.dup.log";
if (-e $log){
	`rm $log`;
}
my $cmd = "perl $Bin/script/rmdup_vars.pl $TSVC_variants_vcf_file $rmdup_vcf";
print O "$cmd\n\n";

# step1: bcf norm => indel left align and indel unify presentation
# see https://samtools.github.io/bcftools/bcftools.html#norm for detail.
# -m:split multiallelics (-) or join biallelics (+)
# -c:check REF alleles and exit (e), warn (w), exclude (x), or set (s)

my $norm_vcf = "$outdir/$sample_name\.TSVC_variants.bcfnorm.vcf";
#$cmd = "bcftools norm -f $fasta -m - -c w $TSVC_variants_vcf_file >$norm_vcf";
$cmd = "bcftools norm -f $fasta -m - -c w $rmdup_vcf >$norm_vcf";
print O "$cmd\n\n";

# bcf norm again will generate dup tvc
my $norm_rmdup_vcf = "$outdir/$sample_name\.TSVC_variants.bcfnorm.rmdup.vcf";
$cmd = "perl $Bin/script/rmdup_vars.pl $norm_vcf $norm_rmdup_vcf";
print O "$cmd\n\n";

# step2: remove 0/0 and ./. genotype call
my $gt_filter_vcf = "$outdir/$sample_name\.TSVC_variants.bcfnorm.gt_filter.vcf";
$cmd = "perl $Bin/script/filter_bcfnorm_vcf.pl $norm_rmdup_vcf $gt_filter_vcf";
print O "$cmd\n\n";

# step3: filter QUAL
my $qual_pass_vcf = "$outdir/$sample_name\.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf";
my $qual_nopass_vcf = "$outdir/$sample_name\.TSVC_variants\.bcfnorm.gt_filter.qual_nopass.vcf";
$cmd = "perl $Bin/script/filter_QUAL.pl $gt_filter_vcf $QUAL_cutoff $qual_pass_vcf \>$qual_nopass_vcf";
print O "$cmd\n\n";

# step4: stat sensitivity and PPV according the gold vcf file
my $gvcf_name = basename $gold_vcf_file;
if ($gvcf_name eq "YH-indel.vcf"){
	# three output file
	my $Sens_file = "$outdir/$sample_name\.Sensitivity.xls";
	my $PPV_file  = "$outdir/$sample_name\.PPV.xls";
	my $Sens_PPV_Summary_file = "$outdir/$sample_name\.Sens_PPV_Summary.xls";

	# Sens
	$cmd = "perl $Bin/script/Stat_Sensitivity.pl $qual_pass_vcf $gold_vcf_file $sample_name $Sens_file $Sens_PPV_Summary_file";
	print O "$cmd\n\n";

	# PPV
	my $YH_27M_BED_file = "$Bin/bed_files/YH.bed";
	$cmd = "perl $Bin/script/Stat_PPV.pl $qual_pass_vcf $YH_27M_BED_file $gold_vcf_file $PPV_file $Sens_PPV_Summary_file";
	print O "$cmd\n\n";

	# Output Sens TVC Call Detail
	my $Sens_TVC_detail_outfile = "$outdir/$sample_name\.TVC.Info.Sens.xls";
	$cmd = "perl $Bin/script/Check_Sens_TVC_Detail.pl $Sens_file $norm_vcf $Sens_TVC_detail_outfile";
	print O "$cmd\n\n";

	# Output PPV TVC Call Detail
	my $PPV_TVC_detail_outfile  = "$outdir/$sample_name\.TVC.Info.PPV.xls";	
	$cmd = "perl $Bin/script/Check_PPV_TVC_Detail.pl $PPV_file $PPV_TVC_detail_outfile";
	print O "$cmd\n\n";

	# Summary HS Depth
	my $depth_summary_file = "$outdir/$sample_name\.HS.InDel.Depth.Summary.xls";
	$cmd = "perl $Bin/script/HS_InDel_Depth_Summary.pl $Sens_TVC_detail_outfile $depth_summary_file";
	print O "$cmd\n\n";

	# Summary NoCall Reason
	my $NoCall_summary_file = "$outdir/$sample_name\.HS.InDel.NoCall.Reason.Summary.xls";
	$cmd = "perl $Bin/script/HS_InDel_NoCall_Reason_Summary.pl $Sens_TVC_detail_outfile $NoCall_summary_file";
	print O "$cmd\n\n";

	# Make TVC Pos BED (used to check tp and fp vars)
	my $tp_fp_bed = "$outdir/$sample_name\.TP.FP.BED";
	$cmd = "perl $Bin/script/Make_TP_FP_BED.pl $PPV_file $tp_fp_bed";
	print O "$cmd\n\n";

	# plot TP vs FP's MLLD & RBI plot
	my $tp_fp_table = "$outdir/$sample_name\.TP.FP.MLLD.RBI.xls";
	$cmd = "perl $Bin/script/make_TP_FP_plot_RBI_MLLD_table.pl $PPV_TVC_detail_outfile $tp_fp_table";
	print O "$cmd\n\n";

	# Summary False Positive Call Reason
}else{
	# 统计giab SNV/InDel位点
	$cmd = "perl $Bin/script/For_giab_NA12878_WES_Sens_PPV.pl $qual_pass_vcf $gold_vcf_file $sample_name $outdir";
	print "Calculate GIAB NA12878 SNV/InDel Sens/PPV\n";
	print O "$cmd\n";
}

close O;
