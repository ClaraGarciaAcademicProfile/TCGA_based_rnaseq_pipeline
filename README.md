 # RNA-seq Pipeline (TCGA-based)

Pipeline para la generación de matrices de conteo a partir de datos de RNA-seq (es un flujo basado en el protocolo utilizado por TCGA: https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/Expression_mRNA_Pipeline/#star-fusion-pipeline).

## Descripción

Este pipeline procesa datos de RNA-seq utilizando STAR para la alineación y genera matrices de conteo de genes. Es una adaptación del pipeline empleado por The Cancer Genome Atlas (TCGA), para procesar datos de diferentes consorcios y repositorios, uniformemente.

## Requisitos

### Software necesario:
- [STAR aligner](https://github.com/alexdobin/STAR) (v2.7+)
- GNU/Linux o macOS
- Al menos 32GB de RAM (recomendado)
- 16 cores de CPU (recomendado)

### Archivos de referencia:
- Genoma humano GRCh38: `GRCh38.primary_assembly.genome.fa.gz`
- Anotación de genes: `gencode.v36.basic.annotation.gtf.gz`
- Disponibles en: https://www.gencodegenes.org/human/release_46.html

## Uso

1. **Preparar archivos de referencia:**
   ```bash
   # Descargar desde GENCODE
   wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_36/GRCh38.primary_assembly.genome.fa.gz
   wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_36/gencode.v36.basic.annotation.gtf.gz
   ```

2. **Ejecutar el pipeline:**
   ```bash
   chmod +x TCGA_based_rnaseq_pipeline.sh
   ./TCGA_based_rnaseq_pipeline.sh
   ```

3. **Modificar rutas:** Antes de ejecutar, modifica las rutas en el script según tu estructura de directorios.

## Estructura del pipeline

El pipeline consta de 6 pasos principales:

1. **Descompresión** de archivos de referencia
2. **Instalación** de STAR (si es necesario)
3. **Generación** del índice inicial del genoma
4. **Primera alineación** para identificar sitios de splicing
5. **Regeneración** del índice con información de splicing
6. **Segunda alineación** con conteo de genes habilitado

## Archivos de entrada

- Archivos FASTQ paired-end (formato `.fastq.gz`)
- Los archivos pueden descargarse del European Nucleotide Archive (ENA)

## Archivos de salida

- Archivo BAM alineado y ordenado por coordenadas
- Matriz de conteos de genes (`ReadsPerGene.out.tab`)
- Archivos de log y estadísticas de alineación

## Configuración de parámetros

Los parámetros están optimizados para datos de RNA-seq humano según los estándares de TCGA:

- `--sjdbOverhang 100`: Para lecturas de ~100-150 nt
- `--outFilterMultimapNmax 20`: Máximo 20 alineaciones múltiples
- `--alignIntronMax 500000`: Intrones máximos de 500kb
- `--alignMatesGapMax 1000000`: Gap máximo entre pares de 1Mb

## Recursos computacionales

- **RAM mínima:** 32GB
- **Espacio en disco:** ~100GB para índices + tamaño de archivos FASTQ
- **Tiempo de ejecución:** Variable según tamaño de muestra (2-6 horas típicamente)

## Notas importantes

- Este pipeline debe ejecutarse para cada muestra individual
- Modifica las rutas de archivos según tu configuración
- Asegúrate de tener suficiente espacio en disco
- Considera usar un sistema de gestión de trabajos (SLURM, PBS) para clusters

## Contribuir

Si encuentras errores o tienes sugerencias de mejora, por favor:

1. Abre un issue describiendo el problema
2. Fork el repositorio
3. Crea una rama para tu feature (`git checkout -b feature/mejora`)
4. Commit tus cambios (`git commit -am 'Añadir mejora'`)
5. Push a la rama (`git push origin feature/mejora`)
6. Crea un Pull Request

## Citación
```
Pipeline RNA-seq basado en TCGA (2024)
```

## Contacto
Clara Victoria García Chávez

