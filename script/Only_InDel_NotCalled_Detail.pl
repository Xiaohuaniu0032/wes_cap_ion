use strict;
use warnings;

my ($sens_vcf,$TSVC_vcf,$not_call_outfile) = @ARGV;

my %rs_calling;
open IN, "$sens_vcf" or die;
while (<IN>){
	chomp;
	my @arr = split /\t/;
	next if ($arr[3] !~ /^rs/);
	push @{$rs_calling{$arr[3]}}, $arr[0]; # rs => ['Called','Called','NotCalled']
}
close IN;

# 哪些rs没有被TVC检出
my %rs_not_call;
foreach my $rs (keys %rs_calling){
	my @call_res = @{$rs_calling{$rs}};
	my $call_flag = 0;
	for my $item (@call_res){
		if ($item eq "Called"){
			$call_flag += 1;
		}
	}

	# check if this rs is called by TVC
	if ($call_flag == 1){
		next;
	}else{
		$rs_not_call{$rs} = 1;
	}
}

my $rs_no_call_num = scalar (keys %rs_not_call);
print "no call num: $rs_no_call_num\n";

# SAR: Alternate allele observations on the reverse strand
# SAF: Alternate allele observations on the forward strand
# AO : Alternate allele observations

# FSAR: Flow Evaluator Alternate allele observations on the reverse strand
# FSAF: Flow Evaluator Alternate allele observations on the forward strand
# FAO : Flow Evaluator Alternate allele observations

# DP :
# FDP:
# AF : FAO/FDP


my %nocall_used;

my ($chr,$pos,$rs,$ref,$alt,$QUAL,$tvc_res,$MLLD);
my ($AO,$FAO,$DP,$FDP,$AF,$FR,$GT);

open O, ">$not_call_outfile" or die;
print O "\#CHROM\tPOS\tID\tREF\tALT\tQUAL\tMLLD\tTVC_RESULT\tAO\tFAO\tDP\tFDP\tAF\tFR\tGT\n";

#my @FR_COV = qw/MINCOV PosCov NegCov/;
#my @FR_NODATA = qw/NODATA/;
#my @FR_SHIFT = qw/PREDICTIONSHIFT/;
#my @FR_HPLEN = qw/HPLEN/;

my %FR_list; # 过滤掉的原因列表

open TVC, "$TSVC_vcf" or die;
while (<TVC>){
	chomp;
	next if (/^\#/);
	my @arr = split /\t/;
	$chr     = $arr[0];
	$pos     = $arr[1];
	$rs      = $arr[2];
	$ref     = $arr[3];
	$alt     = $arr[4];
	$QUAL    = "GQ:".int($arr[5]);
	$tvc_res = $arr[6];

	# get MLLD and FR info
	my $alt_detail = $arr[7]; # AF=0.0666667;AO=0;DP=15;FAO=1;FDP=15;FDVR=5;FR=.&QualityScore<10&STDBIAS0.990802>0.95&STDBIASPVAL0.284<1;FRO=14;FSAF=1;FSAR=0;FSRF=6;FSRR=8;FWDB=-0.0459719;FXX=0;HRUN=1;HS_ONLY=0;LEN=1;MLLD=104.469;OALT=G;OID=rs1639661097;OMAPALT=G;OPOS=17356;OREF=A;PB=0.928571;PBP=0.216;QD=0.983474;RBI=0.0573698;REFB=-0.000975187;REVB=0.0343203;RO=14;SAF=0;SAR=0;SRF=6;SRR=8;SSEN=0;SSEP=0;SSSB=-4.25252e-08;STB=0.990802;STBP=0.284;TYPE=snp;VARB=0.0126649;HS
	my @alt_detail = split /\;/, $alt_detail;
	for my $item (@alt_detail){
		if ($item =~ /MLLD=/){
			$MLLD = $item;
		}

		if ($item =~ /FR=/){
			$FR = $item;
			$FR =~ s/^FR=//;
			#print "$FR\n";
		}
	}

	# get GT col
	my $gt_info = $arr[-1];
	my @gt_info = split /\:/, $gt_info;

	$AO  = "AO=".$gt_info[6];
	$FAO = "FAO=".$gt_info[7];
	$DP  = "DP=".$gt_info[2];
	$FDP = "FDP=".$gt_info[3];
	$AF  = "AF=".$gt_info[8];
	$GT  = "GT=".$gt_info[0];

	# rs可能为多个，同时，多个rs可能都相同，也可能不同（绝大多数rs相同）
	if ($rs =~ /\;/){
		# 多个rs
		my @rs = split /\;/, $rs;

		# 只要有一个rs出现在not call rs list中，同时TVC结果为NOCALL
		my $nocall_flag = 0;
		for my $item (@rs){
			if (exists $rs_not_call{$item}){
				$nocall_flag = 1;
				$nocall_used{$item} = 1;
			}
		}

		if ($nocall_flag == 1){
			# 输出这一行
			print O "$chr\t$pos\t$rs\t$ref\t$alt\t$QUAL\t$MLLD\t$tvc_res\t$AO\t$FAO\t$DP\t$FDP\t$AF\t$FR\t$GT\n";
			
			if ($FR =~ /MINCOV/ || $FR =~ /NegCov/ || $FR =~ /PosCov/){
				$FR_list{"COV"} += 1;
			}

			if ($FR =~ /PREDICTIONSHIFT/){
				$FR_list{"PREDICTIONSHIFT"} += 1;
			}

			if ($FR =~ /HPLEN/){
				$FR_list{"HPLEN"} += 1;
			}

			if ($FR =~ /QualityScore/){
				$FR_list{"QualityScore"} += 1;
			}

			if ($FR =~ /NODATA/){
				$FR_list{"NODATA"} += 1;
			}

			if ($FR =~ /STDBIAS/){
				$FR_list{"STDBIAS"} += 1;
			}

		}
	}else{
		# 一个rs
		if (exists $rs_not_call{$rs}){
			# 输出这一行
			$nocall_used{$rs} = 1;
			print O "$chr\t$pos\t$rs\t$ref\t$alt\t$QUAL\t$MLLD\t$tvc_res\t$AO\t$FAO\t$DP\t$FDP\t$AF\t$FR\t$GT\n";

			if ($FR =~ /MINCOV/ || $FR =~ /NegCov/ || $FR =~ /PosCov/){
				$FR_list{"COV"} += 1;
			}

			if ($FR =~ /PREDICTIONSHIFT/){
				$FR_list{"PREDICTIONSHIFT"} += 1;
			}

			if ($FR =~ /HPLEN/){
				$FR_list{"HPLEN"} += 1;
			}

			if ($FR =~ /QualityScore/){
				$FR_list{"QualityScore"} += 1;
			}

			if ($FR =~ /NODATA/){
				$FR_list{"NODATA"} += 1;
			}

			if ($FR =~ /STDBIAS/){
				$FR_list{"STDBIAS"} += 1;
			}
		}
	}
}
close TVC;
close O;

for my $rs (keys %rs_not_call){
	if (not exists $nocall_used{$rs}){
		print "$rs not appeared in tvc\n";
	}
}

my $nocall_used_n = scalar (keys %nocall_used);
print "$nocall_used_n\n";

# 统计FR列，按由大到小排列
foreach my $FR (sort {$FR_list{$b} <=> $FR_list{$a}} keys %FR_list){
	my $n = $FR_list{$FR};
	print "$FR\t$n\n";
}

