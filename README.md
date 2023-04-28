<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![rworkflows](https://github.com/js2264/DNAZooData/actions/workflows/rworkflows.yml/badge.svg)](https://github.com/js2264/DNAZooData/actions/workflows/rworkflows.yml)
<!-- badges: end -->

# DNAZooData

DNAZooData is a data package giving programmatic access 
to Hi-C contact files uniformly processed by the 
[DNA Zoo consortium](https://www.dnazoo.org/). 

The `DNAZooData()` function provides a gateway to DNA Zoo-hosted Hi-C files, 
including contact matrices in `.hic`, genome assemblies in `.fastq` and 
accessory metadata, for individual species

```r
library(DNAZooData)
head(DNAZooData())
DNAZooData(species = 'Aedes_aegypti')
```

## HiCExperiment ecosystem

`DNAZooData` is integrated within the `HiCExperiment` ecosystem in Bioconductor. 
Read more about the `HiCExperiment` class and handling Hi-C data in R 
[here](https://github.com/js2264/HiCExperiment).

![](https://raw.githubusercontent.com/js2264/HiCExperiment/devel/man/figures/HiCExperiment_ecosystem.png)

- [HiCExperiment](https://github.com/js2264/HiCExperiment): Parsing Hi-C files in R
- [HiCool](https://github.com/js2264/HiCool): End-to-end integrated workflow to process fastq files into .cool and .pairs files
- [HiContacts](https://github.com/js2264/HiContacts): Investigating Hi-C results in R
- [HiContactsData](https://github.com/js2264/HiContactsData): Data companion package
- [fourDNData](https://github.com/js2264/fourDNData): Gateway package to 4DN-hosted Hi-C experiments
- [DNAZooData](https://github.com/js2264/DNAZooData): Gateway package to DNA Zoo-hosted Hi-C experiments and genome assemblies

