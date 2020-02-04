#!/usr/bin/perl -w
use strict;

die "perl $0 [ psyllid.DESeq2.ouput.table ] [ psyllid.combined.gff3 ] [ psyllid.DESeq2.ouput.table.rename ]\n" unless @ARGV == 3;

my %chr;
open (CHR, "chr.list") or die "chr.list $!\n";
while(<CHR>){
	chomp;
	my @line = split;
	$chr{$line[0]} = $line[1];
}
close CHR;

my %scaf;
open (GFF, "$ARGV[1]") or die "$ARGV[1] $!\n";
while(<GFF>){
	next if(/^#/);
	next unless(/\S/);

	chomp;
	my @line = split;

	my $gene_name;
	my $loc_id;
	if(($line[2] eq "gene")||($line[2] eq "pseudogene")){
		if($line[8] =~ /GeneID:(\d+)/){
			$loc_id = $1;
			$scaf{$loc_id} = $line[0];
		}else{
			print "not matching GeneID: $line[8]\n";
		}
	}
}
close GFF;

open (IN, "$ARGV[0]") or die "$ARGV[0] $!\n";
open (OUT, ">$ARGV[2]") or die "$ARGV[2] $!\n";

my $header = <IN>;
$header =~ s/\"//g;
chomp $header;
print OUT "$header\tscaffold\tchr\n";

while(<IN>){
	chomp;
	my $all = $_;
	$all =~ s/\"//g;
	my @line = split /\s+/, $all;

	if($scaf{$line[0]}){
		if($chr{$scaf{$line[0]}}){
			print OUT "$all\t$scaf{$line[0]}\t$chr{$scaf{$line[0]}}\n"; 
		}else{
			print OUT "$all\t$scaf{$line[0]}\tNA\n";
		}
	}else{
		print "$line[0] not found in gff3\n";
	}
}
close IN;
close OUT;
print "Output: $ARGV[2]\n";
