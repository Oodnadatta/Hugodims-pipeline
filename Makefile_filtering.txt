.PHONY : all clean
#Variables
SHELL=/bin/bash
SAMPLEDIR=/commun/data/users/asdp/align20150211/call20150425/VCF
JVARKIT=/commun/data/packages/jvarkit-git
GUNZIP=/bin/gunzip
JAVA=/usr/bin/java
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

PIPE= trio vartrio varchild varchildexon incompats genotype predict 1000G gonl_nogenotype gonl_genotype evs_nogenotype evs_genotype parents_nogenotype parents_genotype

TRIOS= trio01|01-01-RH-E|01-01-RH-M|01-01-RH-P \
	trio02|01-03-ML-E|01-03-ML-M|01-03-ML-P \
	trio03|01-06-SC-E|01-06-SC-M|01-06-SC-P \
	trio04|02-01-FI-E|02-01-FI-M|02-01-FI-P \
	trio05|02-06-GP-E|02-06-GP-M|02-06-GP-P \
	trio06|03-05-SA-E|03-05-SA-M|03-05-SA-P \
	trio07|03-06-BM-E|03-06-BM-M|03-06-BM-P \
	trio08|04-01-FL-E|04-01-FL-M|04-01-FL-P \
	trio09|05-01-DR-E|05-01-DR-M|05-01-DR-P \
	trio10|05-05-BA-E|05-05-BA-M|05-05-BA-P \
	trio11|06-01-GA-E|06-01-GA-M|06-01-GA-P \
	trio12|06-05-CA-E|06-05-CA-M|06-05-CA-P \
	trio13|07-01-HN-E|07-01-HN-M|07-01-HN-P

METHODS= unifiedgenotyper samtools hapcal

MERGED=  gatk merge

#Variants dont la fréquence est strictement supérieure à FREQUENCY
FREQUENCY= 0.001

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

define pipecountmerge

pipecount.$(1).$(call triochild,$(2)).log : $(1).$(call triochild,$(2)).vcf.gz
	for f in $(PIPE); \
	do \
		${ECHO} "$$$$f.vcf.gz	." >> $$@; \
	done
	${ECHO}	"$(1)	`${GUNZIP} -c $(1).$(call triochild,$(2)).vcf.gz | ${GREP} -v '^#' | wc -l`" >> $$@


endef

#Compte le nombre de variants obtenus à chaque étape (tableau : étape	nombre)
define pipecount

pipecount.$(1).$(call triochild,$(2)).log : $(foreach F, ${PIPE}, $(1).$(call triochild,$(2)).${F}.vcf.gz)
	for f in ${PIPE}; \
	do \
		${ECHO} "$$$$f.vcf.gz	`${GUNZIP} -c $(1).$(call triochild,$(2)).$$$$f.vcf.gz |\
		${GREP} -v '^#' |\
		wc -l`" >> $$@; \
	done

endef

define merge
gatk.$(call triochild,$(1)).vcf.gz : unifiedgenotyper.$(call triochild,$(1)).parents_genotype.vcf.gz hapcal.$(call triochild,$(1)).parents_genotype.vcf.gz
	perl -I /commun/data/packages/vcftools/vcftools_0.1.12b/perl/ /commun/data/packages/vcftools/vcftools_0.1.12b/bin/vcf-isec -n +1 -w 20 $$^ | \
	${TABIX}/bgzip -c > $$@ && \
	${TABIX}/tabix -p vcf $$@

merge.$(call triochild,$(1)).vcf.gz : samtools.$(call triochild,$(1)).parents_genotype.vcf.gz gatk.$(call triochild,$(1)).vcf.gz
	 perl -I /commun/data/packages/vcftools/vcftools_0.1.12b/perl/ /commun/data/packages/vcftools/vcftools_0.1.12b/bin/vcf-isec -n +2 -w 20 $$^ | \
	${TABIX}/bgzip -c > $$@

endef

#Retirer les variants des parents de la parentsdb, puis Tabix sur la parentsdb_trio avec création de l'index
define parentsdb1

$(1).parentsdb.vcf.gz : ${SAMPLEDIR}/$(1).annot.vcf.gz
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcfcutsamples.jar -r -f ${VCFSCRIPTS}/20150211_parentsdb/parents.list |\
	${GZIP} --best > $$@

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


define analyse_trio

#Compte le nombre d'occurences pour chaque type de variant
#echo -n do not output the trailing newline
#grep -F Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
#à partir de variant_type.list, pour chaque type de variant (f), écrit "f\t" et écrit le nombre d'occurence de f
vartype_fin.$(1).$(call triochild,$(2)).log : $(1).$(call triochild,$(2)).gonl_genotype.vcf.gz ${VCFSCRIPTS}/20150123_vartype/variant_types.list
	${CAT} $$(filter %.list,$$^) | while read f; do ${ECHO} -n "$$$$f       " && ${GUNZIP} -c $$< | ${GREP} -v '^#' | ${GREP} -F "$$$$f" | wc -l ; done > $$@

#Filtrer les vcf avec parentsdb_trio (AVEC genotype)
$(1).$(call triochild,$(2)).parents_genotype.vcf.gz : $(1).$(call triochild,$(2)).evs_genotype.vcf.gz $(1).parentsdb_$(call triochild,$(2)).vcf.gz $(1).parentsdb_$(call triochild,$(2)).vcf.gz.tbi
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcfresetvcf.jar -r -x $(1).parentsdb_$(call triochild,$(2)).vcf.gz |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() ' |\
	${TABIX}/bgzip > $$@ && \
	${TABIX}/tabix -p vcf $$@

#filtrer les vcf avec parentsdb_trio (SANS génotype)
$(1).$(call triochild,$(2)).parents_nogenotype.vcf.gz : $(1).$(call triochild,$(2)).evs_genotype.vcf.gz
	/commun/data/packages/bedtools/bedtools2-2.20.1/bin/bedtools intersect -header -wa -v -a $$^ -b $(1).parentsdb_$(call triochild,$(2)).vcf.gz |\
	${GZIP} --best > $$@

#filtrer sur evs (>= FREQUENCY, pas de prise en compte du génotype)
$(1).$(call triochild,$(2)).evs_nogenotype.vcf.gz : $(1).$(call triochild,$(2)).gonl_genotype.vcf.gz
	/commun/data/packages/bedtools/bedtools2-2.20.1/bin/bedtools intersect -header -wa -v -a $$^ -b <(${TAR} Oxfz ${VCFSCRIPTS}/20150126_evs/vcftools/ESP6500SI-V2.GRCh38-liftover.coverage.all_sites.txt.tar.gz  |\
	${AWK} -F ' ' '(NF>=9 && int($$$$3)>=650)' | cut -d ' ' -f1,2 |\
	${AWK} -F ' ' '{printf("%s\t%d\t%d\n",$$$$1,int($$$$2),int($$$$2)+1);}' |\
	LC_ALL=C ${SORT} -t '	' -k1,1 -k2,2n) |\
	${GZIP} --best > $$@

#filter sur evs (>= FREQUENCY, AVEC génotype)
#-r remove whole variant if there is no called genotype
$(1).$(call triochild,$(2)).evs_genotype.vcf.gz : $(1).$(call triochild,$(2)).gonl_genotype.vcf.gz evs.20150206_${FREQUENCY}.vcf.gz
	${JAVA} -jar ${JVARKIT}/vcfresetvcf.jar -r -x evs.20150206_${FREQUENCY}.vcf.gz $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() ' |\
	${GZIP} --best > $$@

#filtrer sur GoNL (>= FREQUENCY, AVEC génotype)
#-r remove whole variant if there is no called genotype
$(1).$(call triochild,$(2)).gonl_genotype.vcf.gz : $(1).$(call triochild,$(2)).1000G.vcf.gz release4_noContam_noChildren_with_AN_AC_GTC_stripped_${FREQUENCY}.vcf.gz
	${JAVA} -jar ${JVARKIT}/vcfresetvcf.jar -r -x release4_noContam_noChildren_with_AN_AC_GTC_stripped_${FREQUENCY}.vcf.gz $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() ' |\
	${GZIP} --best > $(addsuffix .tmp.gz,$$@) && \
	mv $(addsuffix .tmp.gz,$$@) $$@

#filtrer sur GoNL (>= FREQUENCY, SANS génotype)
$(1).$(call triochild,$(2)).gonl_nogenotype.vcf.gz : $(1).$(call triochild,$(2)).1000G.vcf.gz
	/commun/data/packages/bedtools/bedtools2-2.20.1/bin/bedtools intersect -header -wa -v -a $$^ -b <(gunzip -c ${VCFSCRIPTS}/20150209_GoNLgeno/release4_noContam_noChildren_with_AN_AC_GTC_stripped_0.01.gz |\
	cut -d '	' -f1,2 |\
	${AWK} -F '	' '{printf("%s\t%d\t%d\n",$$$$1,int($$$$2),int($$$$2)+1);}' |\
	LC_ALL=C ${SORT} -t '	' -k1,1 -k2,2n) |\
	${GZIP} --best > $$@

#filtrer sur 1000G (>= FREQUENCY pour chaque population AFR_AF, AMR_AF, ASN_AF ou EUR_AF >= 0.01, SANS génotype)
$(1).$(call triochild,$(2)).1000G.vcf.gz : $(1).$(call triochild,$(2)).predict.vcf.gz
	${GUNZIP} -c $$< | ${SED} -e 's/AF/originalAF/g' > $(addsuffix _AF.tmp,$$@)
	${JAVA} -jar /commun/data/packages/jvarkit-git/vcfvcf.jar ACF=CONFLICTALT1KG $(foreach FLAG,AMR_AF ASN_AF AFR_AF EUR_AF SNPSOURCE SVTYPE SVLEN, INFO=${FLAG}) TABIX=/commun/data/pubdb/ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20110521/ALL.wgs.phase1_release_v3.20101123.snps_indels_sv.sites.vcf.gz  IN=$(addsuffix _AF.tmp,$$@) > $(addsuffix .tmp,$$@)
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e '!((variant.getAttribute("AF")>=0.01) || (variant.getAttribute("AFR_AF")>=0.01) || (variant.getAttribute("AMR_AF")>=0.01) || (variant.getAttribute("ASN_AF")>=0.01) || (variant.getAttribute("EUR_AF")>=0.01))' $(addsuffix .tmp,$$@)|\
	${GZIP} --best > $$@

#Filter a VCF file annotated with SNPEff or VEP with term exon_variant (from Sequence-Ontology)
$(1).$(call triochild,$(2)).predict.vcf.gz : $(1).$(call triochild,$(2)).genotype.vcf.gz
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterso.jar -A SO:0001818 -A SO:0001590 -A SO:0001572 -A SO:0001629 -A SO:0001569 -A SO:0001630 |\
	${GZIP} --best > $$@

#Excludes all sites ./. (E+P), 0/0 (E), hz (E), 0/parent (E)
$(1).$(call triochild,$(2)).genotype.vcf.gz : $(1).$(call triochild,$(2)).incompats.vcf.gz ${VCFSCRIPTS}/20150121_denovo/jvarkit/filtertrio.js
	${SED} -e 's/__CHILD__/$(call triochild,$(2))/g' -e 's/__FATHER__/$(call triofather,$(2))/g' -e 's/__MOTHER__/$(call triomother,$(2))/g' $$(filter %.js,$$^) > $$(addsuffix .tmp.js,$$@) && \
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -f $$(addsuffix .tmp.js,$$@) |\
	${GZIP} --best > $$@ && \
	${RM} -f $(addsuffix .tmp.js,$$@)

#Excludes all sites without the incompatibilities flag (MENDEL)
$(1).$(call triochild,$(2)).incompats.vcf.gz : $(1).$(call triochild,$(2)).trio.vcf.gz pedigree.txt
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcftrio.jar -p $$(filter %.txt,$$^) |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.hasAttribute("MENDEL")' |\
	${GZIP} --best > $$@

#Compte le nombre d'occurences pour chaque type de variant
#echo -n do not output the trailing newline
#grep -F Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
#à partir de variant_type.list, pour chaque type de variant (f), écrit "f\t" et écrit le nombre d'occurence de f
vartype_ini.$(1).$(call triochild,$(2)).log : $(1).$(call triochild,$(2)).trio.vcf.gz ${VCFSCRIPTS}/20150123_vartype/variant_types.list
	${CAT} $$(filter %.list,$$^) | while read f; do ${ECHO} -n "$$$$f	" && ${GUNZIP} -c $$< | ${GREP} -v '^#' | ${GREP} -F "$$$$f" | wc -l ; done > $$@


#Filter a VCF file annotated with SNPEff or VEP with term exon_variant (from Sequence-Ontology)
$(1).$(call triochild,$(2)).varchildexon.vcf.gz : $(1).$(call triochild,$(2)).varchild.vcf.gz
	${GUNZIP} -c $$< |\
	${JAVA} -jar ${JVARKIT}/vcffilterso.jar -A SO:0001791|\
	${GZIP} --best > $$@

#Keep variants called for child only
$(1).$(call triochild,$(2)).varchild.vcf.gz : $(1).$(call triochild,$(2)).trio.vcf.gz
	${GUNZIP} -c $$^ |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() && variant.getGenotype("$(call triochild,$(2))").isHomRef()==false' |\
	${GZIP} --best > $(addsuffix .tmp.gz,$$@) && \
	mv $(addsuffix .tmp.gz,$$@) $$@

#Keep variants called for child, mother or father.
$(1).$(call triochild,$(2)).vartrio.vcf.gz : $(1).$(call triochild,$(2)).trio.vcf.gz
	${GUNZIP} -c $$^ |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e 'variant.getGenotype("$(call triochild,$(2))").isCalled() || variant.getGenotype("$(call triomother,$(2))").isCalled() || variant.getGenotype("$(call triofather,$(2))").isCalled()' |\
	${GZIP} --best > $(addsuffix .tmp.gz,$$@) && \
	mv $(addsuffix .tmp.gz,$$@) $$@


#Extrait un vcf pour chaque trio et pour chaque méthode (samtools et gatk unified genotyper)
# $(1) : arg 1:  method
# $(2) : arg 2 : structure trio
#-S : argument pour indiquer les trios à garder dans le vcf
$(1).$(call triochild,$(2)).trio.vcf.gz : ${SAMPLEDIR}/$(1).annot.vcf.gz
	${GUNZIP} -c $$< |\
	${JAVA} -jar /commun/data/packages/jvarkit-git/vcfcutsamples.jar \
		$$(foreach I, $(call triofather,$(2))  $(call triomother,$(2))  $(call triochild,$(2)), -S $$I) |\
	${GZIP} --best > $$@

endef

#Cible
all: 	\
	pipecount.log \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},vartype_fin.${M}.$(call triochild,$T).log)) \
	$(foreach T,${TRIOS},merge.$(call triochild,$T).vcf.gz) \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},${M}.$(call triochild,$T).parents_nogenotype.vcf.gz)) \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},${M}.$(call triochild,$T).gonl_nogenotype.vcf.gz)) \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},${M}.$(call triochild,$T).evs_nogenotype.vcf.gz)) \
	$(foreach M,${METHODS},$(foreach T,${TRIOS},vartype_ini.${M}.$(call triochild,$T).log)) \
	pedigree.txt
	echo "AYE J'AI FINI"

pipecount.log: $(foreach M,${METHODS}, $(foreach T,${TRIOS},pipecount.$(M).$(call triochild,$(T)).log)) $(foreach M,${MERGED}, $(foreach T,${TRIOS},pipecount.$(M).$(call triochild,$(T)).log))
	echo Step $^ | sed 's/ /\t/g ; s/pipecount\.//g ; s/\.log//g' > $@
	paste $^ | awk '{ for (col = 3; col <= NF;col += 2) $$col = "" } 1'| sed 's/  /\t/g' >> $@


evs.20150206_${FREQUENCY}.vcf.gz: /commun/data/pubdb/evs.gs.washington.edu/tabix/evs.20150206.vcf.gz
	${GUNZIP} -c $^ |\
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e '!((variant.getAttribute("uaMAF")<=${FREQUENCY}) || (variant.getAttribute("aaMAF")<=${FREQUENCY}) || (variant.getAttribute("totalMAF")<=${FREQUENCY}))' |\
	${TABIX}/bgzip > $@
	${TABIX}/tabix -p vcf $@


release4_noContam_noChildren_with_AN_AC_GTC_stripped_${FREQUENCY}.vcf.gz: ${VCFSCRIPTS}/20150209_GoNLgeno/release4_noContam_noChildren_with_AN_AC_GTC_stripped.tar.gz
	${TAR} tfz $^ |\
	${GREP} -v tbi |\
	while read V; do ${TAR} xfzO $^ $$V | ${GUNZIP} -c ; done |\
	${GREP} '^##' > $(addsuffix _gonl.vcf.tmp,$@)
	head -n 1 $(addsuffix _gonl.vcf.tmp,$@) > $(addsuffix _gonl.vcf.tmp2,$@)
	head -n -1 $(addsuffix _gonl.vcf.tmp,$@) | sort -u >> $(addsuffix _gonl.vcf.tmp2,$@)
	${ECHO} "#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO" >> $(addsuffix _gonl.vcf.tmp2,$@)
	${TAR} tfz $^ |\
	${GREP} -v tbi |\
	while read V; do ${TAR} xfzO $^ $$V | ${GUNZIP} -c ; done |\
	${GREP} -v '^#' >> $(addsuffix _gonl.vcf.tmp2,$@)
	${JAVA} -jar ${JVARKIT}/vcffilterjs.jar -e '(variant.getAttribute("AC")/variant.getAttribute("AN")>=${FREQUENCY})' $(addsuffix _gonl.vcf.tmp2,$@) > $(addsuffix _gonl.vcf.tmp3,$@)
	${TABIX}/bgzip $(addsuffix _gonl.vcf.tmp3,$@)
	mv $(addsuffix _gonl.vcf.tmp3.gz,$@) $@
	${TABIX}/tabix -p vcf $@
	${RM} $(addsuffix _gonl.vcf.tmp,$@) $(addsuffix _gonl.vcf.tmp2,$@)

exacfilter${FREQUENCY}.js: ${VCFSCRIPTS}/20150416_exac/exacfileteraf.js
	${SED} 's/__frequency__/${FREQUENCY}/g' $^ > $@

pedigree.txt: 
	$(foreach I,${TRIOS}, echo "$(call trioid,$I)	$(call triochild,$I)	$(call triofather,$I)	$(call triomother,$I)	0	0" >> $@; )
	$(foreach I,${TRIOS}, echo "$(call trioid,$I)	$(call triofather,$I)	0	0	0	0" >> $@; )
	$(foreach I,${TRIOS}, echo "$(call trioid,$I)	$(call triomother,$I)	0	0	0	0" >> $@; )

$(eval $(foreach M,${METHODS},$(foreach T,${TRIOS},$(call analyse_trio,${M},${T}))))
$(eval $(foreach M,${METHODS},$(foreach T,${TRIOS},$(call parentsdb2,${M},${T}))))
$(eval $(foreach M,${METHODS},$(call parentsdb1,${M})))
$(eval $(foreach M,${METHODS},$(foreach T,${TRIOS},$(call pipecount,${M},${T}))))
$(eval $(foreach M,${MERGED},$(foreach T,$(TRIOS),$(call pipecountmerge,${M},${T}))))
$(eval $(foreach T,${TRIOS},$(call merge,${T})))

clean :
	${RM} -f *.vcf.gz
	${RM} -f *.log
	${RM} -f parentsdb_*
	${RM} -f pedigree.txt
	${RM} -f *.tbi
	${RM} -f *tmp
	${RM} -f *tmp.gz

