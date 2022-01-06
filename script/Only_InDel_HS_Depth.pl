use strict;
use warnings;

my ($indel_gold_vcf,$TSVC_vcf,$outfile) = @ARGV;

open O, ">$outfile" or die;
#print O "RS\tAO\tFAO\tDP\tFDP\n";
print O "RS\tDP\tFDP\n";

my @rs_list;
my %rs_flag;

open VCF, "$indel_gold_vcf" or die;
while (<VCF>){
	chomp;
	next if (/^\#/);
	my @arr = split /\t/;
	my $rs = $arr[2];
	if (not exists $rs_flag{$rs}){
		push @rs_list, $rs;
		$rs_flag{$rs} = 1;
	}else{
		next;
	}
}
close VCF;

my %rs_list;
for my $rs (@rs_list){
	$rs_list{$rs} = 1;
}

# 统计每个rs位点的测序深度
my ($AO,$FAO,$DP,$FDP);

my %rs_depth;

open TVC, "$TSVC_vcf" or die;
while (<TVC>){
	chomp;
	next if (/^\#/);
	my @arr = split /\t/;
	my $gt_info = $arr[-1];
	my @gt_info = split /\:/, $gt_info;
	
	$AO  = $gt_info[6]; # if alt allele is A,T, then AO info will be 3,1
	$FAO = $gt_info[7]; # same as AO

	$DP  = $gt_info[2]; # only one int number
	$FDP = $gt_info[3]; # same as DP

	my $rs = $arr[2];
	if ($rs =~ /\;/){
		my @rs  = split /\;/, $rs;
		my @AO  = split /\,/, $AO;
		my @FAO = split /\,/, $FAO;
		my $run_flag = 0;
		for my $item (@rs){
			if (exists $rs_list{$item}){
				my $rs_AO  = $AO[$run_flag]; 
				my $rs_FAO = $FAO[$run_flag];
				#print O "$item\t$rs_AO\t$rs_FAO\t$DP\t$FDP\n";
				$rs_depth{$item} = "$DP\t$FDP";
			}
			$run_flag += 1;
		}
	}else{
		if (exists $rs_list{$rs}){
			#print O "$rs\t$AO\t$FAO\t$DP\t$FDP\n";
			$rs_depth{$rs} = "$DP\t$FDP";
		}
	}
}
close TVC;

for my $rs (@rs_list){
	my $dep;
	if (exists $rs_depth{$rs}){
		$dep = $rs_depth{$rs};
		print O "$rs\t$dep\n";
	}else{
		$dep = "NA";
		print "$rs\t$dep\n";
	}

	#print O "$rs\t$dep\n";
}

close O;

# 统计DP列 >=5X >=10X >=20X >=100X
my ($cov_5x,$cov_10x,$cov_20x,$cov_100x) = (0,0,0,0);
my $rs_sum;

open DEP, "$outfile" or die;
<DEP>; # skip header
while (<DEP>){
	chomp;
	$rs_sum += 1;
	my @arr = split /\t/;
	my $raw_dep = $arr[1];
	if ($raw_dep >= 5){
		$cov_5x += 1;
	}

	if ($raw_dep >= 10){
		$cov_10x += 1;
	}

	if ($raw_dep >= 20){
		$cov_20x += 1;
	}

	if ($raw_dep >= 100){
		$cov_100x += 1;
	}
}
close DEP;

my $cov_5x_pct   = sprintf "%.2f", $cov_5x   / $rs_sum * 100;
my $cov_10x_pct  = sprintf "%.2f", $cov_10x  / $rs_sum * 100;
my $cov_20x_pct  = sprintf "%.2f", $cov_20x  / $rs_sum * 100;
my $cov_100x_pct = sprintf "%.2f", $cov_100x / $rs_sum * 100;

print "depth\tdepth_rs_num\ttotal_rs_num\tpct\n";
print ">=5X\t$cov_5x\t$rs_sum\t$cov_5x_pct\n";
print ">=10X\t$cov_10x\t$rs_sum\t$cov_10x_pct\n";
print ">=20X\t$cov_20x\t$rs_sum\t$cov_20x_pct\n";
print ">=100X\t$cov_100x\t$rs_sum\t$cov_100x_pct\n";
