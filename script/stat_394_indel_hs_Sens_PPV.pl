use strict;
use warnings;

my ($tvc_vcf_file, $sample_name, $outdir) = @ARGV;

# Please note: giab vcf was extract based on agilent v6 bed region from giab WGS vcf.
# So in theory, all variants in tvc should be equal with agilent.giab.vcf. this means 100% sens and 100 spec.

my $indel_hs_vcf = "$Bin/raw_394_indel_hs_file/hs_vcf_from_new_rs.vcf";
# 检查indel hs文件是否存在
if (!-e $indel_hs_vcf){
	die "can not find indel hs file: $indel_hs_vcf\n";
}

my %tvc_vars;
open IN, "$tvc_vcf_file" or die;
while (<IN>){
	chomp;
	next if (/^\#/);
	my @arr = split /\t/;
	# TVC会有检出Alt Allele但GT判断错误的情况.这里不考虑TVC给出的GT,即纯合/杂合
	my $var = "$arr[0]\t$arr[1]\t$arr[3]\t$arr[4]"; # chr/pos/ref/alt
	$tvc_vars{$var} = 1;
}
close IN;


################# 统计InDel灵敏度 ################
print "check indel sensitivity...\n";

# 检查indel hs文件中哪些位点没有在TSVC文件中
my $stat_file_for_sensitivity = "$outdir/$sample_name\.Sensitivity.xls";
open SENS, ">$stat_file_for_sensitivity" or die;

my $indel_call_num = 0;
my $indel_not_call_num = 0;

my $indel_var_num = 0;
open HS, "$indel_hs_vcf" or die;
while (<HS>){
	chomp;
	next if (/^\#/);
	$indel_var_num += 1; #有多少个indel位点
	my @arr = split /\t/;
	# 可能会存在多个alt alleles
	my $alt = $arr[4];
	
	my $flag = 0;

	if ($alt =~ /\,/){
		# 多个alt allele
		my @alts = split /\,/, $alt;
		for my $alt (@alts){
			my $var = "$arr[0]\t$arr[1]\t$arr[3]\t$alt"; # chr/pos/ref/alt
			if (exists $tvc_vars{$val}){
				$flag = 1;
				last;
			}
		}
	}else{
		my $var = "$arr[0]\t$arr[1]\t$arr[3]\t$arr[4]";
		if (exists $tvc_vars{$var}){
			$flag = 1;
			last;
		}
	}

	my $if_call;
	if ($flag == 1){
		$if_call = "Called";
		$indel_call_num += 1;
	}else{
		$if_call = "NotCalled";
		$indel_not_call_num += 1;
	}

	print SNES "$if_call\t$_\n";

}
close HS;
close SENS;


# stat indel sens
my $indel_num = $indel_call_num + $indel_not_call_num;
my $indel_sens = sprintf "%.2f", $indel_call_num/$indel_num * 100;
print "indel_called_num\tindel_not_called_num\tindel_total_num\tindel_sensitivity(\%)\n";
print "$indel_call_num\t$indel_not_call_num\t$indel_num\t$indel_sens\n";




################# 统计InDel PPV 阳性预测值 (检出阳性中,有多少是真阳性) ################
print "check indel PPV...\n";

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
	my $ref = "$arr[0]\t$arr[1]\t$arr[3]"; # chr/pos/ref
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
	my $tp_flag;
	if (exits $hs_indel{$ref}){
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
my $indel_tp_fp = $tvc_indel_tp + $tvc_indel_fp;
my $indel_ppv = sprintf "%.2f", $tvc_indel_tp/$indel_tp_fp * 100;

print "tvc_indel_tp\ttvc_indel_fp\ttvc_indel_tp_fp\ttvc_indel_PPV(\%)\n";
print "$tvc_indel_tp\t$tvc_indel_fp\t$indel_tp_fp\t$indel_ppv\n";

