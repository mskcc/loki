[![GitHub Actions CI Status](https://github.com/mskcc/loki/workflows/nf-core%20CI/badge.svg)](https://github.com/mskcc/loki/actions?query=workflow%3A%22nf-core+CI%22)
[![GitHub Actions Linting Status](https://github.com/mskcc/loki/workflows/nf-core%20linting/badge.svg)](https://github.com/mskcc/loki/actions?query=workflow%3A%22nf-core+linting%22)[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Nextflow Tower](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Nextflow%20Tower-%234256e7)](https://tower.nf/launch?pipeline=https://github.com/mskcc/loki)

## Introduction

**mskcc/loki** is a bioinformatics pipeline that calculates Copy Number Variation (CNV) mutation data from a Tumor/Normal Bam pair. The pipeline uses MSKCC Facets/Facets-suite and calculates pileups using MKSCC Htstools.

![Loki graph](docs/images/Loki.png)

1. Calculate pileups ([`htstools`](https://github.com/mskcc/htstools/releases/tag/snp_pileup_0.1.1))
2. Calculate CNV results ([`Facets-suite`](https://github.com/mskcc/facets-suite/releases/tag/2.0.9))

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

#### Running nextflow @ MSKCC

If you are runnning this pipeline on a MSKCC cluster you need to make sure nextflow is properly configured for the HPC envirornment:

```bash
module load java/jdk-17.0.8
module load singularity/3.7.1
export PATH=$PATH:/path/to/nextflow/binary
export SINGULARITY_TMPDIR=/path/to/network/storage/for/singularity/tmp/files
export NXF_SINGULARITY_CACHEDIR=/path/to/network/storage/for/singularity/cache
```

### Running the pipeline

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
pairId,tumorBam,normalBam,assay,normalType,bedFile
pair_sample,/bam/path/foo_tumor.rg.md.abra.printreads.bam,/bam/path/foo_normal.rg.md.abra.printreads.bam,IMPACT505,MATCHED,NONE
```

> [!IMPORTANT]
> Make sure the bams have an index file associated with it either file.bam.bai or file.bai should work

Now, you can run the pipeline using:

<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->

```bash
nextflow run main.nf \
   -profile singularity,test_juno \
   --input samplesheet.csv \
   --outdir <OUTDIR>
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

## Credits

mskcc/loki was originally written by Nikhil Kumar [@nikhil](https://github.com/nikhil).

<!--We thank the following people for their extensive assistance in the development of this pipeline: -->

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use  mskcc/loki for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
