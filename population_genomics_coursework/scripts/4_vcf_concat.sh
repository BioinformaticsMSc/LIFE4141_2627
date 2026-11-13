#!/bin/bash

#SBATCH --partition=XXX
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=stickpileupMQ20
#SBATCH --mem=20g
#SBATCH --time=24:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all

# load software
module load bcftools-uoneasy/1.18-GCC-13.2.0

# set variables
# you will need to make a file listing the names of, and absoloute path to, each chromosome VCF file in step 3
# an example file is provided here that lists the vcf files you can use if you get stuck:
# /share/BioinfMSc/life4141/vcf.list.txt
VCFLIST=XXX/vcf.list.txt
# specify where you want the output file to be written and what it should be called
OUT=XXX/vcf/stick.vcf.gz

# Concatenate all of the single chromosome vcf files into one vcf file
bcftools concat \
--file-list $VCFLIST \
-Oz \
--output $OUT

# index the final vcf file
bcftools index $OUT
