#!/bin/bash

# script to generate a phylogeny from your VCF file

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --job-name=phylogeny
#SBATCH --cpus-per-task=8
#SBATCH --mem=5G
#SBATCH --time=12:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all

# load software
module load raxml-ng-uoneasy/1.2.0-GCC-12.3.0

# Set your input VCF file
# NOTE: you will need to change XXX for the path to the filtered VCF file you generated with script 5
INPUT=XXX/vcf/stick.70b.vcf.gz

# set a directory for the output files of this analysis
# NOTE: make sure you change XXX to the path you want to use
OUTDIR=XXX/phylogeny

# make the output directory and parents if they don't already exist
mkdir -p $OUTDIR

# move to the output directory
cd $OUTDIR

# The first step is to convert the vcf to phylip format using python script
python /share/BioinfMSc/vcf2phylip.py \
-i $INPUT \
-o $(basename ${INPUT%.*.*}).phy

# Use raxml to make a bootstrapped phylogeny
# This may take some time to run even with small datasets
# GTR is model of evolution assumed
raxml-ng \
--all \
--msa $(basename ${INPUT%.*.*}).min4.phy \
--threads 8 \
--force perf_threads \
--model GTR \
--prefix $(basename ${INPUT%.*.*}) \
--bs-trees 100

# there are many softwares available to visualise trees, output is Newick Standard Format, have a go with some to view your tree
