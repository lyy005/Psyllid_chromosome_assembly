for i in *.cds.fasta
 do
  perl /stor/work/Ochman/yli19/projects/aphid_genome/step9_paralogs/codon_alignment_v1.4/codon_alignment.pl $i 1 0 > $i\.log
  /stor/work/Ochman/yli19/projects/aphid_genome/step9_paralogs/Gblocks_0.91b/Gblocks $i\.nt.cleanup.aln -t=c -b4=10 -b5=a -e=-gb > $i\.gblocks.log
  less -S $i\.nt.cleanup.aln-gb| perl -e '$/ = ">"; <>; while(<>){chomp; @line=split/\n+/; my $name = shift @line; @name=split/\s+/, $name; my $seq = join "",@line; $seq =~s/\s+//g; print ">$name[0]\n$seq\n";}' > $i\.GBlocks.fas
  perl /stor/work/Ochman/yli19/projects/aphid_genome/step9_paralogs/aln2axt.pl $i\.GBlocks.fas
  nohup /stor/work/Ochman/yli19/projects/aphid_genome/step9_paralogs/KaKs_Calculator/KaKs_Calculator2.0/bin/Linux/KaKs_Calculator  -i $i\.GBlocks.fas.pw.axt -o $i\.kaks &
 done
