# Analytical pipeline of the hackberry petiole gall psyllid (*Pachypsylla venusta*) genome

This document is a walkthrough of the methods and code used to analyze the chromosome-level genome assembly. In the paper, we used HiC and Chicago libraries to build the chromosome-level assembly and analyzed gene content and sequence evolution of chromosomes. We also produced male and female resequencing data for detecting the X chromosome; male and female RNA-seq data for identifying sex-biased genes.

## 1 - Genome Assembly Verification

### 1.1 - BUSCO analysis

        python run_BUSCO.py -i psyllid_dovetail.fasta -l ./insecta_odb9/ -m geno -f -o psyllid_insecta -c 32

### 1.2 - X chromosome assignment based on sequencing depth of males and females

        # Quality control
        # In the trimmomatic adaptor folder:
        cat \*PE.fa > combined.fa

        # Running trimmomatic
        java -jar trimmomatic-0.38.jar PE -phred33 DNA1.1.fq.gz DNA1.2.fq.gz DNA1_pe.1.fq.gz DNA1_se.1.fq.gz DNA1_pe.2.fq.gz DNA1_se.2.fq.gz ILLUMINACLIP:combined.fa:2:30:10:8:TRUE LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 -threads 18

        # Make sliding windows
        bedtools makewindows -g psyllid_genomeFile.txt -w 10000 -s 2000 > psyllid.windows.bed

        # Mapping with Bowtie2 (only one of the read pairs were used for sequence depth analysis)
        bowtie2 -x psyllid_dovetail.fasta -U DNA1_pe.1.fq.gz -S DNA1.sam --threads 18
        samtools view -h -b -S DNA1.sam -o DNA1.bam --threads 20
        samtools sort DNA1.bam -o DNA1.sorted.bam --threads 20
        samtools index DNA1.sorted.bam

        # Estimate sequencing depth in sliding windows
        mosdepth -b psyllid.windows.bed -f psyllid_dovetail.fasta -n -t 20 DNA1_mosdepth DNA1.sorted.bam

## 2 - Genome Structural and Functional Annotation

### 2.1 - Genome structural annotation using BRAKER2

- Mapping RNA-seq data to the genome
           
        # Trimmomatic
        java -jar trimmomatic-0.38.jar PE -phred33 1.fastq 2.fastq pe.1.fq.gz se.1.fq.gz pe.2.fq.gz se.2.fq.gz ILLUMINACLIP:combined.fa:2:30:10:8:TRUE LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 -threads 18
        
        # Mapping using HISAT2
        hisat2 -x ../psyllid_dovetail.fasta -1 pe.1.fq.gz -2 pe.2.fq.gz -U se.1.fq.gz,se.2.fq.gz -S combined.sam --phred33 --novel-splicesite-outfile combined.junctions --rna-strandness RF --dta -t --threads 16
        samtools view -h -b -S combined.sam -o combined.bam --threads 20
        samtools sort combined.bam -o combined.sorted.bam --threads 20
        samtools index combined.sorted.bam
        
        # Annotation with BRAKER2
        braker.pl --genome=psyllid_dovetail.fasta --bam=PVEN.00-female.sorted.bam,PVEN.00-male.sorted.bam,PVEN.00-nymphs.sorted.bam,sloan_bact1.sorted.bam,sloan_bact2.sorted.bam,sloan_bact3.sorted.bam,sloan_body1.sorted.bam,sloan_body2.sorted.bam,sloan_body3.sorted.bam,trans1.sorted.bam,trans2.sorted.bam,trans3.sorted.bam,trans4.sorted.bam,trans5.sorted.bam,trans6.sorted.bam,trans7.sorted.bam --softmasking --workingdir=run_all_RNAonly --species=pven_all_RNAonly --cores=32 --gff3
        
        
### 2.2 - Genome functional annotation using GhostKOALA and PANNZER2

- Submit annotated amino acid sequences to: 
        
     GhostKOALA: https://www.kegg.jp/ghostkoala/
        
     PANNER2: http://ekhidna2.biocenter.helsinki.fi/sanspanz/

## 3 - Genome Synteny Analysis
- Run ortholog assignment using OrthoVenn (https://orthovenn2.bioinfotoolkits.net/home)
- Parse the result from OrthoVenn:
        
        # Find single-copy orthologs:
        less -S ortho_all_clusters.txt  | grep "Pvenusta" | grep "Apisum" | grep "Rmaidis" | perl -e 'while(<>){@a=split; if(@a == 3){print} }' > singleCopy.txt
        
        # Convert GFF3 file to MCScanX inputs
        perl combine_locations_in_gff_RBHversion_aphid2maidis.pl singleCopy.homology aphid.ncbi.gff3 maidis.gff aphid2maidis.gff_old
        perl combine_locations_in_gff_RBHversion_aphid2psyllid.pl singleCopy.homology psyllid_RNAonly.augustus.hints.gff3 aphid.ncbi.gff3 aphid2psyllid.gff_old
        
        # Combine aphid2maidis and aphid2psyllid files
        cat aphid2maidis.gff_old aphid2psyllid.gff_old | sort | uniq > singleCopy.gff_old
        
        # Convert GFF3 file to MCScanX input
        perl make_gff_file.pl singleCopy.gff_old chr.list singleCopy.gff
        
        # Run MCScanX_h
        MCScanX_h singleCopy
        
- Visualize synteny using SynVisio: https://synvisio.github.io/

## 4 - Location of Sex-biased Genes

- Count gene expression using HTSeq

        # Run htseq on each sample
        htseq-count -r pos -s no -m intersection-strict --type exon --idattr=Dbxref $i\.unstranded.combined.sorted.bam -f bam GCF_005508785.1_mt_combined.gff 1> $i\.step3_count_exon.table 2> $i\.step3_count_exon.log
        
        # Combine gene count table together
        perl merge_htseq.pl *.step3_count_exon.modified_gff.table | perl -e 'while(<>){s/GeneID\://; print; }' > gene_counts.aphid_sex.table

## 5 - Location of Symbiosis-related Genes

## 6 - Estimating *dN/dS* ratios

## Citation

Li Y., Zhang B., Moran N.A., 2020. The Aphid X Chromosome is a Dangerous Place for Functionally Important Genes: Diverse Evolution of Hemipteran Genomes Based on Chromosome-level Assemblies.

