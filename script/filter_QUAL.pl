use strict;
use warnings;

my ($gt_filter_vcf,$qual_cutoff,$outfile_vcf) = @ARGV;

open O, ">$outfile_vcf" or die;

open IN, "$gt_filter_vcf" or die;
while (<IN>){
	if (/^\#/){
		print O "$_\n";
	}else{
		my @arr = split /\t/;
		my $qual = $arr[5];
		if ($qual >= $qual_cutoff){
			print O "$_\n";
		}else{
			print "QUAL_Fail\t$_\n";
		}
	}
}
close IN;
close O;