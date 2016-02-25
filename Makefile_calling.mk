SHELL=/bin/bash
OUTDIR=${HOME}/align20150211/test10
TMPDIR=${HOME}/Hugodims/tmp
THREADS=4
capture.extend.size=500
bedtools.exe=/commun/data/packages/bedtools/bedtools2-2.20.1/bin/bedtools
samtools.exe=/commun/data/packages/samtools/git/samtools/samtools
bcftools.exe=/commun/data/packages/samtools/git/bcftools/bcftools
vcftools.exe=/commun/data/packages/vcftools/vcftools_0.1.12b
REF=/commun/data/pubdb/broadinstitute.org/bundle/1.5/b37/index-bwa-0.7.10/human_g1k_v37.fasta
MILLS=/commun/data/pubdb/broadinstitute.org/bundle/1.5/b37/Mills_and_1000G_gold_standard.indels.b37.vcf
DBSNP=/commun/data/pubdb/broadinstitute.org/bundle/1.5/b37/dbsnp_138.b37.vcf
HAPMAP=/commun/data/pubdb/broadinstitute.org/bundle/1.5/b37/hapmap_3.3.b37.vcf
OMNI=/commun/data/pubdb/broadinstitute.org/bundle/1.5/b37/1000G_omni2.5.b37.vcf
OTG=/commun/data/pubdb/broadinstitute.org/bundle/1.5/b37/1000G_phase1.snps.high_confidence.b37.vcf
bgzip.exe=/commun/data/packages/tabix-0.2.6/bgzip
tabix.exe=/commun/data/packages/tabix-0.2.6/tabix
java.exe=/cm/shared/apps/java/jdk1.7.0_60/bin/java
gatk.jar=/commun/data/packages/gatk/3.2.2/GenomeAnalysisTK.jar
gatk.nophone=-et NO_ET -K /commun/data/packages/gatk.no_home.key
SOURCES=${HOME}/src/SnpEff

.PHONY: all

CHROM= 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57
SAMPLES=$(shell find /commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/ -name '*_final.bam' | grep -v '20151209' | grep -v '20160104.*09-03-PA')

METHODS= hapcal

#Concatenate vcf split per chromosome for a given caller + generate an index.
#$(1): a caller in ${METHODS}

define samplename
$(shell echo $(1) | sed 's@^.*/Samples/\([^/]*\)/BAM/.*$$@\1@')
endef

define vqsr

# Filter variants on VQSR results
${OUTDIR}/VCF/$(1)_all.annot_vqsr.vcf: ${OUTDIR}/VCF/$(1)_all.annot.all_recalibrated.vcf ${REF}
	java -jar ${gatk.jar} \
		-nt ${THREADS} \
		-T SelectVariants \
	                -env \
		-R ${REF} \
		-V ${OUTDIR}/VCF/$(1)_all.annot.all_recalibrated.vcf \
		-o $$@

# Apply VQSR model for SNPs
${OUTDIR}/VCF/$(1)_all.annot.all_recalibrated.vcf: ${OUTDIR}/VCF/$(1)_all.annot.snp_recalibrated.vcf ${OUTDIR}/VCF/$(1)_all.annot.indels.recal ${OUTDIR}/VCF/$(1)_all.annot.indels.tranches ${REF}
	java -jar ${gatk.jar} \
		-T ApplyRecalibration \
		-mode INDEL \
		-R ${REF} \
		-input ${OUTDIR}/VCF/$(1)_all.annot.snp_recalibrated.vcf \
		--ts_filter_level 99.0 \
		-recalFile ${OUTDIR}/VCF/$(1)_all.annot.indels.recal \
		-tranchesFile ${OUTDIR}/VCF/$(1)_all.annot.indels.tranches \
		-o $$@

# # Compute VQSR model for indels
${OUTDIR}/VCF/$(1)_all.annot.indels.recal: ${OUTDIR}/VCF/$(1)_all.annot.snp_recalibrated.vcf ${REF} ${MILLS} ${DBSNP}
	java -jar ${gatk.jar} \
		-nt ${THREADS} \
		-T VariantRecalibrator \
		-mode INDEL \
		-R ${REF} \
		-input ${OUTDIR}/VCF/$(1)_all.annot.vcf.gz \
		-resource:mills,known=false,training=true,truth=true,prior=12.0 ${MILLS} \
		-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${DBSNP} \
			-an FS \
			-an MQRankSum \
			-an QD \
			-an ReadPosRankSum \
		--maxGaussians 4 \
		-recalFile ${OUTDIR}/VCF/$(1)_all.annot.indels.recal \
		-tranchesFile ${OUTDIR}/VCF/$(1)_all.annot.indels.tranches

# TODO FIXME add with GATK 3.5:			-an SOR \

${OUTDIR}/VCF/$(1)_all.annot.indels.tranches: ${OUTDIR}/VCF/$(1)_all.annot.indels.recal
	touch $$@

# TODO if nbSamples > 10 and unrelated, add -an InbreedingCoeff
# Apply VQSR model for SNPs
${OUTDIR}/VCF/$(1)_all.annot.snp_recalibrated.vcf: ${OUTDIR}/VCF/$(1)_all.annot.vcf.gz ${OUTDIR}/VCF/$(1)_all.annot.snp.recal ${OUTDIR}/VCF/$(1)_all.annot.snp.tranches ${REF}
	java -jar ${gatk.jar} \
		-T ApplyRecalibration \
		-mode SNP \
		-R ${REF} \
		-input ${OUTDIR}/VCF/$(1)_all.annot.vcf.gz \
		--ts_filter_level 99.5 \
		-recalFile ${OUTDIR}/VCF/$(1)_all.annot.snp.recal \
		-tranchesFile ${OUTDIR}/VCF/$(1)_all.annot.snp.tranches \
		-o $$@

# TODO FIXME once using GATK 3.5		-an InbreedingCoeff \

# Compute VQSR model for SNPs
${OUTDIR}/VCF/$(1)_all.annot.snp.recal: ${OUTDIR}/VCF/$(1)_all.annot.vcf.gz ${REF} ${HAPMAP} ${OMNI} ${OTG} ${DBSNP}
	java -jar ${gatk.jar} \
		-nt ${THREADS} \
		-T VariantRecalibrator \
		-mode SNP \
		-R ${REF} \
		-input ${OUTDIR}/VCF/$(1)_all.annot.vcf.gz \
		-resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${HAPMAP} \
		-resource:omni,known=false,training=true,truth=true,prior=12.0 ${OMNI} \
		-resource:1000G,known=false,training=true,truth=false,prior=10.0 ${OTG} \
		-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${DBSNP} \
			-an FS \
			-an MQ \
			-an MQRankSum \
			-an QD \
			-an ReadPosRankSum \
		-recalFile ${OUTDIR}/VCF/$(1)_all.annot.snp.recal \
		-tranchesFile ${OUTDIR}/VCF/$(1)_all.annot.snp.tranches

# TODO FIXME add with GATK 3.5:			-an SOR \

${OUTDIR}/VCF/$(1)_all.annot.snp.tranches: ${OUTDIR}/VCF/$(1)_all.annot.snp.recal
	touch $$@

endef

#Annotate vcf with SnpEff and VEP for a given caller + generate an index.
#$(1): output (here: $(OUTDIR)/VCF/${M}${C}.annot.vcf.gz)
#$(2): input (here: $(OUTDIR)/VCF/${M}${C}.vcf.gz)

define annot

$(1): $(2)
	mkdir -p $$(dir $$@) && \
	gunzip -c $$< > $$(addsuffix .tmp1.vcf, $$@ ) && \
	$${java.exe} -jar ${SOURCES}/snpEff.jar eff GRCh37.75  \
			-i vcf \
			-o vcf \
			-nodownload \
			-sequenceOntology \
			-lof \
			-c ${SOURCES}/snpEff.config \
			-s $$(addsuffix .snpeff.report,$$@) \
			$$(addsuffix .tmp1.vcf, $$@ )  > $$(addsuffix .tmp2.vcf, $$@ )  && \
	mv $$(addsuffix .tmp2.vcf, $$@ ) $$(addsuffix .tmp1.vcf, $$@ ) && \
	/commun/data/packages/vep/ensembl-tools-release-76/scripts/variant_effect_predictor/variant_effect_predictor.pl  \
		--cache --dir /commun/data/pubdb/ensembl/vep/cache --write_cache  \
		--species homo_sapiens \
		--assembly GRCh37 \
		--db_version 76 \
		--fasta $(REF) \
		--offline \
		--symbol \
		--format vcf \
		--force_overwrite \
		--sift=b \
		--polyphen=b \
		--refseq \
		--xref_refseq \
		-i $$(addsuffix .tmp1.vcf, $$@ ) \
		-o $$(addsuffix .tmp2.vcf, $$@ ) \
		--quiet --vcf	--no_stats && \
	${bgzip.exe} -f $$(addsuffix .tmp2.vcf, $$@ ) && \
	${tabix.exe} -f -p vcf $$(addsuffix .tmp2.vcf.gz, $$@ )


	mv  $$(addsuffix .tmp2.vcf.gz, $$@ ) $$@ && \
	mv  $$(addsuffix .tmp2.vcf.gz.tbi, $$@ ) $$(addsuffix .tbi, $$@ ) 

endef

# Combine and genotype all gVCF in one VCF
define combine

${OUTDIR}/VCF/$(1)_all.vcf.gz: ${OUTDIR}/VCF/$(1)_combine.vcf.gz
	java -jar ${gatk.jar} \
			-T GenotypeGVCFs \
			-R ${REF} \
			--variant $$< \
			-o $$@

${OUTDIR}/VCF/$(1)_combine.vcf.gz: $(foreach S,${SAMPLES},${OUTDIR}/VCF/$(1)_$(call samplename,$(S)).vcf.gz)
	java -jar ${gatk.jar} \
			-T CombineGVCFs \
			-R ${REF} \
			$(foreach S,${SAMPLES},--variant ${OUTDIR}/VCF/$(1)_$(call samplename,$(S)).vcf.gz) \
			-o $$@

endef

define concat

${OUTDIR}/VCF/$(1)_$(call samplename,$(2)).vcf.gz: $(foreach C,${CHROM},${OUTDIR}/VCF/$(1)_$(call samplename,$(2))_$(C).vcf.gz)
	perl -I ${vcftools.exe}/perl ${vcftools.exe}/bin/vcf-concat $$^ > $$(addsuffix .tmp1, $$@ )
	perl -I ${vcftools.exe}/perl ${vcftools.exe}/bin/vcf-sort -t ${TMPDIR} $$(addsuffix .tmp1, $$@ ) > $$(addsuffix .tmp2, $$@ )
	${bgzip.exe} -f $$(addsuffix .tmp2, $$@ ) && \
	${tabix.exe} -f -p vcf $$(addsuffix .tmp2.gz, $$@ )
	mv  $$(addsuffix .tmp2.gz, $$@ ) $$@ && \
	mv  $$(addsuffix .tmp2.gz.tbi, $$@ ) $$(addsuffix .tbi, $$@ )

endef


#Call variants with Haplotype Caller from GATK. Vcf are split by chromosome to save time.
#$(1):a part of the exome.

define calling

$(OUTDIR)/VCF/hapcal_$(call samplename,$(1))_$(2).vcf.gz : $(OUTDIR)/BED/fusion$(2).bed
	mkdir -p $$(dir $$@) && \
	${java.exe} -Xmx5g -jar ${gatk.jar} \
		-T HaplotypeCaller \
			-ERC GVCF \
			--variant_index_type LINEAR \
			--variant_index_parameter 128000 \
		-et NO_ET -K /commun/data/packages/gatk.no_home.key \
		-R $(REF) \
		-stand_call_conf 50.0 \
		-stand_emit_conf 10.0 \
		-S SILENT \
		-L:capture,BED $(OUTDIR)/BED/fusion$(2).bed -I $(1) \
		--dbsnp:vcfinput,VCF /commun/data/pubdb/ncbi/snp/organisms/human_9606/VCF/GRCh37_dbsnp138_00-All.vcf.gz \
		-o $$(basename $$@).tmp.vcf && \
	${java.exe} -jar /commun/data/packages/jvarkit-git/sortvcfonref2.jar \
-T $$(dir $$@) \
		-R ${REF} $$(basename $$@).tmp.vcf | \
		${bgzip.exe} -c > $$@ && \
		${tabix.exe} -f -p vcf $$@ \
	&& rm $$(basename $$@).tmp.vcf && \
	rm -f $$(basename $$@).tmp.vcf $$(basename $$@).tmp.vcf.idx

endef

#Create a bed file from the capture for a given chromosome.
#$(1): a chromosome from ${CHROM}

define bedchrom

$(OUTDIR)/BED/fusion$(1).bed: $(OUTDIR)/BED/fusion.bed
	sed -n "$$$$(((($(1)-1)*2000)+1)),$$$$(($(1)*2000))p" $$^ > $$@

endef

all: $(foreach M,${METHODS},$(OUTDIR)/VCF/${M}_all.annot_vqsr.vcf)
	echo "J'ai fini !"

#Create a bed from the capture.

$(OUTDIR)/BED/fusion.bed : /commun/data/pubdb/agilent/designs/S06588914/S06588914_Covered_noprefix.bed \
			/commun/data/pubdb/agilent/designs/S04380110/S04380110_Covered_noprefix.bed
	mkdir -p $(dir $@) && \
	cat $^ | grep -vE '(^browser|^track)' |\
	cut -f1,2,3 |\
	${bedtools.exe} slop -b ${capture.extend.size} -g $(addsuffix .fai,${REF}) -i - |\
	LC_ALL=C sort -t '	' -k1,1 -k2,2n -k3,3n |\
	${bedtools.exe} merge -d ${capture.extend.size} -i - > $(addsuffix .tmp,$@) && \
	mv  $(addsuffix .tmp,$@) $@

$(eval $(foreach M,${METHODS},$(call vqsr,${M})))
$(eval $(foreach M,${METHODS},$(call annot,$(OUTDIR)/VCF/${M}_all.annot.vcf.gz,$(OUTDIR)/VCF/${M}_all.vcf.gz)))
$(eval $(foreach M,${METHODS},$(call combine,${M})))
$(eval $(foreach M,${METHODS},$(foreach S,${SAMPLES},$(call concat,${M},${S}))))
$(eval $(foreach S,${SAMPLES},$(foreach C,${CHROM},$(call calling,${S},${C}))))
$(eval $(foreach C,${CHROM},$(call bedchrom,${C})))

#Create a file with the names of bam in it. It is regenerated everytime the list changes.

clean:
	rm -rf ${OUTDIR}/VCF
	rm -rf ${OUTDIR}/BED

