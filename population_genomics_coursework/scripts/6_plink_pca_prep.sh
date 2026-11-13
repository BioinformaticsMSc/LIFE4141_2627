#!/bin/bash
#SBATCH --partition=XXX
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --job-name=pcaprep
#SBATCH --mem=1g
#SBATCH --time=48:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all

# load software
module load plink-uoneasy/2.00a3.7-foss-2023a

# Assumption of PCA is that data is independent
# Not the case for genomic data
# First step is to prune variants that are in linkage
# This will make series of new files so best to make a new directory and run within that
# set the path to where you want this directory to be saved by changing XXX
mkdir -p XXX/plink
cd plink

# Set vcf to use - start with the most filtered, smallest file
VCF=XXX/vcf/stick.100b.vcf.gz

# Perform linkage pruning - i.e. identify prune sites
# Like many softwares plink was developed for use on human genomes, so we have to edit the expectation
# --double-id duplicates the ID of samples, plink typically expects pedigree data, not necessary for us
# --allow-extra-chr plink expects human chromosomes!
# --set-missing-var-ids - so plink does not look for annotated ID names for SNPs
# --indep-pairwise set a window of 50kb and 10 bp window, set r-squared threshold - prune any that show a threshold greater than 0.1

# Identify sites to prune 
plink \
--vcf "$VCF" \
--double-id \
--allow-extra-chr \
--set-missing-var-ids @:# \
--indep-pairwise 50 10 0.1 \
--out stick

# Prune and create PCA
# --extract only use those positions for pca
plink \
--vcf "$VCF" \
--double-id \
--allow-extra-chr \
--set-missing-var-ids @:# \
--extract stick.prune.in \
--make-bed \
--pca \
--out stick
