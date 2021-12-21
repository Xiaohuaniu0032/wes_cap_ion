use strict;
use warnings;

#目的:将394个indel hs位点与随机抽取的snv/indel位点合并
# 注意:
# 1)linux shuf命令随机抽取的文件行信息是乱的
# 2)两个文件可能会有重复的行

# 合并时按chr/start pos排序并输出,并输出snv/indel数量

my ($indel_hs_394rs_file,$random_vcf_file,$outfile) = @ARGV;

my %indel_hs;
my %vc; #统变snv/indel异类型数量

open HS, "$indel_hs_394rs_file" or die;
while (<HS>){
	chomp;
	next if (/^\#/);
	my @arr = split /\t/;
	$indel_hs{$arr[0]}{$arr[1]} = $_; # chr/pos
	
	my $info = $arr[7];
	my @info = split /\;/, $info;
	for my $info (@info){
		if ($info =~ /^VC=/){
			$vc{$info} += 1;
		}
	}
}
close HS;


open O, ">$outfile" or die;

open VCF, "$random_vcf_file" or die;
while (<VCF>){
	chomp;
	if (/^\#/){
		print O "$_\n";
	}else{
		my @arr = split /\t/;
		$indel_hs{$arr[0]}{$arr[1]} = $_; # chr/pos

		my $info = $arr[7];
		my @info = split /\;/, $info;
		for my $info (@info){
			if ($info =~ /^VC=/){
				$vc{$info} += 1;
			}
		}
	}
}
close VCF;

foreach my $vc (keys %vc){
	my $n = $vc{$vc};
	print "$vc\t$n\n";
}

my @chrs;
for my $i (1..22){
	my $cc = "chr".$i;
	push @chrs, $cc;
}
push @chrs, "chrX";
push @chrs, "chrY";

foreach my $chr (@chrs){
	if (exists $indel_hs{$chr}){
		my @pos_sort = sort {$a <=> $b} keys %{$indel_hs{$chr}};
		for my $pos (@pos_sort){
			my $val = $indel_hs{$chr}{$pos};
			print O "$val\n";
		}
	}
}
close O;


