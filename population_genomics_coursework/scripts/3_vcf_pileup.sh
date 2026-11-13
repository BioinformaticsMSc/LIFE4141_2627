#!/bin/bash
# Script for mpileup in bcftools to generate VCF / BCF file
#SBATCH --partition=XXX
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=stickpileupMQ20
#SBATCH --mem=20g
#SBATCH --time=12:00:00
#SBATCH --array=0-19 #20 individual chromosomes
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all

# In this script we will call variants separately for each chromosome
# we do that to speed things up because this step can otherwise take a long time
# This should take ~30 minutes to run

# load the software
module load bcftools-uoneasy/1.18-GCC-13.2.0

# Load chromosomes names into an array
# Note that for simplicity we are not using chrM (mitochondria), chrY (male sex chr) and chr19 (X chr). 
mapfile -t ROOTS < /share/BioinfMSc/life4141/chr.names.txt
SAMPLE=${ROOTS[$SLURM_ARRAY_TASK_ID]}

# Reference genome and regions
REF=/share/BioinfMSc/life4141/genome/stickleback_v5_assembly.fa
# Set the name of the output vcf files (one for each chromosome)
OUT=XXX/vcf/stick.MQ20.${SAMPLE}.vcf.gz
# txt file listing all bam files, including their absoloute path
# an example file is given here: /share/BioinfMSc/life4141/bam_list.txt
# the example give paths to the bams you can use if you get stuck
# you will need to make a different bam_list.txt file for your own bams
# hint_ you can redirect the output of the ls command to a file
BAMLIST=XXX/bam_list.txt

# Run bcftools mpileup and variant calling
bcftools mpileup \
  --threads 20 \
  -Ou \
  -f "$REF" \
  --min-MQ 20 \
  --min-BQ 30 \
  --platforms ILLUMINA \
  --annotate FORMAT/DP,FORMAT/AD \
  --bam-list "$BAMLIST" \
  -r "${SAMPLE}" |
bcftools call \
  --threads 20 \
  -m \
  -v \
  -a GQ,GP \
  -Oz \
  -o "$OUT"

# index the vcf output
bcftools index $OUT
