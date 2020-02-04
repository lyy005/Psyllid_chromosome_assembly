#!/usr/bin/perl -w
use strict;

die "usage: perl $0 [ aphid2maidis.table ] [ aphid gff3 ] [ maidis gff3 ] [output]\n" unless (@ARGV==4);
open IN1,$ARGV[0] or die "$!\n";
open IN2,$ARGV[1] or die "$!\n";
open IN3,$ARGV[2] or die "$!\n";
open OUT,">$ARGV[3]" or die "$!\n";

my (%start, %end, %scaf);

# format: 100144916-rna26874	113561234-rna-XM_026967576.1
###
# maidis gff file
###
# format: Dbxref=GeneID:113561234,Genbank:XM_026967576.1
while(<IN3>) {   
	my $line = $_;
	next if ($line =~ /^#/);

	chomp;
	my @line = split/\t+/, $line;
	if($line[2] eq "mRNA"){

#		if($line[-1] =~ /ID=([^\;]+)\;/){
#print "###$1\n"/;
		if($line[-1] =~ /Dbxref=GeneID\:(\d+)\,Genbank\:([^\;]+)\;/){
			my $rna = $1."-rna-".$2;
			#my $gene_name = $2;
#			my $gene_name = $1 if($line[-1] =~ /Dbxref=GeneID\:([^\,]+)\,/);
#			$rna = $gene_name."-".$rna;

			$scaf{$rna} = $line[0];
			$start{$rna} = $line[3];
			$end{$rna} = $line[4];
#print "$rna\n";
		}else{
			print "Gff file mRNA name formwat error $line[-1];\n";
		}
	}
}
close IN3;

####
# aphid gff file
###
# format: ID=rna0;Parent=gene0;Dbxref=GeneID:100569617,Genbank:XM_003239978.3;
while(<IN2>) {
	my $line = $_;
	next if ($line =~ /^#/);
	chomp;
	my @line = split/\t+/, $line;
	if($line[2] eq "mRNA"){
		if($line[-1] =~ /ID=([^\;]+)\;/){
			my $rna = $1;
			my $gene_name;
			if($line[-1] =~ /Dbxref=GeneID\:([^\,]+)\,/){
				$gene_name = $1;
			}
			$rna = $gene_name."-".$rna;
			$scaf{$rna} = $line[0];
			$start{$rna} = $line[3];
			$end{$rna} = $line[4];
		}else{
			print "Gff file mRNA name formwat error $line[-1];\n";
		}
	}
}
close IN2;

while (my $line = <IN1>) {
        chomp $line; 
	my @line = split /\s+/, $line;

	foreach my $i (sort @line){
#		my @i = split /\|/, $i;
		if($scaf{$i}){
			print OUT "$scaf{$i}\t$i\t$start{$i}\t$end{$i}\n";
		}else{
			print "$i\tmRNA not found in gff3\n";
		}
	}
#	print OUT "\n";
}
close OUT;
close IN1;
print "Done\n";
