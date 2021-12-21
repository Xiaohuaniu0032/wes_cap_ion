use strict;
use warnings;

my ($nist_vcf,$wes_bed) = @ARGV;

my %cap_pos;
open BED, "$wes_bed" or die;
while (<BED>){
	chomp;
	my @arr = split /\t/;
	my $sp = $arr[1] + 1; # start pos
	my $ep = $arr[2]; # end pos
	for my $p ($sp..$ep){
		my $r = "$arr[0]\t$p"; # chr\tpos
		$cap_pos{$r} = 1;
	}
}
close BED;

open VCF, "$nist_vcf" or die;
while (<VCF>){
	next if (/^\#/);
	chomp;
	my @arr = split /\t/;
	my $chr = "chr".$arr[0];
	my $r = "$chr\t$arr[1]"; # chr\tpos
	if (exists $cap_pos{$r}){
		print "$_\n";
	}
}
close VCF;
