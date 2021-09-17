# Custom Genome Builder :hammer_and_wrench: :dna:
#### Emily Georgiades, Hughes Group (September 2021)
Scripts to build a custom genome in order to align sequencing reads from edited cell lines.

This is a modified version of Caz's existing script, which can be found here:   
```
/t1-data/project/fgenomics/shared/AA_previous_group_members/charrold/artificial_locus_project/12LP1_R2/custom_reference_genome/generating_custom_genome/
```


---
#### Required files:
1.  [__edited_region.fa__](./edited_region.fa)            
    This contains the sequence to be inserted between homology arms
    
2.  __genome.fa__                   
    Use a symbolic link i.e.  
    ```$ ln -s /path/to/file genome.fa ```
    
3.  __genome.fa.fai__               
     Use a symbolic link i.e.  
    ```$ ln -s /path/to/file genome.fa ```
    
4.  [__allTheOtherChromosomes.bed__](./allTheOtherChromosomes.bed)  
    Coordinates for all other chromosomes. Download chrom.sizes from UCSC, remember to delete the chromosome that you're editing:
    ```
    $ wget https://hgdownload.cse.ucsc.edu/goldenpath/mm39/bigZips/mm39.chrom.sizes 
    $ awk -v OFS='\t' '{print $1, 0, $2}' mm39.chrom.sizes > allTheOtherChromosomes.bed
    ```

5.  [__chrX_split.txt__](./chrX_split.txt)               
    Need to know coordinates of edited chromosome + deletion region.  
    File should look like this (must be tab separated):   
    ```
    chrX  0   xxxx  part_1  ## The chromosome up to deletion region
    chrX  xxxx  xxxx  part_2  ## WT region that is being swapped for the insert sequence. 
    chrX  xxxx  xxxx part_3  ## The remaining chromosome after deletion region.
    ```
