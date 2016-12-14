.PHONY : all clean
#Pour l'ajout de nouveaux patients, modifier la variable TRIOS, pas besoin de modifier parents.list (auto).
#Variables
SHELL=/bin/bash
SAMPLEDIR=/commun/data/users/asdp/align20150211/call20160810/VCF
JVARKIT=/commun/data/packages/jvarkit-git
GUNZIP=/bin/gunzip
JAVA=/commun/data/packages/jdk/jdk1.8.0_60/bin/java -Xmx16g
GZIP=/bin/gzip
CAT=/bin/cat
ECHO=/bin/echo
GREP=/bin/grep
SED=/bin/sed
RM=/bin/rm
TAR=/bin/tar
AWK=/bin/awk
SORT=/bin/sort
VCFSCRIPTS=/commun/data/users/asdp/Hugodims/VCFscripts
TABIX=/commun/data/packages/tabix-0.2.6
DB=${HOME}/src
SNPEFF=${HOME}/src/snpEff
BEDTOOLS=/commun/data/packages/bedtools/bedtools2-2.25.0/bin
GENESDILST=regovar_genespanel_intellectual_disability_201600918.lst
SEXLST=sex_list.tsv
PARBED=PAR.bed
REF=/commun/data/pubdb/broadinstitute.org/bundle/1.5/b37/index-bwa-0.7.10/human_g1k_v37.fasta
HZNCOM=${VCFSCRIPTS}/20160921_full_0.0001-0.01-0.005/hz_n_compositeEFF.py
FLTR=${VCFSCRIPTS}/20160921_full_0.0001-0.01-0.005/fltr.py

#Variants dont la fréquence est strictement supérieure à FREQUENCY
DENOVO_FREQUENCY= 0.0001
HETEROZYGOUSREC_FREQUENCY= 0.01
HOMOZYGOUSREC_FREQUENCY= 0.01
XLINKED_FREQUENCY= 0.005

FREQUENCIES=$(sort ${DENOVO_FREQUENCY} ${HETEROZYGOUSREC_FREQUENCY} ${HOMOZYGOUSREC_FREQUENCY} ${XLINKED_FREQUENCY})

PIPE= trio vartrio varchild varchildexon predict pass depth gonl_nogenotype $(foreach F, ${FREQUENCIES}, gonl_genotype_${F}) $(foreach F, ${FREQUENCIES}, evs_nogenotype_${F}) $(foreach F, ${FREQUENCIES}, evs_genotype_${F}) incompats genotype parents_nogenotype parents_genotype $(foreach F, ${FREQUENCIES}, exac_genotype_${F}) heterozygous_rec homozygous_rec heterozygous_rec.genesdi homozygous_rec.genesdi xlinked parents_genotype.annot.rvis heterozygous_rec.annot.rvis homozygous_rec.annot.rvis xlinked.annot.rvis parents_genotype.annot.cadd heterozygous_rec.annot.cadd homozygous_rec.annot.cadd xlinked.annot.cadd

TRIOS = \
	trio01|03-05-SA-E|03-05-SA-M|03-05-SA-P \
	trio02|01-01-RH-E|01-01-RH-M|01-01-RH-P \
	trio03|01-06-SC-E|01-06-SC-M|01-06-SC-P \
	trio04|05-01-DR-E|05-01-DR-M|05-01-DR-P \
	trio05|02-01-FI-E|02-01-FI-M|02-01-FI-P \
	trio06|02-06-GP-E|02-06-GP-M|02-06-GP-P \
	trio07|04-01-FL-E|04-01-FL-M|04-01-FL-P \
	trio08|05-05-BA-E|05-05-BA-M|05-05-BA-P \
	trio09|03-06-BM-E|03-06-BM-M|03-06-BM-P \
	trio10|06-05-CA-E|06-05-CA-M|06-05-CA-P \
	trio11|07-01-HN-E|07-01-HN-M|07-01-HN-P \
	trio12|06-01-GA-E|06-01-GA-M|06-01-GA-P \
	trio13|01-03-ML-E|01-03-ML-M|01-03-ML-P \
	trio14|03-01-CC-E|03-01-CC-M|03-01-CC-P \
	trio15|04-06-DL-E|04-06-DL-M|04-06-DL-P \
	trio16|07-05-VT-E|07-05-VT-M|07-05-VT-P \
	trio17|08-01-PA-E|08-01-PA-M|08-01-PA-P \
	trio18|08-05-RA-E|08-05-RA-M|08-05-RA-P \
	trio19|10-01-BL-E|10-01-BL-M|10-01-BL-P \
	trio20|05-06-BD-E|05-06-BD-M|05-06-BD-P \
	trio21|09-01-GC-E|09-01-GC-M|09-01-GC-P \
	trio22|02-05-AS-E|02-05-AS-M|02-05-AS-P \
	trio23|01-05-HT-E|01-05-HT-M|01-05-HT-P \
	trio24|01-02-CF-E|01-02-CF-M|01-02-CF-P \
	trio25|06-06-PT-E|06-06-PT-M|06-06-PT-P \
	trio26|03-02-BE-E|03-02-BE-M|03-02-BE-P \
	trio27|04-04-TT-E|04-04-TT-M|04-04-TT-P \
	trio28|02-03-SJ-E|02-03-SJ-M|02-03-SJ-P \
	trio29|09-05-DK-E|09-05-DK-M|09-05-DK-P \
	trio30|11-01-GC-E|11-01-GC-M|11-01-GC-P \
	trio31|01-04-CL-E|01-04-CL-M|01-04-CL-P \
	trio32|04-05-DA-E|04-05-DA-M|04-05-DA-P \
	trio33|02-04-SY-E|02-04-SY-M|02-04-SY-P \
	trio34|13-01-LM-E|13-01-LM-M|13-01-LM-P \
	trio35|08-06-LZ-E|08-06-LZ-M|08-06-LZ-P \
	trio36|03-04-DE-E|03-04-DE-M|03-04-DE-P \
	trio37|07-06-MT-E|07-06-MT-M|07-06-MT-P \
	trio38|06-04-JM-E|06-04-JM-M|06-04-JM-P \
	trio39|12-06-RE-E|12-06-RE-M|12-06-RE-P \
	trio40|08-02-SC-E|08-02-SC-M|08-02-SC-P \
	trio41|07-02-GG-E|07-02-GG-M|07-02-GG-P \
	trio42|11-02-LE-E|11-02-LE-M|11-02-LE-P \
	trio43|11-05-JM-E|11-05-JM-M|11-05-JM-P \
	trio44|10-02-DE-E|10-02-DE-M|10-02-DE-P \
	trio45|06-02-LK-E|06-02-LK-M|06-02-LK-P \
	trio46|02-02-MA-E|02-02-MA-M|02-02-MA-P \
	trio47|04-02-JG-E|04-02-JG-M|04-02-JG-P \
	trio48|08-03-VL-E|08-03-VL-M|08-03-VL-P \
	trio49|09-03-PA-E|09-03-PA-M|09-03-PA-P \
	trio50|06-03-TC-E|06-03-TC-M|06-03-TC-P \
	trio51|11-03-QL-E|11-03-QL-M|11-03-QL-P \
	trio52|12-03-HK-E|12-03-HK-M|12-03-HK-P \
	trio53|10-03-BS-E|10-03-BS-M|10-03-BS-P \
	trio54|08-04-VO-E|08-04-VO-M|08-04-VO-P \
	trio55|09-02-TL-E|09-02-TL-M|09-02-Tl-P \
	trio56|09-04-BE-E|09-04-BE-M|09-04-BE-P \
	trio57|07-04-RE-E|07-04-RE-M|07-04-RE-P \
	trio58|10-04-ML-E|10-04-ML-M|10-04-ML-P \
	trio59|13-03-RM-E|13-03-RM-M|13-03-RM-P \
	trio60|16-03-CM-E|16-03-CM-M|16-03-CM-P \
	trio61|11-06-BB-E|11-06-BB-M|11-06-BB-P \
	trio62|14-03-HG-E|14-03-HG-M|14-03-HG-P \
	trio63|12-05-PB-E|12-05-PB-M|12-05-PB-P \
	trio64|05-02-SL-E|05-02-SL-M|05-02-SL-P \
	trio65|13-06-PN-E|13-06-PN-M|13-06-PN-P \
	trio66|05-03-RC-E|05-03-RC-M|05-03-RC-P \
	trio67|15-01-RC-E|15-01-RC-M|15-01-RC-P \
	trio68|13-05-BM-E|13-05-BM-M|13-05-BM-P \
	trio69|16-01-FA-E|16-01-FA-M|16-01-FA-P

METHODS= hapcal

ANNOTATE= parents_genotype homozygous_rec heterozygous_rec xlinked

#Fonctions

define trioid
$(word 1,$(subst |, ,$(1)))
endef

define triofather
$(word 4,$(subst |, ,$(1)))
endef

define triomother
$(word 3,$(subst |, ,$(1)))
endef

define triochild
$(word 2,$(subst |, ,$(1)))
endef

define pipecount

#Compte le nombre de variants obtenus à chaque étape (tableau : étape	nombre)
pipecount.$(1).$(call triochild,$(2)).log : $(foreach F, ${PIPE}, $(1).$(call triochild,$(2)).${F}.vcf.gz)
	> $$@
	for f in ${PIPE}; \
	do \
		${ECHO} "$$$$f.vcf.gz	`${GUNZIP} -c $(1).$(call triochild,$(2)).$$$$f.vcf.gz |\
		${GREP} -v '^#' |\
		wc -l`" >> $$@; \
	done

endef

#Retirer les variants des parents de la parentsdb, puis Tabix sur la parentsdb_trio avec création de l'index
define parentsdb1

$(1).parentsdb.vcf.gz : ${SAMPLEDIR}/$(1)_all.annot.vcf.gz parents.list
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcfcutsamples.jar -r -f parents.list |\
	${GZIP} --best > $$@ && \
	test $$$${PIPESTATUS[1]} -eq 0

endef

define parentsdb2

$(1).parentsdb_$(call triochild,$(2)).vcf.gz.tbi : $(1).parentsdb_$(call triochild,$(2)).vcf.gz
	${TABIX}/tabix -p vcf $$^

$(1).parentsdb_$(call triochild,$(2)).vcf.gz : $(1).parentsdb.vcf.gz
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcfcutsamples.jar -v -S $$(call triomother,$(2)) -S $$(call triofather,$(2)) |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'function hasAlt(v) { for(var i=0;i< variant.getNSamples();++i) { var g=variant.getGenotype(i); if(g.isHomVar() || g.isHet()) return true; } return false;} hasAlt(variant);' |\
	${TABIX}/bgzip > $$@

endef 

define annotate_trio

$(1).$(call triochild,$(2)).$(3).annot.cadd.vcf.gz: $(1).$(call triochild,$(2)).$(3).annot.cadd.vcf
	${GZIP} --best < $$< > $$@

$(1).$(call triochild,$(2)).$(3).annot.cadd.vcf: $(1).$(call triochild,$(2)).$(3).annot.rvis.vcf
	${FLTR} --cadd $$< $$@

$(1).$(call triochild,$(2)).$(3).annot.rvis.vcf.gz: $(1).$(call triochild,$(2)).$(3).annot.rvis.vcf
	${GZIP} --best < $$< > $$@

$(1).$(call triochild,$(2)).$(3).annot.rvis.vcf: $(1).$(call triochild,$(2)).$(3).annot.vcf
	${FLTR} --rvis $$< $$@

$(1).$(call triochild,$(2)).$(3).annot.vcf : $(1).$(call triochild,$(2)).$(3).vcf.gz
	zgrep -q -v '^#' $$< && \
	/commun/data/packages/vep/ensembl-tools-release-76/scripts/variant_effect_predictor/variant_effect_predictor.pl  \
		--cache --dir /commun/data/pubdb/ensembl/vep/cache --write_cache  \
		--species homo_sapiens \
		--assembly GRCh37 \
		--db_version 76 \
		--fasta ${REF} \
		--offline \
		--symbol \
		--format vcf \
		--force_overwrite \
		--sift=b \
		--polyphen=b \
		--refseq \
		--gmaf \
		--maf_1kg \
		--maf_esp \
		--everything \
		--pubmed \
		--xref_refseq \
		--quiet --vcf	--no_stats \
		-i $$^ \
		-o $$(addsuffix .tmp.vcf, $$@) && \
	${JAVA} -jar ${SNPEFF}/SnpSift.jar dbnsfp -v -db ${DB}/dbNsfp/2.9.1_hg19_20160330.vcf.gz $$(addsuffix .tmp.vcf, $$@) > $$(addsuffix .tmp2.vcf, $$@) && \
	${JAVA} -jar ${SNPEFF}/SnpSift.jar annotate -id ${DB}/dbSNP/human_9606_b147_GRCh37p13_all_20160601.vcf.gz -v $$(addsuffix .tmp2.vcf, $$@) > $$(addsuffix .tmp3.vcf, $$@) && \
	${JAVA} -jar ${SNPEFF}/SnpSift.jar annotate -id ${DB}/clinvar/GRCh37_20160831.vcf.gz -v $$(addsuffix .tmp3.vcf, $$@) > $$@ && \
	rm $$(addsuffix .tmp.vcf, $$@) $$(addsuffix .tmp2.vcf, $$@) $$(addsuffix .tmp3.vcf, $$@) || \
	zcat $$< > $$@
endef

define analyse_trio_with_frequency

#filtrer sur ExAC (AVEC génotype)
$(1).$(call triochild,$(2)).exac_genotype_$(3).vcf.gz :  $(1).$(call triochild,$(2)).gonl_genotype_$(3).vcf.gz ExAC.r0.3.sites.vep_$(3).vcf.gz
	${JAVA} -jar ${JVARKIT}/vcfresetvcf.jar -r -x  ExAC.r0.3.sites.vep_$(3).vcf.gz $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() ' |\
	${GZIP} --best > $$@

#filtrer sur evs (>= FREQUENCY, pas de prise en compte du génotype)
$(1).$(call triochild,$(2)).evs_nogenotype_$(3).vcf.gz : $(1).$(call triochild,$(2)).gonl_genotype_$(3).vcf.gz
	${BEDTOOLS}/bedtools intersect -header -wa -v -a $$^ -b <(${TAR} Oxfz ${VCFSCRIPTS}/20150126_evs/vcftools/ESP6500SI-V2.GRCh38-liftover.coverage.all_sites.txt.tar.gz  |\
	${AWK} -F ' ' '(NF>=9 && int($$$$3)>=650)' | cut -d ' ' -f1,2 |\
	${AWK} -F ' ' '{printf("%s\t%d\t%d\n",$$$$1,int($$$$2),int($$$$2)+1);}' |\
	LC_ALL=C ${SORT} -T /commun/data/users/asdp/Hugodims/tmp -t '	' -k1,1 -k2,2n) |\
	${GZIP} --best > $$@ && \
	test $$$${PIPESTATUS[0]} -eq 0

#filter sur evs (>= FREQUENCY, AVEC génotype)
#-r remove whole variant if there is no called genotype
$(1).$(call triochild,$(2)).evs_genotype_$(3).vcf.gz : $(1).$(call triochild,$(2)).gonl_genotype_$(3).vcf.gz evs.20150206_$(3).vcf.gz
	${JAVA} -jar ${JVARKIT}/vcfresetvcf.jar -r -x evs.20150206_$(3).vcf.gz $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() ' |\
	${GZIP} --best > $$@ && \
	test $$$${PIPESTATUS[0]} -eq 0

#filtrer sur GoNL (>= FREQUENCY, AVEC génotype)
#-r remove whole variant if there is no called genotype
$(1).$(call triochild,$(2)).gonl_genotype_$(3).vcf.gz : $(1).$(call triochild,$(2)).depth.vcf.gz release4_noContam_noChildren_with_AN_AC_GTC_stripped_$(3).vcf.gz
	${JAVA} -jar ${JVARKIT}/vcfresetvcf.jar -r -x release4_noContam_noChildren_with_AN_AC_GTC_stripped_$(3).vcf.gz $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() ' |\
	${GZIP} --best > $(addsuffix .tmp.gz,$$@) && \
	test $$$${PIPESTATUS[0]} -eq 0 && \
	mv $(addsuffix .tmp.gz,$$@) $$@

endef

define analyse_trio

#filtrer avec hz_n_compositeEFF
$(1).$(call triochild,$(2)).xlinked.vcf.gz : $(1).$(call triochild,$(2)).exac_genotype_${XLINKED_FREQUENCY}.vcf.gz ${SEXLST} ${PARBED}
	( grep -q "$$$$(echo $(call triochild,$(2)) | sed 's/-E//').*M" ${SEXLST} && ( \
	    ${GUNZIP} -c $$< |\
	    ${HZNCOM} -xlinked-male \
        ) || ( \
	    ${GUNZIP} -c $$< |\
            grep '^\(#\|[^ 	]*[xX]\)' \
        ) ) | \
        ${BEDTOOLS}/bedtools intersect -header -wa -v -a stdin -b ${PARBED} |\
	perl -I /commun/data/packages/vcftools/vcftools_0.1.12b/perl/ /commun/data/packages/vcftools/vcftools_0.1.12b/bin/vcf-sort -c -t /commun/data/users/asdp/Hugodims/tmp |\
	${TABIX}/bgzip > $$@ && \
	${TABIX}/tabix -p vcf $$@

#filtrer avec hz_n_compositeEFF
$(1).$(call triochild,$(2)).heterozygous_rec.vcf.gz : $(1).$(call triochild,$(2)).exac_genotype_${HETEROZYGOUSREC_FREQUENCY}.vcf.gz
	${GUNZIP} -c $$^ |\
	${HZNCOM} -heterozygous |\
	perl -I /commun/data/packages/vcftools/vcftools_0.1.12b/perl/ /commun/data/packages/vcftools/vcftools_0.1.12b/bin/vcf-sort -c -t /commun/data/users/asdp/Hugodims/tmp |\
	${TABIX}/bgzip > $$@ && \
	${TABIX}/tabix -p vcf $$@

#filtrer avec hz_n_compositeEFF
$(1).$(call triochild,$(2)).homozygous_rec.vcf.gz : $(1).$(call triochild,$(2)).exac_genotype_${HOMOZYGOUSREC_FREQUENCY}.vcf.gz
	${GUNZIP} -c $$^ |\
	${HZNCOM} -homozygous |\
	perl -I /commun/data/packages/vcftools/vcftools_0.1.12b/perl/ /commun/data/packages/vcftools/vcftools_0.1.12b/bin/vcf-sort -c -t /commun/data/users/asdp/Hugodims/tmp |\
	${TABIX}/bgzip > $$@ && \
	${TABIX}/tabix -p vcf $$@

#Filtrer les vcf avec parentsdb_trio (AVEC genotype)
$(1).$(call triochild,$(2)).parents_genotype.vcf.gz : $(1).$(call triochild,$(2)).genotype.vcf.gz $(1).parentsdb_$(call triochild,$(2)).vcf.gz $(1).parentsdb_$(call triochild,$(2)).vcf.gz.tbi
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcfresetvcf.jar -r -x $(1).parentsdb_$(call triochild,$(2)).vcf.gz |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() ' |\
	${TABIX}/bgzip > $$@ && \
	${TABIX}/tabix -p vcf $$@

#filtrer les vcf avec parentsdb_trio (SANS génotype)
$(1).$(call triochild,$(2)).parents_nogenotype.vcf.gz : $(1).$(call triochild,$(2)).genotype.vcf.gz $(1).parentsdb_$(call triochild,$(2)).vcf.gz
	${BEDTOOLS}/bedtools intersect -header -wa -v -a $$< -b $(1).parentsdb_$(call triochild,$(2)).vcf.gz |\
	${GZIP} --best > $$@ && \
	test $$$${PIPESTATUS[0]} -eq 0 

#filtrer sur GoNL (>= FREQUENCY, SANS génotype)
$(1).$(call triochild,$(2)).gonl_nogenotype.vcf.gz : $(1).$(call triochild,$(2)).predict.vcf.gz
	${BEDTOOLS}/bedtools intersect -header -wa -v -a <(gunzip -c $$^) -b <(gunzip -c ${VCFSCRIPTS}/20150209_GoNLgeno/release4_noContam_noChildren_with_AN_AC_GTC_stripped_0.01.gz |\
	cut -d '	' -f1,2 |\
	${AWK} -F '	' '{printf("%s\t%d\t%d\n",$$$$1,int($$$$2),int($$$$2)+1);}' |\
	LC_ALL=C ${SORT} -T /commun/data/users/asdp/Hugodims/tmp -t '	' -k1,1 -k2,2n) |\
	${GZIP} --best > $$@ && \
	test $$$${PIPESTATUS[0]} -eq 0

#Sélectionner variants où DP > 5 chez l'enfant
$(1).$(call triochild,$(2)).depth.vcf.gz : $(1).$(call triochild,$(2)).pass.vcf.gz
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").getDP()>5' |\
	${GZIP} --best > $$@

#Supprimer les variants sans le filtre PASS
$(1).$(call triochild,$(2)).pass.vcf.gz : $(1).$(call triochild,$(2)).predict.vcf.gz
	${GUNZIP} -c $$^ |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.isFiltered()==false' |\
	${GZIP} --best > $$@

#Filter a VCF file annotated with SNPEff or VEP with term exon_variant (from Sequence-Ontology)
$(1).$(call triochild,$(2)).predict.vcf.gz : $(1).$(call triochild,$(2)).varchild.vcf.gz
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterso.jar -A SO:0001818 SO:0001590 SO:0001572 SO:0001629 SO:0001569 SO:0001630 -- |\
	${GZIP} --best > $$@ && \
	test $$$${PIPESTATUS[1]} -eq 0

#Excludes all sites ./. (E+P), 0/0 (E), hz (E), 0/parent (E)
$(1).$(call triochild,$(2)).genotype.vcf.gz : $(1).$(call triochild,$(2)).incompats.vcf.gz ${VCFSCRIPTS}/20150121_denovo/jvarkit/filtertrio.js
	${SED} -e 's/__CHILD__/$(call triochild,$(2))/g' -e 's/__FATHER__/$(call triofather,$(2))/g' -e 's/__MOTHER__/$(call triomother,$(2))/g' $$(filter %.js,$$^) > $$(addsuffix .tmp.js,$$@) && \
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -f $$(addsuffix .tmp.js,$$@) |\
	${GZIP} --best > $$@ && \
	test $$$${PIPESTATUS[1]} -eq 0 && \
	${RM} -f $(addsuffix .tmp.js,$$@)

#Excludes all sites without the incompatibilities flag (MENDEL)
$(1).$(call triochild,$(2)).incompats.vcf.gz : $(1).$(call triochild,$(2)).evs_genotype_${DENOVO_FREQUENCY}.vcf.gz pedigree.txt
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcftrio.jar -p $$(filter %.txt,$$^) |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.hasAttribute("MENDEL")' |\
	${GZIP} --best > $$@ && \
	test $$$${PIPESTATUS[1]} -eq 0

#Filter a VCF file annotated with SNPEff or VEP with term exon_variant (from Sequence-Ontology)
$(1).$(call triochild,$(2)).varchildexon.vcf.gz : $(1).$(call triochild,$(2)).varchild.vcf.gz
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterso.jar -A SO:0001791|\
	${GZIP} --best > $$@ && \
	test $$$${PIPESTATUS[1]} -eq 0

#Keep variants called for child only and different from the reference (enlève ./. et 0/0)
$(1).$(call triochild,$(2)).varchild.vcf.gz : $(1).$(call triochild,$(2)).trio.vcf.gz
	${GUNZIP} -c $$^ |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() && variant.getGenotype("$(call triochild,$(2))").isHomRef()==false' |\
	${GZIP} --best > $(addsuffix .tmp.gz,$$@) && \
	test $$$${PIPESTATUS[1]} -eq 0 && \
	mv $(addsuffix .tmp.gz,$$@) $$@

#Keep variants called for child, mother or father.
$(1).$(call triochild,$(2)).vartrio.vcf.gz : $(1).$(call triochild,$(2)).trio.vcf.gz
	${GUNZIP} -c $$^ |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() || variant.getGenotype("$(call triomother,$(2))").isCalled() || variant.getGenotype("$(call triofather,$(2))").isCalled()' |\
	${GZIP} --best > $(addsuffix .tmp.gz,$$@) && \
	test $$$${PIPESTATUS[1]} -eq 0 && \
	mv $(addsuffix .tmp.gz,$$@) $$@

#Extrait un vcf pour chaque trio et pour chaque méthode (samtools et gatk unified genotyper)
# $(1) : arg 1:  method
# $(2) : arg 2 : structure trio
#-S : argument pour indiquer les trios à garder dans le vcf
$(1).$(call triochild,$(2)).trio.vcf.gz : ${SAMPLEDIR}/$(1)_all.annot_vqsr.vcf.gz
	${GUNZIP} -c $$< |\
	${JAVA} -jar /commun/data/packages/jvarkit-git/vcfcutsamples.jar \
		$$(foreach I, $(call triofather,$(2))  $(call triomother,$(2))  $(call triochild,$(2)), -S $$I) |\
		${SED} 's/\bANN=/EFF=/g' |\
		${SED} 's/\bID=ANN,/ID=EFF,/g' |\
	${GZIP} --best > $$@ && \
	test $$$${PIPESTATUS[1]} -eq 0

endef

#Cible
all: 	\
	pipecount.log \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},${M}.$(call triochild,$T).xlinked.vcf.gz)) \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},${M}.$(call triochild,$T).heterozygous_rec.genesdi.vcf.gz)) \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},${M}.$(call triochild,$T).homozygous_rec.genesdi.vcf.gz)) \
	$(foreach M,${METHODS},$(foreach A,${ANNOTATE},$(foreach T,${TRIOS}, ${M}.$(call triochild,${T}).${A}.annot.rvis.vcf.gz))) \
	$(foreach M,${METHODS},$(foreach A,${ANNOTATE},$(foreach T,${TRIOS}, ${M}.$(call triochild,${T}).${A}.annot.cadd.vcf.gz))) \
	$(foreach T,${TRIOS}, hapcal.$(call triochild,$T).parents_genotype.vcf.gz) \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},${M}.$(call triochild,$T).parents_nogenotype.vcf.gz)) \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},${M}.$(call triochild,$T).gonl_nogenotype.vcf.gz)) \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},$(foreach F, ${FREQUENCIES}, ${M}.$(call triochild,$T).evs_nogenotype_${F}.vcf.gz)))
	echo "AYE J'AI FINI"

pipecount.log: $(foreach M,${METHODS},$(foreach T,${TRIOS},pipecount.$(M).$(call triochild,$(T)).log))
	echo Step $^ | sed 's/ /\t/g ; s/pipecount\.//g ; s/\.log//g' > $@
	paste $^ | awk '{ for (col = 3; col <= NF;col += 2) $$col = "" } 1'| sed 's/  /\t/g' >> $@


define resources_with_frequency

evs.20150206_$(1).vcf.gz: /commun/data/pubdb/evs.gs.washington.edu/tabix/evs.20150206.vcf.gz
	$${GUNZIP} -c $$^ |\
	$${JAVA} -jar $${JVARKIT}/vcffilterjs.jar -e '!((variant.getAttribute("uaMAF")<=$(1)) || (variant.getAttribute("aaMAF")<=$(1)) || (variant.getAttribute("totalMAF")<=$(1)))' |\
	$${TABIX}/bgzip > $$@
	$${TABIX}/tabix -p vcf $$@


release4_noContam_noChildren_with_AN_AC_GTC_stripped_$(1).vcf.gz: $${VCFSCRIPTS}/20150209_GoNLgeno/release4_noContam_noChildren_with_AN_AC_GTC_stripped.tar.gz
	$${TAR} tfz $$^ |\
	$${GREP} -v tbi |\
	while read V; do $${TAR} xfzO $$^ $$$$V | $${GUNZIP} -c ; done |\
	$${GREP} '^##' > $$(addsuffix _gonl.vcf.tmp,$$@)
	head -n 1 $$(addsuffix _gonl.vcf.tmp,$$@) > $$(addsuffix _gonl.vcf.tmp2,$$@)
	head -n -1 $$(addsuffix _gonl.vcf.tmp,$$@) | sort -T /commun/data/users/asdp/Hugodims/tmp -u >> $$(addsuffix _gonl.vcf.tmp2,$$@)
	$${ECHO} "#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO" >> $$(addsuffix _gonl.vcf.tmp2,$$@)
	$${TAR} tfz $$^ |\
	$${GREP} -v tbi |\
	while read V; do $${TAR} xfzO $$^ $$$$V | $${GUNZIP} -c ; done |\
	$${GREP} -v '^#' >> $$(addsuffix _gonl.vcf.tmp2,$$@)
	$${JAVA} -jar $${JVARKIT}/vcffilterjs.jar -e '(variant.getAttribute("AC")/variant.getAttribute("AN")>=$(1))' $$(addsuffix _gonl.vcf.tmp2,$$@) > $$(addsuffix _gonl.vcf.tmp3,$$@)
	$${TABIX}/bgzip $$(addsuffix _gonl.vcf.tmp3,$$@)
	mv $$(addsuffix _gonl.vcf.tmp3.gz,$$@) $$@
	$${TABIX}/tabix -p vcf $$@
	$${RM} $$(addsuffix _gonl.vcf.tmp,$$@) $$(addsuffix _gonl.vcf.tmp2,$$@)

exacfilter$(1).js: $${VCFSCRIPTS}/20150416_exac/exacfileteraf.js
	$${SED} 's/__frequency__/$(1)/g' $$^ > $$@

ExAC.r0.3.sites.vep_$(1).vcf.gz: /commun/data/pubdb/broadinstitute.org/exac/0.3/ExAC.r0.3.sites.vep.vcf.gz exacfilter$(1).js
	$${GUNZIP} -c $$< |\
	$${JAVA} -jar $${JVARKIT}/vcffilterjs.jar -f exacfilter$(1).js |\
	$${TABIX}/bgzip > $$(addsuffix .tmp.gz,$$@) && \
	$${TABIX}/tabix -p vcf -f $$(addsuffix .tmp.gz,$$@) && \
	mv $$(addsuffix .tmp.gz,$$@) $$@ && \
	mv $$(addsuffix .tmp.gz.tbi,$$@) $$(addsuffix .tbi,$$@)

endef

pedigree.txt: 
	$(foreach I,${TRIOS}, echo "$(call trioid,$I)	$(call triochild,$I)	$(call triofather,$I)	$(call triomother,$I)	0	0" >> $@; )
	$(foreach I,${TRIOS}, echo "$(call trioid,$I)	$(call triofather,$I)	0	0	0	0" >> $@; )
	$(foreach I,${TRIOS}, echo "$(call trioid,$I)	$(call triomother,$I)	0	0	0	0" >> $@; )

$(eval $(foreach M,${METHODS},$(foreach A,${ANNOTATE},$(foreach T,${TRIOS},$(call annotate_trio,${M},${T},${A})))))
$(eval $(foreach M,${METHODS},$(foreach T,${TRIOS},$(call analyse_trio,${M},${T}))))
$(eval $(foreach M,${METHODS},$(foreach T,${TRIOS},$(foreach F,${FREQUENCIES},$(call analyse_trio_with_frequency,${M},${T},${F})))))
$(eval $(foreach M,${METHODS},$(foreach T,${TRIOS},$(call parentsdb2,${M},${T}))))
$(eval $(foreach M,${METHODS},$(call parentsdb1,${M})))
$(eval $(foreach M,${METHODS},$(foreach T,${TRIOS},$(call pipecount,${M},${T}))))
$(eval $(foreach F,${FREQUENCIES},$(call resources_with_frequency,${F})))

parents.list:
	find -L /commun/data/projects/plateforme/NTS-015_ENS_Bezieau_HUGODIMS/ -name '*_final.bam' | ${AWK} -F/ '{print $$NF;}' | cut -d '_' -f2 | ${GREP} -v -E 'E$$' | ${SORT} -T /commun/data/users/asdp/Hugodims/tmp > $@

%.genesdi.vcf.gz : %.vcf.gz ${GENESDILST}
	zgrep '^#' $< > $(addsuffix .tmp,$@) && \
	zgrep -w -F -f ${GENESDILST} $< >> $(addsuffix .tmp,$@) || \
        true
	${TABIX}/bgzip $(addsuffix .tmp,$@)
	mv $(addsuffix .tmp.gz,$@) $@
	${TABIX}/tabix -p vcf $@

clean :
	${RM} -f *.vcf.gz
	${RM} -f *.log
	${RM} -f parentsdb_*
	${RM} -f pedigree.txt
	${RM} -f *.tbi
	${RM} -f *.tmp
	${RM} -f *.tmp.gz
	${RM} -f *.list
	${RM} -f *.tmp.js
