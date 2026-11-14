#!/bin/bash

# Script for mpileup in bcftools to generate VCF / BCF file

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=stickpileupMQ20
#SBATCH --mem=20g
#SBATCH --time=12:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all
#SBATCH --array=1-20 # Run 20 iterations of this script, one for each line in /share/BioinfMSc/life4141/chr.names.txt

# In this script we will call variants separately for each chromosome
# we do that to speed things up because this step can otherwise take a long time

# load the software
module load bcftools-uoneasy/1.18-GCC-13.2.0

# Set the chromosome name for each iteration of this script using SLURM_ARRAY_TASK_ID to print the nth line in the chr.names.txt file
# Note that for simplicity we are not using chrM (mitochondria), chrY (male sex chr) and chr19 (X chr).
CHROMOSOME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /share/BioinfMSc/life4141/chr.names.txt)

# Set the path to and name of the reference genome
REF=/share/BioinfMSc/life4141/genome/stickleback_v5_assembly.fa

# Set the name and path of the output vcf files (one for each chromosome)
# NOTE: you will need to replace XXX with the path to wherever you wish to write the output to
OUTFILE=XXX/vcf/stick.MQ20.$CHROMOSOME.vcf.gz

# make the output directory and parent directories if they don't already exist
mkdir -p $(dirname $OUTFILE)

# Set the list of all bam files to call variants for, including their absoloute path
# an example file is given here: /share/BioinfMSc/life4141/bam_list.txt
# the example give paths to the bams you can use if you get stuck
# you will need to make a different bam_list.txt file for your own bams
# hint_ you can redirect the output of the ls command to a file
BAMLIST=XXX/bam_list.txt

# Run bcftools mpileup and variant calling
bcftools mpileup \
  --threads 20 \
  -Ou \
  -f $REF \
  --min-MQ 20 \
  --min-BQ 30 \
  --platforms ILLUMINA \
  --annotate FORMAT/DP,FORMAT/AD \
  --bam-list $BAMLIST \
  -r $CHROMOSOME |
bcftools call \
  --threads 20 \
  -m \
  -v \
  -a GQ,GP \
  -Oz \
  -o $OUTFILE

# index the vcf output
bcftools index $OUTFILE
