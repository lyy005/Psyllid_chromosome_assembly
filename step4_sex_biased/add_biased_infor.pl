#!/usr/bin/perl -w
use strict;

die "perl $0 [ male biased ] [ female biased ] [ asexual biased ] [ aphid_sex.DESeq2_normalized.table.rename.final ] [ output ]\n" unless @ARGV == 5;

my %hash;
open (LS, "$ARGV[0]") or die "$ARGV[0] $!\n";
while(<LS>){
	chomp;
	s/\"//g;
	my @line = split;
	$hash{$line[0]} = "male-biased";
}
close LS;

open (LS, "$ARGV[1]") or die "$ARGV[1] $!\n";
while(<LS>){
	chomp;
	s/\"//g;
	my @line = split;
	$hash{$line[0]} = "female-biased";
}
close LS;

open (LS, "$ARGV[2]") or die "$ARGV[2] $!\n";
while(<LS>){
	chomp;
	s/\"//g;
	my @line = split;
	$hash{$line[0]} = "asexual-biased";
}
close LS;

open (IN, "$ARGV[3]") or die "$ARGV[3] $!\n";
open (OUT, ">$ARGV[4]") or die "$ARGV[4] $!\n";

my $header = <IN>;
chomp $header;
$header =~ s/\"//g;
print OUT "$header bias\n";

while(<IN>){
	chomp;
	s/\"//g;

	my $line = $_;
	my @line = split /\s+/, $line;
	my $id = $line[0];

	my $exp = $line[-3] + $line[-4] + $line[-5];
	if($hash{$id}){
		print OUT "$line $hash{$id}\n";
	}elsif($exp <= 15){
		print OUT "$line unexpressed\n";
	}else{
		print OUT "$line unbiased\n";
	}
}
close IN;
