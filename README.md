This README is not up to date

## Welcome to Project Hugodims

The cause of the intellectual disability is not found in half of the cases with current techniques used in diagnosis.
Our goal with this study is to identify molecular causes implicated in unexplained intellectual disability.
We used high throughput exome sequencing with a _de novo_ strategy in 75 trios.
Each trio is composed of a patient and his parents.
What is the _de novo_ strategy? It consists in looking for mutations that occur during meiosis, which means the child has them but not his parents.

We have created a custom bioinformatic pipeline.
* The first steps are usual: alignment of the sequences on the reference human genome and data recalibration to improve the quality of results.
* We use 3 variant callers which compare the exome of the samples to the reference human genome.
The next step annotates the variants with data like gene names or if the variant is in a UTR region.
* Only heterozygous _de novo_ variants and coding and splicing variants are conserved.
Then, variants with a frequency higher than 0.1 % based on public databases are filtered out.
Remaining variants are removed if they are found in any parent.

### Usage

```

make -f [Makefile]

```
* The Makefile which performs the alignment and the data recalibration is not available here.
* The Makefile to use to do the variant calling and the annotation is Makefile_calling.
* The Makefile to use to do the filtering is Makefile_filtering. The filtering consists in keeping _de novo_, coding or splicing and rare variants.

### Authors
* Anne-Sophie Denommé-Pichon
* Supervisor: Pierre Lindenbaum

