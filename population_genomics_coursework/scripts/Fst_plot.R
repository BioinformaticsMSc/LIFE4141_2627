# clear your global environment
rm(list=ls())

# set your working directory (replace XXX with the directory you want to work in)
# Ensure you have copied the vcftools fst output from the HPC to your working directory on your laptop
setwd("XXX")

# set the name of your Fst output file (replace with your own file name)
FST_FILE <- "XXX.windowed.weir.fst"

# Load libraries
library(ggplot2)
library(dplyr)

# Import the data (assuming tab-delimited file with header)
fst_data <- read.table(FST_FILE, header = TRUE)

# Filter for chromosome chrI
# Just plot chrI
chrI_data <- fst_data %>% filter(CHROM == "chrI")

# Basic plot: position vs mean Fst
# feel free to extend this plotting code as you like and try different chromosomes etc
ggplot(chrI_data, aes(x = BIN_START, y = MEAN_FST)) +
  geom_point(alpha = 0.6, color = "steelblue") +
  labs(title = "Fst across chrI",
       x = "Position",
       y = "Mean Fst") +
  theme_minimal()
