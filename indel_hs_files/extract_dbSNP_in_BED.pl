use strict;
use warnings;

my ($dbSNP_vcf,$bed_file) = @ARGV;
my $snv_num = 1000;
my $indel_num = 1000;

my %target_pos;
open BED, "$bed_file" or die;
while (<BED>){
	chomp;
	my @arr = split /\t/;
	my $sp = $arr[1] + 1;
	my $ep = $arr[2];
	for my $p ($sp..$ep){
		$target_pos{$arr[0]}{$p} = 1;
	}
}
close BED;

# 确定每条染色体取多少条
# 先统计每条染色体上SNV INDEL的个数,然后按比列确定每条染色体随机取多少条

my %useful_chr;
my @nc_list = qw/NC_000001 NC_000002 NC_000003 NC_000004 NC_000005 NC_000006 NC_000007 NC_000008 NC_000009 NC_000010 NC_000011 NC_000012 NC_000013 NC_000014 NC_000015 NC_000016 NC_000017 NC_000018 NC_000019 NC_000020 NC_000021 NC_000022 NC_000023 NC_000024/;
# chr1-chr22,chrX,chrY
for my $item (@nc_list){
	$useful_chr{$item} = 1;
}

my %chr_snv;
my %chr_indel;

if ($dbSNP_vcf =~ /\.gz$/){
	open IN, "gunzip -dc $dbSNP_vcf |" or die;
}else{
	open IN, "$dbSNP_vcf" or die;
}


while (<IN>){
	chomp;
	if (/^\#/){
		print "$_\n";
	}else{
		# 检查坐标是否在BED区域
		# 替换染色体名 NC_000001.10 = > chr1
		my @arr = split /\t/;
		my $NC = (split /\./, $arr[0])[0]; # NC_000001.10
		next if (!exists $useful_chr{$NC});
		$NC =~ s/^NC_//;
		$NC =~ s/^0+//;
		my $chr_int = int($NC);
		my $chr;
		if ($chr_int <= 22){
			$chr = "chr".$chr_int;
		}elsif ($chr_int == 23){
			$chr = "chrX";
		}else{
			$chr = "chrY";
		}

		next if (!exists $target_pos{$chr}{$arr[1]}); # 跳过不在bed区间中的位点

		$arr[0] = $chr;
		my $val = join "\t", @arr;
		print "$val\n";
	}
}
close IN;
