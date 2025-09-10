# Pipeline para la generación de matrices de conteo a partir de datos de RNA-seq
# Este pipeline es una modificación del empleado por TCGA para generar las matrices de conteos de RNA-seq.
# Se debe repetir para cada una de las muestras, y los archivos FASTQ pueden ser descargados directamente del European Nucleotide Archive (ENA).
# Los archivos de referencia (genoma y anotación) están disponibles en ENSEMBL y se pueden descargar desde: https://www.gencodegenes.org/human/release_46.html.

# Paso 1: Descomprimir archivos .gz para obtener el genoma de referencia y la anotación de genes

gunzip GRCh38.primary_assembly.genome.fa.gz
gunzip gencode.v36.basic.annotation.gtf.gz

# Paso 2: Instalar STAR (Spliced Transcripts Alignment to a Reference)
# STAR es una herramienta para alinear lecturas de RNA-seq a un genoma de referencia.
# Se puede descargar STAR desde GitHub: https://github.com/alexdobin/STAR.git
# Alternativamente, descargar el archivo binario precompilado desde el sitio web del autor.

# Paso 3: Generar el índice del genoma utilizando STAR
# Modifica las rutas según la ubicación de tus archivos y directorios.

STAR --runMode genomeGenerate \
     --genomeDir STAR_index \                 # Directorio donde se almacenará el índice del genoma
     --genomeFastaFiles STAR_index/GRCh38.primary_assembly.genome.fa \  # Archivo FASTA del genoma de referencia
     --sjdbOverhang 100 \                     # Extensión de nucleótidos para la base de datos de sitios de unión de splicing (SJ)
     --sjdbGTFfile STAR_index/gencode.v36.basic.annotation.gtf \  # Archivo GTF de anotación de genes
     --runThreadN 16                          # Número de hilos a utilizar

# Paso 4: Primera alineación de lecturas para obtener el archivo SJ.out.tab (sitios de splicing)
# Este paso genera el archivo SJ.out.tab que mejora la precisión en la siguiente alineación.

STAR --genomeDir Analysis/STAR_index \       # Directorio del índice del genoma
     --readFilesIn FASTQ/SRR11124374_1.fastq.gz FASTQ/SRR11124374_2.fastq.gz \  # Archivos FASTQ de las lecturas (rutas modificables)
     --runThreadN 16 \
     --outFilterMultimapScoreRange 1 \
     --outFilterMultimapNmax 20 \
     --outFilterMismatchNmax 10 \
     --alignIntronMax 500000 \
     --alignMatesGapMax 1000000 \
     --sjdbScore 2 \
     --alignSJDBoverhangMin 1 \
     --genomeLoad NoSharedMemory \
     --readFilesCommand zcat \
     --outFilterMatchNminOverLread 0.33 \
     --sjdbOverhang 100 \
     --outSAMstrandField intronMotif \
     --outSAMtype None \
     --outSAMmode None

# Paso 5: Segunda generación del índice del genoma utilizando la información de splicing obtenida (SJ.out.tab)

STAR --runMode genomeGenerate \
     --genomeDir Analysis \                 # Directorio del índice del genoma actualizado
     --genomeFastaFiles Analysis/STAR_index/GRCh38.primary_assembly.genome.fa \  # Archivo FASTA del genoma de referencia
     --sjdbOverhang 100 \
     --runThreadN 16 \
     --sjdbFileChrStartEnd SJ.out.tab       # Archivo de sitios de splicing (modificar ruta en todo caso)

# Paso 6: Segunda alineación de lecturas utilizando el nuevo índice del genoma y habilitando el conteo de genes
# Esta alineación genera un archivo BAM y un archivo con el conteo de genes (--quantMode GeneCounts).

STAR --genomeDir Analysis \               # Directorio del índice del genoma actualizado
     --readFilesIn FASTQ/SRR11124374_1.fastq.gz FASTQ/SRR11124374_2.fastq.gz \  # Archivos FASTQ (modificar rutas)
     --runThreadN 16 \
     --outFilterMultimapScoreRange 1 \
     --outFilterMultimapNmax 20 \
     --outFilterMismatchNmax 10 \
     --alignIntronMax 500000 \
     --alignMatesGapMax 1000000 \
     --sjdbScore 2 \
     --alignSJDBoverhangMin 1 \
     --genomeLoad NoSharedMemory \
     --limitBAMsortRAM 0 \
     --readFilesCommand zcat \
     --outFilterMatchNminOverLread 0.33 \
     --outFilterScoreMinOverLread 0.33 \
     --sjdbOverhang 100 \
     --outSAMstrandField intronMotif \
     --outSAMattributes NH HI NM MD AS XS \
     --outSAMunmapped Within \
     --outSAMtype BAM SortedByCoordinate \  # Archivo BAM ordenado por coordenadas
     --outSAMmode Full \
     --quantMode GeneCounts                # Habilitar el conteo de genes
