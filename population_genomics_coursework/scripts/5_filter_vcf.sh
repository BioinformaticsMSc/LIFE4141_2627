#!/bin/bash
#SBATCH --partition=XXX
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --job-name=filter
#SBATCH --mem=1g
#SBATCH --time=48:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all

# load software
module load bcftools-uoneasy/1.18-GCC-13.2.0
module load vcftools-uoneasy/0.1.16-GCC-12.3.0

# set variables
VCF_IN=XXX/vcf/stick.vcf.gz
VCF_OUT=XXX/vcf/stick.70.vcf.gz

# set filters
# Minor allele frequency
MAF=0.05
# Missing data - is inverted, means that genotype call present 70 individuals
MISS=0.70
# Quality filter
QUAL=30
# Only retain positions that are enither to deeply sequenced or at low depth - both may be due to errors 
MIN_DEPTH=1
MAX_DEPTH=50

# Use vcftools to filter data
vcftools --gzvcf $VCF_IN \
--remove-indels --maf $MAF --max-missing $MISS --minQ $QUAL \
--min-meanDP $MIN_DEPTH --max-meanDP $MAX_DEPTH \
--minDP $MIN_DEPTH --maxDP $MAX_DEPTH --recode --stdout | bgzip -c >
$VCF_OUT

# Index
bcftools index $VCF_OUT

# Use bcftools to only retain biallelic sites
VCFB=XXX/vcf/stick.70b.vcf.gz

# Keep bi-allelic SNPs, get rid of indels, write file to compressed vcf
bcftools view -Oz --max-alleles 2 --exclude-types indels -o $VCFB $VCF_OUT
# Count number of SNPs in filtered VCF
bcftools view -H $VCFB | wc -l > $VCFB.SNPS.txt
