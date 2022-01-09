use strict;
use warnings;

my ($tvc_vcf_file, $indel_hs_vcf, $sample_name, $outdir) = @ARGV;

# Please note: giab vcf was extract based on agilent v6 bed region from giab WGS vcf.
# So in theory, all variants in tvc should be equal with agilent.giab.vcf. this means 100% sens and 100 spec.

# 检查indel hs文件是否存在
if (!-e $indel_hs_vcf){
	die "can not find $indel_hs_vcf, please check these file(s)\n";
}

my %skip_rs;
open VCF, "$indel_hs_vcf" or die;
while (<VCF>){
	chomp;
	next if (/^$/);
	next if (/^\#/);
	my @arr = split /\t/;
	my $alt = $arr[4];
	if ($alt =~ /\,/){
		# this pos has >=2 alt alleles
		# in giab NA12878, multi allele var is about 1%, so do not consider there multi allele vars will not affect the final results.
		$skip_rs{$arr[2]} = 1;
	}
}
close VCF;

################# 统计InDel灵敏度 ################
print "check indel sensitivity...\n";

# read tvc results, and for each var in gold vcf, check if it is called by TVC

# first read tvc results
my %tvc_vars;
open IN, "$tvc_vcf_file" or die;
while (<IN>){
	chomp;
	next if (/^\#/);
	my @arr = split /\t/;
	my $var = "$arr[0]\t$arr[1]\t$arr[3]\t$arr[4]"; # chr/pos/ref/alt. here we do not consider GT
	$tvc_vars{$var} = 1;
}

# then check each var in gold vcf

my $stat_file_for_sensitivity = "$outdir/$sample_name\.Sensitivity.xls";
open SENS, ">$stat_file_for_sensitivity" or die;

my $Log = "$outdir/$sample_name\.Sens.PPV.Result.txt";
open O, ">$Log" or die;

my ($called_num,$not_called_num) = (0,0);

open HS, "$indel_hs_vcf" or die;
while (<HS>){
	chomp;
	next if (/^\#/);
	next if (/^$/);
	my @arr = split /\t/;
	
	my $rs = $arr[2];
	if (exists $skip_rs{$rs}){
		print O "###[This Var will be skipped for multi alt allele] => $_\n\n";
	}

	my $alt = $arr[4];
	next if ($alt =~ /\,/); # skip multi alt vars

	my $chr;
	if ($arr[0] =~ /^chr/){
		$chr = $arr[0];
	}else{
		$chr = "chr".$arr[0];
	}

	my $var = "$chr\t$arr[1]\t$arr[3]\t$arr[4]"; # chr/pos/ref/alt

	my $if_call;
	if (exists $tvc_vars{$var}){
		$if_call = "Called";
		$called_num += 1;
	}else{
		$if_call = "NotCalled";
		$not_called_num += 1;
	}

	print SENS "$if_call\t$_\n";

}
close HS;
close SENS;


# stat indel sens
my $indel_all_num = $called_num + $not_called_num;
my $indel_sens = sprintf "%.2f", $called_num / $indel_all_num * 100;

print O "indel_called_num\tindel_not_called_num\tindel_total_num\tindel_sensitivity(\%)\n";
print O "$called_num\t$not_called_num\t$indel_all_num\t$indel_sens\n";
close O;



# 针对300+ indel位点，无法统计PPV。因为除了这300+真阳性位点，WES中还有其他真阳性位点，而我们并没有这些真阳性位点。

################# 统计InDel PPV 阳性预测值 (检出阳性中,有多少是真阳性) ################

#print "check indel PPV...\n";
#print "Skip stat hs indel PPV for we lack a complete True-Positive variants list file\n";


=begin comment
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

=end comment

=cut