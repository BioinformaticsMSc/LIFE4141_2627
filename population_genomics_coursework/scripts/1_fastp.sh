#!/bin/bash

# script to use fastp to trim paired Illumina sequencing reads

#SBATCH --partition=defq
#SBATCH --job-name=fastp
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=16g
#SBATCH --time=1:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all
#SBATCH --array=1-45 # Run 45 iterations of this script, one for each line in /share/BioinfMSc/life4141/names.txt

# Load fastp software
module load fastp-uoneasy/0.23.4-GCC-12.3.0

# Set the sample name for each iteration of this script using SLURM_ARRAY_TASK_ID to print the nth line in the names.txt file
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /share/BioinfMSc/life4141/names.txt)

# Define the input fastq files
FILE1=/share/BioinfMSc/life4141/fastq/${SAMPLE}_R1.fq.gz
FILE2=/share/BioinfMSc/life4141/fastq/${SAMPLE}_R2.fq.gz

# Set the name and path of the directory you want the output to be written to
# NOTE: you will need to replace XXX with the path to wherever you wish to write the output to
OUTDIR=XXX/trimmed

# make the output directory and any parent directories if they don't already exist
mkdir -p $OUTDIR

# Run fastp on the paired fastq files. This outputs trimmed sequences and an HTML report
fastp \
  --in1 "$FILE1" \
  --in2 "$FILE2" \
  --out1 "$OUTDIR/${SAMPLE}_R1.trimmed.fq.gz" \
  --out2 "$OUTDIR/${SAMPLE}_R2.trimmed.fq.gz" \
  -l 50 \
  -h "$OUTDIR/${SAMPLE}.html" \
  &> "$OUTDIR/${SAMPLE}.log"

# write information about what the script did to the slurm output file
echo "Finished fastp for $SAMPLE"
