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
	"gvcf:s" => \$gold_vcf_file,                      # Optional <Default: Bin/raw_394_indel_hs_file/hs_vcf_from_new_rs.vcf>
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
	$gold_vcf_file = "$Bin/raw_394_indel_hs_file/hs_vcf_from_new_rs.vcf";
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

# step1: bcf norm => indel left align and indel unify presentation
# see https://samtools.github.io/bcftools/bcftools.html#norm for detail.
# -m:split multiallelics (-) or join biallelics (+)
# -c:check REF alleles and exit (e), warn (w), exclude (x), or set (s)
my $norm_vcf = "$outdir/$sample_name\.TSVC_variants.bcfnorm.vcf";
my $cmd = "bcftools norm -f $fasta -m - -c w $TSVC_variants_vcf_file >$norm_vcf";
print O "$cmd\n";

# step2: remove 0/0 and ./. genotype call
my $gt_filter_vcf = "$outdir/$sample_name\.TSVC_variants.bcfnorm.gt_filter.vcf";
$cmd = "perl $Bin/script/filter_bcfnorm_vcf.pl $norm_vcf $gt_filter_vcf";
print O "$cmd\n";

# step3: filter QUAL
my $qual_pass_vcf = "$outdir/$sample_name\.TSVC_variants.bcfnorm.gt_filter.qual_pass.vcf";
my $qual_nopass_vcf = "$outdir/$sample_name\.TSVC_variants\.bcfnorm.gt_filter.qual_nopass.vcf";
$cmd = "perl $Bin/script/filter_QUAL.pl $gt_filter_vcf $QUAL_cutoff $qual_pass_vcf \>$qual_nopass_vcf";
print O "$cmd\n";

# step4: stat sensitivity and PPV according the gold vcf file
my $indel_hs_vcf = "$Bin/raw_394_indel_hs_file/hs_vcf_from_new_rs.vcf";
$cmd = "perl $Bin/script/stat_394_indel_hs_Sens_PPV.pl $qual_pass_vcf $indel_hs_vcf $sample_name $outdir";
print O "$cmd\n";

close O;
