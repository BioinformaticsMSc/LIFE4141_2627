#!/bin/bash

# script to run and FST scan using your vcf file

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --job-name=fst_scan
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=2:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all

# load initial software (here there is a software conflict so we will load and unload them as we use them in the script)
module load bcftools-uoneasy/1.19-GCC-13.2.0

# make an output directory for your fst scan
# NOTE: you will need to replace XXX with the path to wherever you want to write the output directory to
mkdir -p XXX/fst_scan


# set the path to and name of your VCF file
# NOTE: you will need to replace XXX with the path to wherever you wrote your VCF file to in step 5
VCF=XXX/vcf/stick.100b.vcf.gz

# Use this command to extract individual names (which will the include path)
bcftools query -l $VCF 
# Basic script to estimate Fst in windows across the genome
# Example code for vcftools Fst window scan in obse vs obsm contrast
module load vcftools-uoneasy/0.1.16-GCC-12.3.0
vcftools --gzvcf vcf/stick.100b.vcf.gz \
--max-missing 0.8 \
--maf 0.05 \
--weir-fst-pop obse.txt \
--weir-fst-pop obsm.txt \
--fst-window-size 5000 \
--fst-window-step 5000

# Best practice to keep only sites with less than 20% of the data missing
# MAF as before - both MAF and missing should have no impact because already filtered on this basis
# A suggested window size; you may experiment to see if you can reduce this to the point that adjacent outlier (top 1%) windows start to get similar values.
# Means windows will not overlap with the above window-size. Change in concert with that value.

# Plain text files required for the above according to vcftools manual, list of the membership of each population:
