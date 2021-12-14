use strict;
use warnings;

my ($dbSNP_vcf,$outdir,$out_vcf_name) = @ARGV;

open O, ">$outdir/$out_vcf_name" or die;

my $ref_freq_cutoff = 0.05; # ref freq should <= cutoff [0.05]

if ($dbSNP_vcf =~ /\.gz$/){
	open IN, "gunzip -dc $dbSNP_vcf |" or die;
}else{
	open IN, "$dbSNP_vcf" or die;
}

my $log = "$outdir/human_1000g.freq.log";
open LOG, ">$log" or die;

my $human_1000g_line = 0; # 统计FREQ包含1000Genomes的行数
my $useful_line = 0; # 统计最终满足条件的indel行数

print "Start to process dbSNP vcf db\n";

while (<IN>){
	chomp;
	next if /VC=SNV/; # skip SNV
	if (/^\#/){
		print O "$_\n";
	}else{
		# check 1000genome records
		# FREQ=1000Genomes:0.5747,0.4253,.|TOMMO:0.9994,0.0005821,.|dbGaP_PopFreq:1,0,0;COMMON
		my @arr = split /\t/;
		my @info = split /\t/, $arr[7]; # INFO信息列
		for my $info (@info){
			if ($info =~ /^FREQ/){
				# 检查FREQ信息
				my $db_info = $info;
				$db_info =~ s/^FREQ=//;
				
				my $ref_freq;
				my $if_1000g = 0; # 判断是否包含1000Genomes频率信息

				if ($db_info =~ /\|/){
					# 包含多个数据库频率信息
					my @db_info = split /\|/, $db_info;
					for my $db (@db_info){
						if ($db =~ /^1000Genomes/){
							# 检查ref频率
							my $freq_info = (split /\:/, $db)[1]; # 1000Genomes:0.9119,0.08806,. [Ref is C, Alt is G,T] rs575272151
							$ref_freq = (split /\,/, $freq_info)[0];
							$if_1000g = 1;
						}
					}
				}else{
					if ($db_info =~ /^1000Genomes/){
						# 检查ref频率
						my $freq_info = (split /\:/, $db_info)[1]; # FREQ=1000Genomes:0.9998,0.0001997
						$ref_freq = (split /\,/, $freq_info)[0];
						$if_1000g = 1;
					}
				}

				if ($if_1000g == 1){
					# 存在1000Genome信息
					$human_1000g_line += 1;
					if ($ref_freq <= $ref_freq_cutoff){
						# ref频率<=0.05 [default]
						print O "$_\n";
						$useful_line += 1;
					}else{
						print LOG "Skip $arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]\: Ref Freq is $ref_freq (\>$ref_freq_cutoff)\n";
					}
				}
			}
		}
	}
}
close IN;
close O;

print LOG "total 1000Genomes Lines: $human_1000g_line\n";
print LOG "useful line: $useful_line\n";
close LOG;