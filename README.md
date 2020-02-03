# Analytical pipeline of the hackberry petiole gall psyllid (*Pachypsylla venusta*) genome

This document is a walkthrough of the methods and code used to analyze the chromosome-level genome assembly. In the paper, we used HiC and Chicago libraries to build the chromosome-level assembly and analyzed gene content and sequence evolution of chromosomes. We also produced male and female resequencing data for detecting the X chromosome; male and female RNA-seq data for identifying sex-biased genes.

## 1 - Genome Assembly Verification

### 1.1 - BUSCO analysis

        python run_BUSCO.py -i psyllid_dovetail.fasta -l ./insecta_odb9/ -m geno -f -o psyllid_insecta -c 32

### 1.2 - X chromosome assignment based on sequencing depth of males and females

- Quality control

        # In the trimmomatic adaptor folder:
        cat \*PE.fa > combined.fa

        # Running trimmomatic
        java -jar trimmomatic-0.38.jar PE -phred33 DNA1.1.fq.gz DNA1.2.fq.gz DNA1_pe.1.fq.gz DNA1_se.1.fq.gz DNA1_pe.2.fq.gz DNA1_se.2.fq.gz ILLUMINACLIP:combined.fa:2:30:10:8:TRUE LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 -threads 18

- Make sliding windows

        bedtools makewindows -g psyllid_genomeFile.txt -w 10000 -s 2000 > psyllid.windows.bed

- Mapping with Bowtie2 (only one of the read pairs were used for sequence depth analysis)

        bowtie2 -x psyllid_dovetail.fasta -U DNA1_pe.1.fq.gz -S DNA1.sam --threads 18
        samtools view -h -b -S DNA1.sam -o DNA1.bam --threads 20
        samtools sort DNA1.bam -o DNA1.sorted.bam --threads 20
        samtools index DNA1.sorted.bam

- Estimate sequencing depth in sliding windows

        mosdepth -b psyllid.windows.bed -f psyllid_dovetail.fasta -n -t 20 DNA1_mosdepth DNA1.sorted.bam

## 2 - Genome Structural and Functional Annotation

### 2.1 - Genome structural annotation using BRAKER2

### 2.2 - Genome functional annotation using GhostKOALA and PANNZER2

## 3 - Genome Synteny Analysis

## 4 - Location of Sex-biased Genes

## 5 - Location of Symbiosis-related Genes

## 6 - Estimating *dN/dS* ratios


