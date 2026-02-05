#!/bin/bash

# Verifica se o usuário passou um código SRR como argumento
# Exemplo de uso: bash pipeline_universal.sh SRR36298167
SRR=$1

if [ -z "$SRR" ]; then
    echo "ERRO: Você precisa fornecer um código SRR."
    echo "Uso: bash pipeline_universal.sh <CODIGO_SRR>"
    exit 1
fi

echo "--- INICIANDO PIPELINE UNIVERSAL PARA: $SRR ---"

# 1. Download
echo "--- ETAPA 1: Baixando as reads do NCBI ---"
fastq-dump --split-files $SRR

# 2. Qualidade
echo "--- ETAPA 2: Verificando qualidade inicial ---"
fastqc ${SRR}_1.fastq ${SRR}_2.fastq

# 3. Filtragem (Q30)
echo "--- ETAPA 3: Filtragem de qualidade (FastP) ---"
fastp -i ${SRR}_1.fastq -I ${SRR}_2.fastq \
      -o ${SRR}_1_FILTERED.fastq -O ${SRR}_2_FILTERED.fastq \
      -q 30 -l 50 -e 30

# 4. Montagem
echo "--- ETAPA 4: Montagem do Genoma (SPAdes) ---"
spades.py --pe1-1 ${SRR}_1_FILTERED.fastq \
          --pe1-2 ${SRR}_2_FILTERED.fastq \
          -t 4 --careful --cov-cutoff auto \
          -o ${SRR}_assembly

# 5. Filtro de Contigs
echo "--- ETAPA 5: Filtrando contigs < 1000bp ---"
seqkit seq -m 1000 ${SRR}_assembly/scaffolds.fasta -o genoma_${SRR}_final.fasta

# 6. Estatísticas
echo "--- ETAPA 6: Estatísticas Finais (QUAST) ---"
quast.py genoma_${SRR}_final.fasta

echo "--- PIPELINE CONCLUÍDO PARA O ACESSO $SRR ---"
