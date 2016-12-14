#! /usr/bin/env python2.7
# -*- coding: utf-8 -*-

# coded by Anne-Sophie Denommé-Pichon
# 2015-08-22

import sys

child = None
mother = None
father = None

def find_genotype(variant, column):
	"Récupère le génotype dans le vcf (1/1 par exemple)"
	return variant.split('\t')[column].split(':')[0].split('/')

if __name__ == '__main__':
	# Cela permet de ne pas exécuter le code de le_nom_du_fichier.py dans un autre fichier.py s'il est importé.
	# Il ne conservera que les fonctions, les classes...

	homozygous = '-homozygous' in sys.argv
	if homozygous:
		sys.argv.remove('-homozygous')
	heterozygous = '-heterozygous' in sys.argv
	if heterozygous:
		sys.argv.remove('-heterozygous')
	xlinked_male = '-xlinked-male' in sys.argv
	if xlinked_male:
		sys.argv.remove('-xlinked-male')
	xlinked_female = '-xlinked-female' in sys.argv
	if xlinked_female:
		sys.argv.remove('-xlinked-female')

	dico = {}

	for line in sys.stdin:
		line = line.rstrip()
		if line.startswith('#'):
			print line # write the header
			if len(line) > 1 and line[1] != '#':
				for columnId, column in enumerate(line.split('\t')):
					if column.endswith('-E'):
						child = columnId
					elif column.endswith('-M'):
						mother = columnId
					elif column.endswith('-P'):
						father = columnId
				if not (child and mother and father):
					print >> sys.stderr, 'Missing column for one of the trio members in header "{}"'.format(line)
					sys.exit(1)
		else:
			if not (child and mother and father):
				print >> sys.stderr, 'Missing header?'
				sys.exit(1)
                        mother_genotype = find_genotype(line, mother)
                        father_genotype = find_genotype(line, father)
                        if (mother_genotype[0] not in ['0'] and mother_genotype[1] not in ['0']) or \
			   (father_genotype[0] not in ['0'] and father_genotype[1] not in ['0']):
                        # if (mother_genotype[0] not in ['0', '.'] and mother_genotype[1] not in ['0', '.']) or \
			#    (father_genotype[0] not in ['0', '.'] and father_genotype[1] not in ['0', '.']):
                                continue
                        else:
                                child_genotype = find_genotype(line, child)
                                if child_genotype[0] != '0': # pour homozygotes
                                        if homozygous:
						if (child_genotype[0] in mother_genotype and child_genotype[1] in father_genotype) or \
						   (child_genotype[0] in father_genotype and child_genotype[1] in mother_genotype):
							print line
					if 'X' in line.split('\t', 1)[0]:
						if child_genotype[0] not in father_genotype and child_genotype[1] not in father_genotype: # De novo
							if xlinked_female:
								print line
						if xlinked_male and (\
						   (child_genotype[0] in mother_genotype and child_genotype[0] not in father_genotype) or \
						   (child_genotype[1] in mother_genotype and child_genotype[1] not in father_genotype)):
							print line
                                else: # pour les hétérozygotes composites
                                        #débug			print "un truc rigolo, j'ai dit un truc rigolo"
					split_string = 'EFF=' in line and 'EFF=' or 'ANN='
         				annotation = line.split('\t')[7].split(split_string)[1].split(';')[0]
         				for effect in annotation.split(','):
         					gene_name = effect.split('|')[3]
						if gene_name:
							if gene_name not in dico:
								dico[gene_name] = set()
							dico[gene_name].add(line)

	# annotation = ensemble des annotation des snpEFF uniquement
	#	exemple :
	#	frameshift_variant(HIGH||ccc/cTcc|p.Pro54_Pro55fs/c.161_162insT|540|SAMD11|protein_coding|CODING|ENST00000455979|1|1|WARNING_TRANSCRIPT_NO_START_CODON),frameshift_variant(HIGH||ccc/cTcc|p.Pro228_Pro229fs/c.683_684insT|681|SAMD11|protein_coding|CODING|ENST00000342066|7|1),upstream_gene_variant(MODIFIER||909|||SAMD11|processed_transcript|CODING|ENST00000478729||1),upstream_gene_variant(MODIFIER||1639|||SAMD11|retained_intron|CODING|ENST00000474461||1),upstream_gene_variant(MODIFIER||2666|||SAMD11|retained_intron|CODING|ENST00000466827||1),upstream_gene_variant(MODIFIER||2729|||SAMD11|retained_intron|CODING|ENST00000464948||1),downstream_gene_variant(MODIFIER||3644||108|SAMD11|protein_coding|CODING|ENST00000437963||1),downstream_gene_variant(MODIFIER||4767||749|NOC2L|protein_coding|CODING|ENST00000327044||1),downstream_gene_variant(MODIFIER||4767|||NOC2L|retained_intron|CODING|ENST00000483767||1),downstream_gene_variant(MODIFIER||4768|||NOC2L|retained_intron|CODING|ENST00000477976||1),downstream_gene_variant(MODIFIER||146||178|SAMD11|protein_coding|CODING|ENST00000420190||1),intron_variant(MODIFIER|||c.427+25_427+26insT|588|SAMD11|protein_coding|CODING|ENST00000341065|5|1|WARNING_TRANSCRIPT_NO_START_CODON)


	# dico = dico
	# gene_name = clé
	# dico[gene_name] = valeur associée à gene_name = un set

	dedoublon = set() #dedoublon : les variants que l'on va garder
	for gene_name in dico:
		variants = set()
                found_variant_from_mother = False
                found_variant_from_father = False
                for variant in dico[gene_name]:
                        child_genotype = find_genotype(variant, child)
                        mother_genotype = find_genotype(variant, mother)
                        father_genotype = find_genotype(variant, father)
                        found_variant_from_mother = found_variant_from_mother or \
                                                    child_genotype[1] == mother_genotype[1] or \
                                                    mother_genotype[1] == '.'
                        found_variant_from_father = found_variant_from_father or \
                                                    child_genotype[1] == father_genotype[1] or \
                                                    father_genotype[1] == '.'
                        if found_variant_from_mother:
				if found_variant_from_father:
                                        for variant in dico[gene_name]:
                                                # Vérification de la ségrégation : si le variant provient bien d'un parent (ie. pas une erreur de séquençage)
						child_genotype = find_genotype(variant, child)
						mother_genotype = find_genotype(variant, mother)
						father_genotype = find_genotype(variant, father)
                                                if (child_genotype[1] == mother_genotype[1] and child_genotype[1] != father_genotype[1]) or \
                                                   (child_genotype[1] == father_genotype[1] and child_genotype[1] != mother_genotype[1]):
        						if heterozygous:
        							variants.add(variant)
					if heterozygous:
						break
				else:
					if child_genotype[1] != mother_genotype[1]: # De novo
	                			if 'X' in line.split('\t', 1)[0]:
							for variant in dico[gene_name]:
								child_genotype = find_genotype(variant, child)
								father_genotype = find_genotype(variant, father)
								if child_genotype[1] != father_genotype[1]:
									if xlinked_female:
										variants.add(variant)
							if xlinked_female:
								break
		if len(variants) > 1:
			dedoublon.update(variants)

	for variant in dedoublon:
		print variant

	# variant = élément de dico[gene_name], ce dernier est un set. L'élement d'un set (de string) se trouve entre '' quand il est affiché avec print.
