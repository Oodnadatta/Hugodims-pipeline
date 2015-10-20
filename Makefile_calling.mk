SHELL=/bin/bash
OUTDIR=${HOME}/align20150211/test2
capture.extend.size=500
bedtools.exe=/commun/data/packages/bedtools/bedtools2-2.20.1/bin/bedtools
samtools.exe=/commun/data/packages/samtools/git/samtools/samtools
bcftools.exe=/commun/data/packages/samtools/git/bcftools/bcftools
vcftools.exe=/commun/data/packages/vcftools/vcftools_0.1.12b
REF=/commun/data/pubdb/broadinstitute.org/bundle/1.5/b37/index-bwa-0.7.10/human_g1k_v37.fasta
bgzip.exe=/commun/data/packages/tabix-0.2.6/bgzip
tabix.exe=/commun/data/packages/tabix-0.2.6/tabix
java.exe=/cm/shared/apps/java/jdk1.7.0_60/bin/java
gatk.jar=/commun/data/packages/gatk/3.2.2/GenomeAnalysisTK.jar
gatk.nophone=-et NO_ET -K /commun/data/packages/gatk.no_home.key
.PHONY: all

CHROM= 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y

BAM_LIST= \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20141106/align/Samples/03-05-SA-P/BAM/20141106_03-05-SA-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20141106/align/Samples/01-01-RH-E/BAM/20141106_01-01-RH-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20141106/align/Samples/01-01-RH-P/BAM/20141106_01-01-RH-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20141106/align/Samples/03-05-SA-E/BAM/20141106_03-05-SA-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20141106/align/Samples/03-05-SA-M/BAM/20141106_03-05-SA-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20141106/align/Samples/01-01-RH-M/BAM/20141106_01-01-RH-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/01-06-SC-P/BAM/20150202_01-06-SC-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/02-01-FI-M/BAM/20150202_02-01-FI-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/02-06-GP-E/BAM/20150202_02-06-GP-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/05-01-DR-E/BAM/20150202_05-01-DR-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/05-01-DR-P/BAM/20150202_05-01-DR-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/02-06-GP-M/BAM/20150202_02-06-GP-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/02-01-FI-P/BAM/20150202_02-01-FI-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/01-06-SC-E/BAM/20150202_01-06-SC-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/01-06-SC-M/BAM/20150202_01-06-SC-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/02-01-FI-E/BAM/20150202_02-01-FI-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/02-06-GP-P/BAM/20150202_02-06-GP-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/05-01-DR-M/BAM/20150202_05-01-DR-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/04-01-FL-P/BAM/20150202_04-01-FL-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/05-05-BA-P/BAM/20150202_05-05-BA-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/03-06-BM-E/BAM/20150202_03-06-BM-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/05-05-BA-M/BAM/20150202_05-05-BA-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/06-05-CA-M/BAM/20150202_06-05-CA-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/06-05-CA-E/BAM/20150202_06-05-CA-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/03-06-BM-P/BAM/20150202_03-06-BM-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/05-05-BA-E/BAM/20150202_05-05-BA-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/04-01-FL-M/BAM/20150202_04-01-FL-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/06-05-CA-P/BAM/20150202_06-05-CA-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/04-01-FL-E/BAM/20150202_04-01-FL-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150202/align/Samples/03-06-BM-M/BAM/20150202_03-06-BM-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150306/align/Samples/01-03-ML-E/BAM/20150306_01-03-ML-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150306/align/Samples/01-03-ML-M/BAM/20150306_01-03-ML-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150306/align/Samples/01-03-ML-P/BAM/20150306_01-03-ML-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150306/align/Samples/06-01-GA-E/BAM/20150306_06-01-GA-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150306/align/Samples/06-01-GA-M/BAM/20150306_06-01-GA-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150306/align/Samples/06-01-GA-P/BAM/20150306_06-01-GA-P_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150306/align/Samples/07-01-HN-E/BAM/20150306_07-01-HN-E_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150306/align/Samples/07-01-HN-M/BAM/20150306_07-01-HN-M_final.bam \
	/commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/20150306/align/Samples/07-01-HN-P/BAM/20150306_07-01-HN-P_final.bam

METHODS= unifiedgenotyper samtools hapcal

#Concatenate vcf split per chromosome for a given caller + generate an index.
#$(1): a caller in ${METHODS}

define concat

${OUTDIR}/VCF/$(1).annot.vcf.gz: $(foreach C,${CHROM},${OUTDIR}/VCF/$(1)$(C).annot.vcf.gz)
	perl -I ${vcftools.exe}/perl ${vcftools.exe}/bin/vcf-concat $$^ > $$(addsuffix .tmp, $$@ )
	${bgzip.exe} -f $$(addsuffix .tmp, $$@ ) && \
	${tabix.exe} -f -p vcf $$(addsuffix .tmp.gz, $$@ )
	mv  $$(addsuffix .tmp.gz, $$@ ) $$@ && \
	mv  $$(addsuffix .tmp.gz.tbi, $$@ ) $$(addsuffix .tbi, $$@ )

endef

#Annotate vcf with SnpEff and VEP for a given caller + generate an index.
#$(1): output (here: $(OUTDIR)/VCF/${M}${C}.annot.vcf.gz)
#$(2): input (here: $(OUTDIR)/VCF/${M}${C}.vcf.gz)

define annot

$(1): $(2)
	mkdir -p $$(dir $$@) && \
	gunzip -c $$< > $$(addsuffix .tmp1.vcf, $$@ ) && \
	$${java.exe} -jar /commun/data/packages/snpEff/snpEff_4_0/snpEff.jar eff GRCh37.75  \
			-i vcf \
			-o vcf \
			-nodownload \
			-sequenceOntology \
			-lof \
			-c /commun/data/packages/snpEff/snpEff_4_0/snpEff.config \
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

#Call variants with SAMtools, Unified Genotyper from GATK and Haplotype Caller from GATK. Vcf are split by chromosome to save time.
#$(1):a chromosome from ${CHROM}

define calling

$(OUTDIR)/VCF/samtools$(1).vcf.gz : bam.list $(OUTDIR)/BED/fusion$(1).bed
	mkdir -p $$(dir $$@)  && \
	${samtools.exe} mpileup --uncompressed --BCF --output-tags DP,DV,DP4,SP  \
		--max-depth 10000 \
		--max-idepth 10000 \
		--redo-BAQ --adjust-MQ 50 --min-ireads 3 --gap-frac 0.002  --min-MQ 30 \
		--positions $$(filter %.bed,$$^)\
		-r "$(1)" \
		--fasta-ref $(REF) \
		--bam-list $$< | \
	${bcftools.exe} call --output-type u --variants-only --multiallelic-caller --format-fields GQ,GP  - |\
	${bcftools.exe} filter --exclude 'MAX(DP)<10' --output-type v - > $$(addsuffix .tmp.vcf,$$@) && \
	${java.exe} -Xmx250m  -Djava.io.tmpdir=$$(dir $$@) -jar ${gatk.jar} -T VariantAnnotator \
		-R $(REF) ${gatk.nophone} \
		-L:capture,BED ${OUTDIR}/BED/fusion$(1).bed \
		--variant $$(addsuffix .tmp.vcf,$$@) \
		-o $$(addsuffix .tmp2.vcf, $$@ ) \
		--dbsnp /commun/data/pubdb/ncbi/snp/organisms/human_9606/VCF/GRCh37_dbsnp138_00-All.vcf.gz && \
	${bgzip.exe} -f $$(addsuffix .tmp2.vcf,$$@) && \
	mv $$(addsuffix .tmp2.vcf.gz,$$@) $$@ && \
	rm -f $$(addsuffix .tmp.vcf,$$@) $$(addsuffix .tmp.vcf.idx,$$@) $$(addsuffix .tmp2.vcf.idx,$$@)


$(OUTDIR)/VCF/unifiedgenotyper$(1).vcf.gz : bam.list $(OUTDIR)/BED/fusion$(1).bed
	mkdir -p $$(dir $$@)  && \
	${java.exe} -Xmx10g   -jar /commun/data/packages/gatk/3.2.2/GenomeAnalysisTK.jar -T UnifiedGenotyper \
	-et NO_ET -K /commun/data/packages/gatk.no_home.key -nt 16 \
	-R $(REF)  -glm BOTH -S SILENT --downsample_to_coverage  40000 \
	-L:capture,BED ${OUTDIR}/BED/fusion$(1).bed \
	-I bam.list \
	--dbsnp:vcfinput,VCF /commun/data/pubdb/ncbi/snp/organisms/human_9606/VCF/GRCh37_dbsnp138_00-All.vcf.gz \
	-o $(addsuffix .tmp.vcf,$$@) && \
	${bgzip.exe}  $(addsuffix .tmp.vcf,$$@)  && \
	mv $(addsuffix .tmp.vcf.gz,$$@) $$@


$(OUTDIR)/VCF/hapcal$(1).vcf.gz : bam.list $(OUTDIR)/BED/fusion$(1).bed
	mkdir -p $$(dir $$@) && \
	${java.exe} -Xmx5g -jar ${gatk.jar} \
		-T HaplotypeCaller \
		-et NO_ET -K /commun/data/packages/gatk.no_home.key \
		-R $(REF) \
		-stand_call_conf 50.0 \
		-stand_emit_conf 10.0 \
		-S SILENT \
		-L:capture,BED $(OUTDIR)/BED/fusion$(1).bed -I bam.list \
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
	grep '^$(1)	' $$^ > $$@

endef

all: \
	$(foreach M,${METHODS},$(OUTDIR)/VCF/${M}.annot.vcf.gz) \

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

$(eval $(foreach M,${METHODS},$(call concat,${M})))
$(eval $(foreach M,${METHODS},$(foreach C,${CHROM},$(call annot,$(OUTDIR)/VCF/${M}${C}.annot.vcf.gz,$(OUTDIR)/VCF/${M}${C}.vcf.gz))))
$(eval $(foreach C,${CHROM},$(call calling,${C})))
$(eval $(foreach C,${CHROM},$(call bedchrom,${C})))

#Create a file with the names of bam in it. It is regenerated everytime the list changes.

bam.list: ${BAM_LIST}
	rm -f $@
	$(foreach B,$(filter %.bam,$^),echo "${B}" >> $@ ; )

clean:
	rm -rf ${OUTDIR}/VCF
	rm -rf ${OUTDIR}/BED
	rm -f bam.list