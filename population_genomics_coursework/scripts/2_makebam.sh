#!/bin/bash

# script to map trimmed sequencing reads to a reference genome with bwa
# then remove duplicate reads using picard
# Note that there are many alternative ways to do this - consider exploring them? 

#SBATCH --partition=defq
#SBATCH --job-name=makebam
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=8g
#SBATCH --time=144:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all
#SBATCH --array=1-45 # Run 45 iterations of this script, one for each line in /share/BioinfMSc/life4141/names.txt

# Load software
module load samtools-uoneasy/1.18-GCC-12.3.0
module load bwa-uoneasy/0.7.17-GCCcore-12.3.0
module load picard-uoneasy/3.0.0-Java-17

# Set the sample name for each iteration of this script using SLURM_ARRAY_TASK_ID to print the nth line in the names.txt file
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /share/BioinfMSc/life4141/names.txt)

# Define the input fastq files
# NOTE: this is the files you made in step 1. You will need to change XXX to the path to wherever you wrote the fastp trimmed files
FILE1=XXX/trimmed/${SAMPLE}_R1.trimmed.fq.gz
FILE2=XXX/trimmed/${SAMPLE}_R2.trimmed.fq.gz

# Define the genome (This must be indexed with bwa, we have done this step for you so you don't all do it with bwa index $REF)
REF=/share/BioinfMSc/life4141/genome/stickleback_v5_assembly.fa

# Set the name and paths of the files you want the outputs to be written to
# NOTE: you will need to replace XXX with the path to wherever you wish to write the output to
OUTFILE1=XXX/bam/${SAMPLE}.sort.bam
OUTFILE2=XXX/bam/${SAMPLE}.rmd.bam

# make the output directory and any parent directories if they don't already exist
mkdir -p bam

# print information about what the script is doing to the slurm output file
echo "Aligning reads for $SAMPLE with bwa"

# Align the reads to the reference genome
# Use help options to understand the syntax
bwa mem \
-M \
-t 8 \
$REF $FILE1 $FILE2 |
samtools view -b |
samtools sort -T $SAMPLE > $OUTFILE1

# Use picard to remove "duplicates" - a duplicate read is a sequence that is exactly the same in both the forward and reverse directions
# A duplicate read in Illumina (or other short-read sequencing) refers to a read that is an exact copy of another read in the dataset, typically originating from the same original DNA fragment. 
# These duplicates are usually PCR duplicates, created during the amplification step in library preparation rather than representing independent molecules from the sample.
# Duplicates inflate read counts, making coverage appear higher than it truly is.
java -Xmx1g -jar $EBROOTPICARD/picard.jar \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT=$OUTFILE1 \
OUTPUT=$OUTFILE2 \
METRICS_FILE=$OUTFILE2.metrics

# index the final bam file
samtools index $OUTFILE2

# remove the bam file with duplicates not removed
rm $OUTFILE
