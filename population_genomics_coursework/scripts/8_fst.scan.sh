#!/bin/bash

# script to run and FST scan using your vcf file

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --job-name=fst_scan
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=1:00:00
#SBATCH --mail-user=YOUR.NAME@nottingham.ac.uk
#SBATCH --mail-type=all

# load initial software
module load vcftools-uoneasy/0.1.16-GCC-12.3.0

# set the output directory for your fst scan
# NOTE: you will need to replace XXX with the path to wherever you want to write the output directory to
OUTDIR=XXX/fst_scan

# make the output directory and any necessary parent directories
mkdir -p $OUTDIR

# set the path to and name of your VCF file
# NOTE: you will need to replace XXX with the path to wherever you wrote your VCF file to in step 5
VCF=XXX/vcf/stick.70b.vcf.gz

# make lists of all individuals in each population for input to vcftools
# (Fst is calcualted between populations)
# we do this by making a list of populations and looping over them
# (the populations are obse, obsm, scad and cist and these form part of the individual names in /share/BioinfMSc/life4141/names.txt)
populations=(obse obsm scad cist)
for population in ${populations[@]}
do
grep -i "$population" /share/BioinfMSc/life4141/names.txt > $OUTDIR/$population.txt
done

# Set up a for loop to calculate pairwise Fst for each unique pair in our list of populations
for ((i = 0; i < ${#populations[@]}; i++)); do
  for ((j = i + 1; j < ${#populations[@]}; j++)); do
    p1=${populations[i]}
    p2=${populations[j]}

# Estimate Fst in windows across the genome
# Best practice to keep only sites with less than 20% of the data missing
# MAF as before - both MAF and missing should have no impact because already filtered on this basis
# 5000 is a suggested window size; you may experiment to see if you can reduce this to the point that adjacent outlier (top 1%) windows start to get similar values.
# --fst-window-step should be the same as --fst-window-size so that windows will not overlap. Change this in concert with window size.
    vcftools \
      --gzvcf $VCF \
      --max-missing 0.8 \
      --maf 0.05 \
      --weir-fst-pop $OUTDIR/$p1.txt \
      --weir-fst-pop $OUTDIR/$p2.txt \
      --fst-window-size 5000 \
      --fst-window-step 5000 \
      --out $OUTDIR/${p1}_${p2}
  done
done
