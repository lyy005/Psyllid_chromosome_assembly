#!usr/bin/perl -w
use strict;

die "Usage: perl $0 [.aln]\n" unless (@ARGV == 1);
open (FA, $ARGV[0]) or die "$ARGV[0] $!\n";
open OUT, ">$ARGV[0].pw.axt" or die "$ARGV[0].pw.axt $!\n";

$/=">";
my $null = <FA>;
my @all;
while(<FA>){
      	chomp;
	my @line = split /\n+/;
	my $name = shift @line;
	my @name = split /\s+/, $name;

	my $seq = join "", @line;

	my $save = $name[0]."\n".$seq;

	push @all, $save;
}

my $c = @all;
my ($i, $j);
for($i = 0; $i < $c; $i ++){
	for($j = $i+1; $j < $c; $j ++){

		my @seq1 = split /\n+/, $all[$i]; 
		my @seq2 = split /\n+/, $all[$j];

		print OUT "$seq1[0]\-$seq2[0]\n$seq1[1]\n$seq2[1]\n\n";
	}
}

close FA;
close OUT;
