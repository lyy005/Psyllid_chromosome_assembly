#!/usr/bin/perl -w
use strict;

die "usage: perl $0 [ old gff file ] [ chr list ] [ new gff file ]\n" unless (@ARGV == 3);

open GFF,$ARGV[0] or die "$!\n";
open LST,$ARGV[1] or die "$!\n";
open OUT,">$ARGV[2]" or die "$!\n";

my %hash;
print "#Scaffold_ID\tchr_ID\n";
while (my $line=<LST>) {
	next if ($line =~ /^\#/);
	chomp $line;
        my @line = split(/\s+/,$line);
	$hash{$line[1]} = $line[0];
print "$line[1]\t$line[0]\n";
}
close LST;


while(my $line=<GFF>){
	chomp $line;
	my @line = split(/\s+/,$line);
	
	my $key = shift @line;

	$line = join "\t", @line;

	if(exists $hash{$key}){
		print OUT "$hash{$key}\t$line\n";
	}
}
close OUT;
