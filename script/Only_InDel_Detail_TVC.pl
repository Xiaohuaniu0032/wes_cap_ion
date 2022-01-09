use strict;
use warnings;
use File::Basename;

my ($sens_vcf,$TSVC_bcfnorm_vcf,$outfile) = @ARGV;

# SAR: Alternate allele observations on the reverse strand
# SAF: Alternate allele observations on the forward strand
# AO : Alternate allele observations

# FSAR: Flow Evaluator Alternate allele observations on the reverse strand
# FSAF: Flow Evaluator Alternate allele observations on the forward strand
# FAO : Flow Evaluator Alternate allele observations

# DP :
# FDP:
# AF : FAO/FDP


my %tvc_detail;
open TVC, "$TSVC_bcfnorm_vcf" or die;
while (<TVC>){
	chomp;
	next if (/^\#/);
	my @arr = split /\t/;

	my ($QUAL,$MLLD,$RBI,$STB,$Call_Res,$FR) = qw/NA NA NA NA NA NA/;
	my ($AO,$FAO,$DP,$FDP,$AF,$GT)           = qw/NA NA NA NA NA NA/;
	
	$QUAL     = "GQ=".int($arr[5]);
	$Call_Res = $arr[6];

	my $var = "$arr[0]\.$arr[1]\.$arr[3]\.$arr[4]"; # chr/pos/ref/alt

	# get MLLD and FR info
	my $alt_detail = $arr[7]; # AF=0.0666667;AO=0;DP=15;FAO=1;FDP=15;FDVR=5;FR=.&QualityScore<10&STDBIAS0.990802>0.95&STDBIASPVAL0.284<1;FRO=14;FSAF=1;FSAR=0;FSRF=6;FSRR=8;FWDB=-0.0459719;FXX=0;HRUN=1;HS_ONLY=0;LEN=1;MLLD=104.469;OALT=G;OID=rs1639661097;OMAPALT=G;OPOS=17356;OREF=A;PB=0.928571;PBP=0.216;QD=0.983474;RBI=0.0573698;REFB=-0.000975187;REVB=0.0343203;RO=14;SAF=0;SAR=0;SRF=6;SRR=8;SSEN=0;SSEP=0;SSSB=-4.25252e-08;STB=0.990802;STBP=0.284;TYPE=snp;VARB=0.0126649;HS
	my @alt_detail = split /\;/, $alt_detail;
	for my $item (@alt_detail){
		if ($item =~ /MLLD=/){
			$MLLD = $item;
		}

		if ($item =~ /FR=/){
			$FR = $item;
		}

		if ($item =~ /RBI=/){
			$RBI = $item;
		}

		if ($item =~ /STB=/){
			$STB = $item;
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
	$GT  = "GT=".$gt_info[0]; # 0/1 | ./. | 0/0

	
	$tvc_detail{$var} = "$QUAL\t$MLLD\t$STB\t$RBI\t$Call_Res\t$FR\t$AO\t$FAO\t$DP\t$FDP\t$AF\t$GT"; # QUAL/MLLD/STB/RBI/FR/TVC_Res/AO/FAO/DP/FDP/AF/GT
	
}
close TVC;



# read sensitivity file and output each InDel HS's TVC detail info

open O, ">$outfile" or die;
print O "\#If_Call\tHS_Var\tHS_GT\tTVC_QUAL\tTVC_MLLD\tTVC_STB\tTVC_RBI\tTVC_RESULT\tTVC_FR\tTVC_AO\tTVC_FAO\tTVC_DP\tTVC_FDP\tTVC_AF\tTVC_GT\n";

open IN, "$sens_vcf" or die;
while (<IN>){
	chomp;
	my @arr = split /\t/;
	my $gt = "GT=".(split /\:/, $arr[-1])[0];
	my $chr;
	if ($arr[1] =~ /^chr/){
		$chr = $arr[1];
	}else{
		$chr = "chr".$arr[1];
	}

	my $var = "$chr\.$arr[2]\.$arr[4]\.$arr[5]"; # chr.pos.ref.alt
	
	my $tvc_info;
	if (exists $tvc_detail{$var}){
		$tvc_info = $tvc_detail{$var};
	}else{
		$tvc_info = join "\t", qw/NA NA NA NA NA NA NA NA NA NA NA NA/;
	}

	print O "$arr[0]\t$var\t$gt\t$tvc_info\n";

}
close IN;
close O;






# Job1-统计热点深度
# Job2-统计FR分类

my $bn = basename($outfile);
my $sample = (split /\./, $bn)[0];
print "auto detected sample name is: $sample\n";
my $od = dirname($outfile);

# 统计热点深度
my ($cov_5x,$cov_10x,$cov_20x) = (0,0,0);
my $hs_num = 0;

my $HS_InDel_Depth_Summary_File = "$od/$sample\.HS.InDel.Depth.Summary.xls";
open DEPTH, ">$HS_InDel_Depth_Summary_File" or die;
print DEPTH "Chr\tPos\tRef\tAlt\tAO\tFAO\tDP\tFDP\n";

open IN, "$outfile" or die;
<IN>;
while (<IN>){
	chomp;
	my @arr = split /\t/;
	my $var = $arr[1];
	my @var = split /\./, $var;
	
	my $AO  = (split /\=/, $arr[-6])[1];
	my $FAO = (split /\=/, $arr[-5])[1];

	my $DP  = int((split /\=/, $arr[-4])[1]);
	my $FDP = (split /\=/, $arr[-3])[1];

	print DEPTH "$var[0]\t$var[1]\t$var[2]\t$var[3]\t$AO\t$FAO\t$DP\t$FDP\n";

	if ($DP >= 5){
		$cov_5x += 1;
	}

	if ($DP >= 10){
		$cov_10x += 1;
	}

	if ($DP >= 20){
		$cov_20x += 1;
	}

	$hs_num += 1;
}
close IN;
close DEPTH;

my ($cov_5x_pct,$cov_10x_pct,$cov_20x_pct) = (0,0,0);

if ($cov_5x > 0){
	$cov_5x_pct = sprintf "%.2f", $cov_5x / $hs_num * 100;
}else{
	$cov_5x_pct = 0;
}

if ($cov_10x > 0){
	$cov_10x_pct = sprintf "%.2f", $cov_10x / $hs_num * 100;
}else{
	$cov_10x_pct = 0;
}

if ($cov_20x > 0){
	$cov_20x_pct = sprintf "%.2f", $cov_20x / $hs_num *100;
}else{
	$cov_20x_pct = 0;
}

print "Depth(Raw_DP)\tNum\tTotal_Num\tPct(\%)\n";
print ">=5X\t$cov_5x\t$hs_num\t$cov_5x_pct\n";
print ">=10X\t$cov_10x\t$hs_num\t$cov_10x_pct\n";
print ">=20X\t$cov_20x\t$hs_num\t$cov_20x_pct\n";



# 统计NotCall的FR
my ($Ref_Call,$Low_Cov,$NODATA,$PREDICTIONSHIFT,$Others) = (0,0,0,0,0);

my %others;

open IN, "$outfile" or die;
<IN>;
while (<IN>){
	chomp;
	my @arr = split /\t/;
	my $TVC_Res = $arr[-8];
	if ($arr[0] eq "NotCalled"){
		my $FR = $arr[-7];

		if ($TVC_Res eq "PASS"){
			$Ref_Call += 1;
		}else{
			# with filter reason
			if ($FR =~ /MINCOV/ || $FR =~ /PosCov/ || $FR =~ /NegCov/){
				$Low_Cov += 1;
			}elsif ($FR =~ /NODATA/){
				$NODATA += 1;
			}elsif ($FR =~ /PREDICTIONSHIFT/){
				$PREDICTIONSHIFT += 1;
			}else{
				$Others += 1;
				$others{$FR} += 1; # output other's FR
			}
		}
	}
}
close IN;

my $NoCall_Summary_File = "$od/$sample\.HS.InDel.NoCall.Reason.Summary.xls";

open O, ">$NoCall_Summary_File" or die;
print O "NoCallReason\tNum\tTotal_Num\tPct(\%)\n";
my $n = $Ref_Call + $Low_Cov + $NODATA + $PREDICTIONSHIFT + $Others;

my $ref_call_pct = sprintf "%.2f", $Ref_Call / $n * 100;
my $low_cov_pct  = sprintf "%.2f", $Low_Cov  / $n * 100; 
my $no_data_pct  = sprintf "%.2f", $NODATA   / $n * 100;
my $predshif_pct = sprintf "%.2f", $PREDICTIONSHIFT / $n * 100;
my $others_pct   = sprintf "%.2f", $Others   / $n * 100;

print O "Ref_Call\t$Ref_Call\t$n\t$ref_call_pct\n";
print O "Low_Cov\t$Low_Cov\t$n\t$low_cov_pct\n";
print O "NODATA\t$NODATA\t$n\t$no_data_pct\n";
print O "PREDICTIONSHIFT\t$PREDICTIONSHIFT\t$n\t$predshif_pct\n";
print O "Others\t$Others\t$n\t$others_pct\n";


print O "\n\n\n";
print O "###### Other's FR ######\n";

foreach my $fr (sort {$others{$b} <=> $others{$a}} keys %others){
	my $n = $others{$fr};
	print O "$fr\t$n\n";
}

close O;
