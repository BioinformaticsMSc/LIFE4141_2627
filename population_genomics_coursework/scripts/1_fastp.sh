#!/bin/bash
#SBATCH --partition=XXX
#SBATCH --job-name=fastp
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=16g
#SBATCH --time=1:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all
#SBATCH --array=0-44   # Adjust based on number of lines in root_names.txt; first sample is "0"!

# 1 Gb .fq.gz unzips to approximately 4 Gb, fastp needs memory for both R1 and R2
# 1 pair ran in ~3 minutes using these settings, certainly possible to speed it up
# Load fastp software
module load fastp-uoneasy/0.23.4-GCC-12.3.0

# Load the sample names from file names.txt into an array
mapfile -t ROOTS < XXX/names.txt

# Get the current sample name based on SLURM_ARRAY_TASK_ID
SAMPLE=${ROOTS[$SLURM_ARRAY_TASK_ID]}

# Define input files
FILE1=XXX/fastq/${SAMPLE}_R1.fq.gz
FILE2=XXX/fastq/${SAMPLE}_R2.fq.gz

# Output directory
OUTDIR=XXX/trimmed
mkdir -p "$OUTDIR"

# Run fastp: Outputs trimmed sequences and an HTML report
fastp \
  --in1 "$FILE1" \
  --in2 "$FILE2" \
  --out1 "$OUTDIR/${SAMPLE}_R1.trimmed.fq.gz" \
  --out2 "$OUTDIR/${SAMPLE}_R2.trimmed.fq.gz" \
  -l 50 \
  -h "$OUTDIR/${SAMPLE}.html" \
  &> "$OUTDIR/${SAMPLE}.log"

echo "Finished fastp for $SAMPLE"
