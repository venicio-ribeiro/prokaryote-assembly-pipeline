#!/bin/bash

# =================================================================
# PIPELINE: Bacterial Genome Assembly (End-to-End)
# Autor: Vinícius (Bioinfo Project)
# Descrição: Download, QC, Trimming e Assembly de genomas bacterianos.
# =================================================================

SRR=$1
THREADS=$(nproc) # Detecta automaticamente quantos núcleos usar

# Verificação de entrada
if [ -z "$SRR" ]; then
    echo "❌ ERRO: Forneça um código SRR de acesso (Ex: SRR36298167)"
    exit 1
fi

echo "🚀 INICIANDO PIPELINE: $SRR"
echo "🧵 Usando $THREADS threads"
echo "----------------------------------------------------"

# --- 1. DOWNLOAD ---
if [[ -f "${SRR}_1.fastq" ]]; then
    echo "✅ Arquivos locais detectados."
else
    echo "🌐 Baixando dados via fastq-dump..."
    vdb-config --set /http/timeout/read=10000
    fastq-dump --split-files "$SRR"
fi

# Trava de segurança
if [ ! -f "${SRR}_1.fastq" ]; then
    echo "❌ FALHA: Arquivos não encontrados. Verifique a conexão."
    exit 1
fi

# --- 2. QUALIDADE (FastQC) ---
echo "📊 Passo 1: Controle de Qualidade (FastQC)..."
mkdir -p qc_reports
fastqc -t "$THREADS" "${SRR}_1.fastq" "${SRR}_2.fastq" -o qc_reports/

# --- 3. FILTRAGEM (FastP) ---
echo "✂️ Passo 2: Filtragem de Reads (FastP)..."
fastp -i "${SRR}_1.fastq" -I "${SRR}_2.fastq" \
      -o "${SRR}_1_trimmed.fastq" -O "${SRR}_2_trimmed.fastq" \
      --qualified_quality_phred 30 \
      --length_required 50 \
      --html "${SRR}_fastp.html" --json "${SRR}_fastp.json"

# --- 4. MONTAGEM (SPAdes) ---
echo "🏗️ Passo 3: Montagem do Genoma (SPAdes)..."
# Nota: O SPAdes pode falhar com poucos dados (subsample), mas é ideal para genomas reais.
spades.py --pe1-1 "${SRR}_1_trimmed.fastq" \
          --pe1-2 "${SRR}_2_trimmed.fastq" \
          -t "$THREADS" \
          --careful \
          -o "${SRR}_assembly_result"

# --- 5. FINALIZAÇÃO ---
echo "----------------------------------------------------"
if [ -f "${SRR}_assembly_result/contigs.fasta" ]; then
    echo "🎉 SUCESSO! Genoma montado em: ${SRR}_assembly_result/contigs.fasta"
else
    echo "⚠️ Pipeline concluído, mas a montagem falhou (verifique a cobertura dos dados)."
fi
