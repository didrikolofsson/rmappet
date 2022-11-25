# rmappet

## Introduction

**rmappet** is a nextflow pipeline for performing parallel alternative splicing analysis on bulk, short-read RNA sequencing data using both [rMATS](https://rnaseq-mats.sourceforge.net/) and [Whippet](https://github.com/timbitz/Whippet.jl). The splicing events reported by each tool are then overlapped to identify shared events, providing additional confidence when interpreting the results.

## Pipeline summary

1. Raw read quality control and trimming ([Fastp](https://github.com/OpenGene/fastp))
2. Alternative splicing analysis with rMATS
   1. Build STAR genome index ([STAR](https://github.com/alexdobin/STAR))
   2. Align trimmed reads ([STAR](https://github.com/alexdobin/STAR))
   3. Sort and index alignments ([Samtools](http://www.htslib.org/))
   4. Perform alternative splicing analysis using rMATS ([rMATS](http://www.htslib.org/))
   5. Standardise rMATS results
3. Alternative splicing analysis with Whippet
   1. Build whippet genome index ([Whippet](https://github.com/timbitz/Whippet.jl))
   2. Quantify splicing events ([Whippet](https://github.com/timbitz/Whippet.jl))
   3. Perform differential splicing analysis ([Whippet](https://github.com/timbitz/Whippet.jl))
4. Overlap alternative splicing results reported by rMATS and whippet

## Instructions

1. Install [Nextflow](https://www.nextflow.io/) (>=22.10.3)
2. Install [Docker](https://www.docker.com/) and/or [Singularity](https://sylabs.io/)
3. Download the rmappet pipeline with the following command:

   ```
    nextflow pull DidrikOlofsson/rmappet
   ```

## Citations

## Contact
