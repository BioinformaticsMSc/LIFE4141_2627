#!/bin/bash
#SBATCH --partition=XXX
#SBATCH --job-name=makebam
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=8g
#SBATCH --time=144:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all
#SBATCH --array=1-44   # Adjust based on number of lines in root_names.txt; first sample is "0"!

# Script to align reads to the stickleback reference genome, outputting a bam file
# then remove duplicate reads
# Note that there are many alternative ways to do this - consider exploring? 

# Load software
module load samtools-uoneasy/1.18-GCC-12.3.0
module load bwa-uoneasy/0.7.17-GCCcore-12.3.0
module load picard-uoneasy/3.0.0-Java-17

# You need to index the reference genome, once only
bwa index XXX/genome/stickleback_v5_assembly.fa

# Load sample names into an array
mapfile -t ROOTS < XXX/names.txt

# Get the current sample name based on SLURM_ARRAY_TASK_ID
SAMPLE=${ROOTS[$SLURM_ARRAY_TASK_ID]}

# Set file paths
# Fastp trimmed reads
FILE=XXX/trimmed/${SAMPLE}
FILE1=XXX/trimmed/${SAMPLE}_R1.trimmed.fq.gz
FILE2=XXX/trimmed/${SAMPLE}_R2.trimmed.fq.gz
# Downsampled reads
#FILE=XXX/downsample/${SAMPLE}
#FILE1=XXX/downsample/${SAMPLE}_R1.downsample.fq.gz
#FILE2=XXX/downsample/${SAMPLE}_R2.downsample.fq.gz

# Reference genome (Needs to be indexed with bwa, above)
REF=XXX/genome/stickleback_v5_assembly.fa
# Outfile 
mkdir -p bam
OUTFILE=bam/${SAMPLE}.sort.bam

# Align reads using combination of bwa mem and samtools
# Use help options to understand syntax
        echo "Aligning ${SAMPLE} with bwa"
        bwa mem -M -t 8 $REF $FILE1 \
        $FILE2 | samtools view -b |
        samtools sort -T ${SAMPLE} > $OUTFILE

# Use picard to remove "duplicates" - a duplicate read is a sequence that is exactly the same in both the forward and reverse directions
# A duplicate read in Illumina (or other short-read sequencing) refers to a read that is an exact copy of another read in the dataset, typically originating from the same original DNA fragment. 
# These duplicates are usually PCR duplicates, created during the amplification step in library preparation rather than representing independent molecules from the sample.
# Duplicates inflate read counts, making coverage appear higher than it truly is.
# Multiple identical reads from the same fragment can make a variant look more supported than it is.
java -Xmx1g -jar $EBROOTPICARD/picard.jar \
MarkDuplicates REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT="$OUTFILE" \
OUTPUT=bam/${SAMPLE}.rmd.bam \
METRICS_FILE=bam/${SAMPLE}.rmd.bam.metrics

# index the final bam file
samtools index bam/${SAMPLE}.rmd.bam

# remove the bam file with duplicates not removed
rm $OUTFILE
