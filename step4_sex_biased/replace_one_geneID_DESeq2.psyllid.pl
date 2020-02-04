#!/usr/bin/perl -w
use strict;

die "perl $0 [ psyllid.DESeq2.ouput.table ] [ psyllid.DESeq2.ouput.table.rename ]\n" unless @ARGV == 2;

my %chr;
open (CHR, "chr.list") or die "chr.list $!\n";
while(<CHR>){
	chomp;
	my @line = split;
	$chr{$line[0]} = $line[1];
}
close CHR;

my %scaf;

open (IN, "$ARGV[0]") or die "$ARGV[0] $!\n";
open (OUT, ">$ARGV[1]") or die "$ARGV[1] $!\n";

my $header = <IN>;
$header =~ s/\"//g;
chomp $header;
print OUT "$header\tscaffold\tchr\n";

while(<IN>){
	chomp;
	my $all = $_;
	$all =~ s/\"//g;
	my @line = split /\s+/, $all;

	# ScZCZ4B_999.g1225
	if($line[0] =~ /(ScZCZ4B_\d+)/){
		my $scaf = $1;

		if($chr{$scaf}){
			print OUT "$all\t$scaf\t$chr{$scaf}\n"; 
		}else{
			print OUT "$all\t$scaf\tNA\n";
		}
	}elsif(($line[0] =~ /gene\-/)||($line[0] =~ /rna\-/)){
		if($line[0] =~ /CRP/){
			print OUT "$all\tCarsonella\tCarsonella\n";
		}else{
			print OUT "$all\tmt\tmt\n";
		}
	}else{
		print "$line[0] not found in gff3\n";
	
	}
}
close IN;
close OUT;

print "Output:\n $ARGV[1]\n";
