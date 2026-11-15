#!/bin/bash

# script to prepare input files for plink and perform a PCA

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --job-name=pcaprep
#SBATCH --mem=1g
#SBATCH --time=00:30:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all

# load software
module load plink-uoneasy/2.00a3.7-foss-2023a

# An assumption of PCA is that the data is independent, this is not the case for genomic data
# The first step is to prune variants that are in linkage
# This will make series of new files so best to make a new directory and run within that
# set the path to where you want this directory to be saved by changing XXX
mkdir -p XXX/plink

# move to the directory you created
cd XXX/plink

# Set the vcf to use - start with the most filtered, smallest file
# You can also try this with the unfiltered vcf and see what difference the filtering made
# NOTE: you will need to replace XXX with the path to wherever you wrote your VCF file to in step 5
VCF=XXX/vcf/stick.70b.vcf.gz

# Perform linkage pruning - i.e. identify prune sites
# Like many softwares plink was developed for use on human genomes, so we have to edit the expectation
# --double-id duplicates the ID of samples, plink typically expects pedigree data, not necessary for us
# --allow-extra-chr plink expects human chromosomes!
# --set-missing-var-ids - so plink does not look for annotated ID names for SNPs
# --indep-pairwise set a window of 50kb and 10 bp window, set r-squared threshold - prune any that show a threshold greater than 0.1

# Identify sites to prune 
plink \
--vcf $VCF \
--double-id \
--allow-extra-chr \
--set-missing-var-ids @:# \
--indep-pairwise 50 10 0.1 \
--out stick

# Prune and create PCA
# --extract only use those positions for pca
plink \
--vcf $VCF \
--double-id \
--allow-extra-chr \
--set-missing-var-ids @:# \
--extract stick.prune.in \
--make-bed \
--pca \
--out stick
