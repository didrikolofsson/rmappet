# rmappet

## Introduction

**rmappet** is a nextflow pipeline for parallel alternative splicing analysis on bulk, short-read RNA sequencing data using both [rMATS](https://rnaseq-mats.sourceforge.net/) and [Whippet](https://github.com/timbitz/Whippet.jl). Coordinates of the splicing events reported by each tool are then overlapped to identify shared events, providing additional confidence when interpreting the results. Both single- and paired-end data is supported.

## Pipeline summary

1. Raw read quality control and trimming ([Fastp](https://github.com/OpenGene/fastp))
2. **rMATS** - Alternative splicing analysis
   1. Build STAR genome index ([STAR](https://github.com/alexdobin/STAR))
   2. Align trimmed reads ([STAR](https://github.com/alexdobin/STAR))
   3. Sort and index alignments ([Samtools](http://www.htslib.org/))
   4. Alternative splicing analysis using rMATS ([rMATS](http://www.htslib.org/))
   5. Standardize rMATS results
3. **Whippet** - Alternative splicing analysis
   1. Build whippet genome index ([Whippet](https://github.com/timbitz/Whippet.jl))
   2. Quantify splicing events ([Whippet](https://github.com/timbitz/Whippet.jl))
   3. Alternative splicing analysis using Whippet ([Whippet](https://github.com/timbitz/Whippet.jl))
4. Overlap splicing coordinates

## Get started

1. Install [Nextflow](https://www.nextflow.io/) (>=22.10.3)
2. Install [Docker](https://www.docker.com/) and/or [Singularity](https://sylabs.io/)
3. Download and test rmappet:

   ```
   nextflow run DidrikOlofsson/rmappet -profile test -stub
   ```

## Pipeline execution

The pipeline can currently be executed in the following computing environments:

1. Local computers with docker
2. Distributed computing clusters with SLURM and Singularity

This section contains information about required pipeline inputs and instructions on how to execute the pipeline in the supported environments.

### Required inputs

#### Parameter file

A parameter file with necessary settings and file paths must be supplied when executing the pipeline. The parameter file should be in [YAML](https://www.cloudbees.com/blog/yaml-tutorial-everything-you-need-get-started) format and contain the following information:

- **dev** - Run the pipeline in development mode using a single sample for testing
- **samplesheet** - Path to sample sheet in csv format
- **genome** - Path to genome fasta
- **annotation** - Path to genome annotation in GTF format
- **outputdir** - Path to output directory
- **readlen** - Read length
- **libtype** - Library type

Example parameter files for both single and paired end experiments can be found in the `/data` folder.

#### Sample sheet

A sample sheet with information about the experimental design should be included together with the parameter file. The sample sheet should be in CSV format and contain the following columns and information:

| sample_id | read1                      | read2                      | condition   |
| --------- | -------------------------- | -------------------------- | ----------- |
| sample1   | path/to/sample1_1.fastq.gz | path/to/sample1_2.fastq.gz | condition_a |
| sample2   | path/to/sample2_1.fastq.gz | path/to/sample2_2.fastq.gz | condition_a |
| sample3   | path/to/sample3_1.fastq.gz | path/to/sample3_2.fastq.gz | condition_a |
| sample4   | path/to/sample4_1.fastq.gz | path/to/sample4_2.fastq.gz | condition_b |
| sample5   | path/to/sample5_1.fastq.gz | path/to/sample5_2.fastq.gz | condition_b |
| sample6   | path/to/sample6_1.fastq.gz | path/to/sample6_2.fastq.gz | condition_b |

Example sample sheets can be found in the `/data` folder.

### Local execution

### Cluster execution
