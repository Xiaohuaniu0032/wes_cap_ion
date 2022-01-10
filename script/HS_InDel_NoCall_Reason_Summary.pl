use strict;
use warnings;

my ($Sens_TVC_outfile,$outfile) = @ARGV;

# 统计NotCall的FR
my ($Ref_Call,$Low_Cov,$NODATA,$PREDICTIONSHIFT,$Others) = (0,0,0,0,0);
my %others;

open IN, "$Sens_TVC_outfile" or die;
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



open O, ">$outfile" or die;
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
