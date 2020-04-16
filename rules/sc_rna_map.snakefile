

STAR_VERSION = subprocess.check_output("STAR --version", shell=True)

rule STARsolo:
	"""
	STARsolo to align single cell or single nuceli data
	specify --soloFeatures Gene for single-cell  data
	specify --soloFeatures GeneFull for single-nuclei data
	specify --soloFeatures Gene GeneFull for getting both counts in exons level and exon + intron level (velocity)
	"""
	input: 
		mapindex = config["genome"]["mapindex"],
		whitelist = config["barcode"]["whitelist"]
	output: 
		bam = "Result/STAR/{sample}Aligned.sortedByCoord.out.bam",
		bai = "Result/STAR/{sample}Aligned.sortedByCoord.out.bam.bai",
		rawmtx = "Result/STAR/{sample}Solo.out/Gene/raw/matrix.mtx",
		feature = "Result/STAR/{sample}Solo.out/Gene/raw/features.tsv",
		barcode = "Result/STAR/{sample}Solo.out/Gene/raw/barcodes.tsv"
	params:
		star_custom = config.get("STARsolo_custom", ""),
		outdir = "Result/STAR/" + "{sample}",
		transcript = lambda wildcards: ','.join(FILES[wildcards.sample]["R2"]),
		barcode = lambda wildcards: ','.join(FILES[wildcards.sample]["R1"]),
		barcodestart = config["barcode"]["barcodestart"],
		barcodelength = config["barcode"]["barcodelength"],
		umistart = config["barcode"]["umistart"],
		umilength = config["barcode"]["umilength"]
	version: STAR_VERSION        
	log:
		"Result/Log/{sample}_STAR.log" 
	benchmark:
		"Result/Benchmark/{sample}_STAR.benchmark"
	threads:
		config.get("STARsolo_threads", "")

	shell:
		"""
		STAR \
			--runMode alignReads \
			--genomeDir {input.mapindex} \
			--runThreadN {threads} \
			--outFileNamePrefix {params.outdir} \
			--outSAMtype BAM SortedByCoordinate \
			--outSAMattributes NH HI nM AS CR UR CB UB GX GN sS sQ sM \
			--soloType CB_UMI_Simple \
			{params.star_custom} \
			--soloCBwhitelist {input.whitelist} \
			--soloCBstart {params.barcodestart} \
			--soloCBlen {params.barcodelength} \
			--soloUMIstart {params.umistart} \
			--soloUMIlen {params.umilength} \
			--soloCBmatchWLtype 1MM_multi_pseudocounts \
			--soloUMIfiltering MultiGeneUMI \
			--readFilesIn {params.transcript} {params.barcode} --readFilesCommand zcat \
			> {log} 2>&1
		samtools index -b -@ {threads} {output.bam}
				
		"""







