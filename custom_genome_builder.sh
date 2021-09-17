#!/bin/sh
#------------------------------------------------------------------------------
# BUILDING A CUSTOM GENOME
# Emily Georgiades, Hughes lab
# September 2021
#
# This script has been modified from:
# /t1-data/user/charrold/artificial_locus_project/12LP1_R2/custom_reference_genome/
#------------------------------------------------------------------------------


# -----------------------
# Before running script:
# -----------------------
# working directory must contain:
# (1) edited_region.fa --> i.e. the sequence to be inserted between homology arms
# (2) sym link to genome.fa and genome.fa.fai
# (3) allTheOtherChromosomes.bed --> coordinates for all chroms (see README)
# (4) chrX_split.txt --> coordinates of homology arms + region to delete

# Print all output to log file:
exec > >(tee "$PWD/output.log") 2>&1

start="$(date)"
workingdir="$(pwd)"

echo "----------------------BUILDING A CUSTOM GENOME---------------------"
echo
echo "Run started:  "$start" "
echo "Current working directory is: "$workingdir" "
echo
echo "Loading required modules..."
module purge #Unloads all modules from the users environment
module load bedtools samtools
module list #Prints list of modules and versions

echo "Splitting chrX_split into individual bedfiles"
if ! cat chrX_split.txt | awk '{print $0 > "coordinates_"NR".bed"}'; then
  echo "Could not split chrX_split.txt. Check that file is tab separated."
  exit 1
fi

echo
echo "Generating fasta files for coordinates..."
bedtools getfasta -fi genome.fa -bed coordinates_2.bed -fo coordinates_2.fa
bedtools getfasta -fi genome.fa -bed coordinates_1.bed -fo coordinates_1.fa
bedtools getfasta -fi genome.fa -bed coordinates_3.bed -fo coordinates_3.fa
echo

echo "Removing headers from coordinates fasta files"
tail -n 1 coordinates_1.fa > forCombine_1.fa
tail -n 1 coordinates_3.fa > forCombine_3.fa
echo

echo "Combining the chrX parts"
# 'edited_region.fa' contains the sequence to be inserted between homology arms
paste forCombine_1.fa edited_region.fa forCombine_3.fa | sed 's/\s\s*//g' | sed 's/^/>chrX\n/'> combined_edited_chrX.fa
echo "Quick look at combined_edited_chrX.fa :"
head -n 1 combined_edited_chrX.fa
echo

echo "Gathering the fasta sequences for remaining chromsomes"
if ! bedtools getfasta -fi genome.fa -bed allTheOtherChromosomes.bed -fo allTheOtherChromosomes.fa; then
  echo "Bedtools getfasta error for allTheOtherChromosomes"
  exit 1
fi
echo

echo "Removing coordinates from header lines"
sed -i 's/:.*//' combined_edited_chrX.fa
head -n 1 combined_edited_chrX.fa
sed -i 's/:.*//' allTheOtherChromosomes.fa
head -n 1 allTheOtherChromosomes.fa
echo

echo "Combining the edited chrX and rest of chromosomes"
cat allTheOtherChromosomes.fa combined_edited_chrX.fa > ALL_combined_edited_chrX.fa
echo

echo "Making fasta index"
if ! samtools faidx ALL_combined_edited_chrX.fa ; then
  echo "samtools faidx error"
  exit 1
fi

echo
end="$(date)"
echo "Run completed:  "$end" "
echo
