# rmappet

## Introduction

**rmappet** is a [nextflow](https://www.nextflow.io/) pipeline for parallel alternative splicing analysis of bulk, short-read RNA sequencing data using both [rMATS](https://rnaseq-mats.sourceforge.net/) and [Whippet](https://github.com/timbitz/Whippet.jl). Splicing events reported by each tool are then overlapped by location to identify shared events, providing additional confidence when interpreting the results. Both single- and paired-end data is supported.

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
2. Install [Docker](https://www.docker.com/) for local execution
3. Install [Singularity](https://sylabs.io/) for cluster execution
4. Download and test rmappet in stub mode:

   ```
   nextflow run didrikolofsson/rmappet -profile test,docker -stub
   ```

## Pipeline execution

The pipeline can currently be executed locally using docker or on distributed computing clusters using [SLURM](https://slurm.schedmd.com/) and singularity. Software dependencies are resolved using pre-built docker and singularity images, removing the need for users to manage their own dependenices. This section provides information about the required pipeline inputs and how to execute the pipeline in the supported environments.

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

Examples of sample sheets can be found in the `/data` folder.

### Local execution

Execute the pipeline on a local computer using docker by running the following command. Make sure that the docker daemon is running before launch to avoid errors.

```
nextflow run didrikolofsson/rmappet -profile docker -params-file path/to/params.yaml
```

### Cluster execution

Execute the pipeline on a distributed computing cluster by running the following command. Make sure that the singularity command is accessible on the head node before launch to avoid errors, e.g call `module load singularity` on clusters with a module system.

```
nextflow run didrikolofsson/rmappet -profile slurm,singularity -params-file path/to/params.yaml
```

## Pipeline output

The rmappet pipeline generates a set of output folders and files containing results from the various processing steps. The pipelines output is structured as follows:

```
outputdir
├── fastp
│   ├── sample1.fastp.html
│   └── sample1.fastp.json
├── overlap
│   ├── condition_a_vs_condition_b.rmats_only.csv
│   ├── condition_a_vs_condition_b.rw_overlap.csv
│   ├── condition_a_vs_condition_b.whippet_only.csv
│   ├── condition_a_vs_condition_b.significant.rmats_only.csv
│   ├── condition_a_vs_condition_b.significant.rw_overlap.csv
│   └── condition_a_vs_condition_b.significant.whippet_only.csv
├── rmats
│   ├── results
│   │   ├── condition_a_vs_condition_b.jc.tsv
│   │   ├── condition_a_vs_condition_b.jcec.tsv
│   │   ├── condition_a_vs_condition_b.significant.jc.tsv
│   │   └── condition_a_vs_condition_b.significant.jcec.tsv
│   └── run
│       └── condition_a_vs_condition_b
│           └── condition_a_vs_condition_b.txt
├── samtools
│   └── sort
│       ├── sample1.sortedByCoord.bam
│       └── sample1.sortedByCoord.bam.bai
├── star
│   └── alignments
│       ├── sample1.Log.final.out
│       ├── sample1.ReadsPerGene.out.tab
│       └── sample1.SJ.out.tab
└── whippet
    ├── delta
    │   ├── condition_a_vs_condition_b.diff.gz
    │   └── condition_a_vs_condition_b.significant.tsv
    └── quant
        ├── sample1.gene.tpm.gz
        ├── sample1.isoform.tpm.gz
        ├── sample1.jnc.gz
        ├── sample1.map.gz
        └── sample1.psi.gz
```

## Troubleshooting

Please note that rmappet is currently under active development, and we are still working to fix bugs and add features. If you have any questions, suggestions, or issues, please feel free to contact us or open an issue.

## Contact

Didrik Olofsson ([didrik.olofsson@omiqa.bio](mailto:didrik.olofsson@omiqa.bio))

Dr. Alexander Neumann ([alexander.neumann@omiqa.bio](mailto:alexander.neumann@omiqa.bio))

Prof. Dr. Florian Heyd ([florian.heyd@fu-berlin.de](mailto:florian.heyd@fu-berlin.de))
