use strict;
use warnings;

my ($tvc_vcf_file, $indel_hs_vcf, $sample_name, $outdir) = @ARGV;

# Please note: giab vcf was extract based on agilent v6 bed region from giab WGS vcf.
# So in theory, all variants in tvc should be equal with agilent.giab.vcf. this means 100% sens and 100 spec.

# 检查indel hs文件是否存在
if (!-e $indel_hs_vcf){
	die "can not find indel hs file: $indel_hs_vcf\n";
}


################# 统计InDel灵敏度 ################

my %tvc_vars;
open IN, "$tvc_vcf_file" or die;
while (<IN>){
	chomp;
	next if (/^\#/);
	my @arr = split /\t/;
	next if ($arr[2] !~ /^rs/);
	
	my $rs;
	if ($arr[2] =~ /\;/){
		my @rs = split /\;/, $arr[2];
		$rs = $rs[0];
	}else{
		$rs = $arr[2];
	}

	my $var = "$arr[0]\t$arr[1]\t$arr[3]\t$arr[4]"; # chr/pos/ref/alt
	push @{$tvc_vars{$rs}}, $var;  # 一个rs可能有多个变异
}

# 检查indel hs文件中，每个rs是否被tvc检出了
print "check indel sensitivity...\n";

my $stat_file_for_sensitivity = "$outdir/$sample_name\.Sensitivity.xls";
open SENS, ">$stat_file_for_sensitivity" or die;

my $indel_call_num = 0;
my $indel_not_call_num = 0;

my $indel_var_num = 0;

my %called_rs;
my %all_rs;

open HS, "$indel_hs_vcf" or die;
while (<HS>){
	chomp;
	next if (/^\#/);
	#$indel_var_num += 1; #有多少个indel位点
	my @arr = split /\t/;
	$all_rs{$arr[2]} = 1; # all rs

	# NA12878 giab VCF染色体以1/2/3..命名
	# 394个indel热点是从dbSNP数据库中得到的,dbSNP build 155以NC_000001.10命名染色体,indel hs文件染色体已经转换为chr命名
	# 如果需要和NA12878 giab数据库比较,染色体命名需处理一下
	
	my $chr;
	if ($arr[0] =~ /^chr/){
		$chr = $arr[0];
	}else{
		$chr = "chr".$arr[0]; # na12878 giab染色体只包含1-22,不包含X/Y
	}

	my $find_flag;
	if (exists $tvc_vars{$arr[2]}){
		my $var = "$chr\t$arr[1]\t$arr[3]\t$arr[4]"; # chr/pos/ref/alt;
		my @tvc_vars = @{$tvc_vars{$arr[2]}};
		my $item_flag = 0;
		for my $item (@tvc_vars){
			if ($var eq $item){
				$item_flag = 1;
			}
		}

		# check if any one of tvc call match golden hs indel 
		if ($item_flag == 1){
			$find_flag = 1
		}else{
			$find_flag = 0;
		}
	}else{
		$find_flag = 0;
	}

	my $if_call;
	if ($find_flag == 1){
		$if_call = "Called";
		$called_rs{$arr[2]} = 1;	
	}else{
		$if_call = "NotCalled";
	}

	print SENS "$if_call\t$_\n";

}
close HS;
close SENS;


# stat indel sens
my $rs_all_num = scalar (keys %all_rs);
my $called_rs_num = scalar (keys %called_rs);
my $indel_sens = sprintf "%.2f", $called_rs_num / $rs_all_num * 100;

my $not_called_rs_num = $rs_all_num - $called_rs_num;

print "indel_called_num\tindel_not_called_num\tindel_total_num\tindel_sensitivity(\%)\n";
#print "$indel_call_num\t$indel_not_call_num\t$indel_num\t$indel_sens\n";
print "$called_rs_num\t$not_called_rs_num\t$rs_all_num\t$indel_sens\n";
print "\n";



################# 统计InDel PPV 阳性预测值 (检出阳性中,有多少是真阳性) ################

# 针对300+ indel位点，无法统计PPV。因为除了这300+真阳性位点，WES中还有其他真阳性位点，而我们并没有这些真阳性位点。

print "check indel PPV...\n";
print "Skip stat hs indel PPV for we lack a complete True-Positive variants list file\n";

# 检查TSVC文件InDel位点,哪些在hs indel中,哪些不在hs indel中
my $stat_file_for_ppv = "$outdir/$sample_name\.PPV.xls";
open PPV, ">$stat_file_for_ppv" or die;

my $indel_tp_num = 0;

# 读取hs indel
my %hs_indel;
open INDEL, "$indel_hs_vcf" or die;
while (<INDEL>){
	chomp;
	next if (/^\#/);
	my @arr = split /\t/;

	my $chr;
	if ($arr[0] =~ /^chr/){
		$chr = $arr[0];
	}else{
		$chr = "chr".$arr[0]; # na12878 giab染色体只包含1-22,不包含X/Y
	}

	my $ref = "$chr\t$arr[1]\t$arr[3]"; # chr/pos/ref
	$hs_indel{$ref} = $arr[4];
}
close INDEL;

# 读取tvc,过滤SNV位点
my ($tvc_indel_tp,$tvc_indel_fp) = (0,0);

open TVC, "$tvc_vcf_file" or die;
while (<TVC>){
	chomp;
	next if (/^\#/);
	my @arr = split /\t/;
	my $len_ref = length($arr[3]);
	my $len_alt = length($arr[4]);
	next if ($len_ref == $len_alt); ###### 过滤SNV位点

	my $ref = "$arr[0]\t$arr[1]\t$arr[3]"; # chr/pos/ref
	my $alt = $arr[4];
	# 先检查indel hs是否存在这个ref位点. 如果存在,检查tvc alt是否在indel hs alt alleles中
	my $tp_flag = 0;

	if (exists $hs_indel{$ref}){
		my $hs_indel_alt_allele = $hs_indel{$ref};
		if ($hs_indel_alt_allele =~ /\,/){ # TSVC文件已经经过了bcf norm,不会出现alt列包含多个alt alleles的现象
			my @hs_indel_alt_allele = split /\,/, $hs_indel_alt_allele;
			for my $hs_alt (@hs_indel_alt_allele){
				if ($alt eq $hs_alt){
					$tp_flag = 1;
				}
			}
		}else{
			if ($alt eq $hs_indel_alt_allele){
				$tp_flag = 1;
			}
		}
	}

	my $if_call;
	if ($tp_flag == 1){
		# 真阳性位点
		$if_call = "TP";
		$tvc_indel_tp += 1;
	}else{
		$if_call = "FP";
		$tvc_indel_fp += 1;
	}

	print PPV "$if_call\t$_\n";
}
close PPV;
close TVC;

# stat indel spec
#my $indel_tp_fp = $tvc_indel_tp + $tvc_indel_fp;
#my $indel_ppv = sprintf "%.2f", $tvc_indel_tp/$indel_tp_fp * 100;

#print "tvc_indel_tp\ttvc_indel_fp\ttvc_indel_tp_fp\ttvc_indel_PPV(\%)\n";
#print "$tvc_indel_tp\t$tvc_indel_fp\t$indel_tp_fp\t$indel_ppv\n";

