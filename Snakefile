"""
A single cell RNA-seq analysis pipeline.
Author: Ming (Tommy) Tang  04/16/2020
"""

configfile: "config.yaml"

include: "rules/common.snakefile"
# load the samples.json file
FILES = json.load(open(config['SAMPLES_JSON']))
ALL_SAMPLES = sorted(FILES.keys())


STAR_BAM = expand("Result/STAR/{sample}/{sample}Aligned.sortedByCoord.out.bam", sample = ALL_SAMPLES)
STAR_BAI = expand("Result/STAR/{sample}/{sample}Aligned.sortedByCoord.out.bam.bai", sample = ALL_SAMPLES)
STAR_MAT = expand("Result/STAR/{sample}/{sample}Solo.out/Gene/raw/matrix.mtx", sample= ALL_SAMPLES)

TARGETS = STAR_BAM + STAR_MAT + STAR_BAI

rule all:
	input: TARGETS

if config["platform"] == "10x-genomics":
	include: "rules/sc_rna_map.snakefile"