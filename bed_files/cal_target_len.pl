use strict;
use warnings;

my $target = "YH.bed";

my $len_total;
open IN, "$target" or die;
while (<IN>){
	chomp;
	my @arr = split /\t/;
	my $len = $arr[2] - $arr[1];
	$len_total += $len;
}
close IN;

print "$len_total\n";
