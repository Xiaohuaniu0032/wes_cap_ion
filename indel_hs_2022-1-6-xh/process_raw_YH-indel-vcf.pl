use strict;
use warnings;

my ($raw_vcf,$fa,$out_new_vcf,$out_new_bed) = @ARGV;

open O, ">$out_new_vcf" or die;

open IN, "$raw_vcf" or die;
my $h = <IN>;
print O "$h";
while (<IN>){
	chomp;
	my @arr = split /\t/;
	my $alt = $arr[4];
	if ($alt !~ /\,/){
		print O "$_\n";
	}else{
		print "[Multi Alt Allele, SKipped] ===> $_\n";
	}
}
close IN;
close O;

# vcf to hs bed
my $cmd = "tvcutils prepare_hotspots -v $out_new_vcf -r $fa -a -s -d $out_new_bed";
`$cmd`;


