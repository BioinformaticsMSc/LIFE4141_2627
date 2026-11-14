#!/bin/bash

# script to filter your VCF file

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --job-name=filter_vcf
#SBATCH --mem=1g
#SBATCH --time=1:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all

# load software
module load bcftools-uoneasy/1.18-GCC-13.2.0
module load vcftools-uoneasy/0.1.16-GCC-12.3.0

# set the path to and name of the input and output files
# remember to replace XXX to the path to wherever you wrote 
VCF_IN=XXX/vcf/stick.vcf.gz
VCF_OUT1=XXX/vcf/stick.70.vcf.gz
VCF_OUT2=XXX/vcf/stick.70b.vcf.gz

# set filters that we will apply to the VCF
MAF=0.05 # Minor allele frequency
MISS=0.70 # Missing data - is inverted, means that genotype call present 70 individuals
QUAL=30 # Quality filter
MIN_DEPTH=1 # Only retain positions that are above a minimum depth of coverage
MAX_DEPTH=50 # Only retain positions that are below a maximum depth of coverage

# Use vcftools to filter data
vcftools \
--gzvcf $VCF_IN \
--remove-indels \
--maf $MAF \
--max-missing $MISS \
--minQ $QUAL \
--min-meanDP $MIN_DEPTH \
--max-meanDP $MAX_DEPTH \
--minDP $MIN_DEPTH \
--maxDP $MAX_DEPTH \
--recode \
--stdout | bgzip -c > $VCF_OUT1

# Index the output VCF
bcftools index $VCF_OUT1

# Keep bi-allelic SNPs, get rid of indels, write file to compressed vcf
bcftools view \
-Oz \
--max-alleles 2 \
--exclude-types indels \
-o $VCF_OUT2 $VCF_OUT1

# Count the number of SNPs in the filtered VCF
bcftools view -H $VCF_OUT2 | wc -l > $VCF_OUT2.SNPS.txt
