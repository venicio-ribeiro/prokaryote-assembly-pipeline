# Pipeline de Montagem de novo e Avaliação de Qualidade de Genomas Procariotos

Este repositório fornece um fluxo de trabalho automatizado para a montagem *de novo* de genomas bacterianos a partir de dados do NCBI SRA, bem como as instruções necessárias para configurar um ambiente Linux isolado no Windows utilizando Docker, garantindo que todas as ferramentas e pipelines de Bioinformática funcionem corretamente, independente do sistema operacional base.

## Sobre o Ambiente
A maioria dos pipelines e softwares de Bioinformática é desenvolvida nativamente para **Linux**. Para usuários de Windows ou macOS, utilizamos o **Docker** para executar containers Linux.

O Docker permite "simular" sistemas operacionais em containers isolados, eliminando a necessidade de instalações complexas diretamente no seu computador pessoal.

---

##  Passo a Passo para Instalação

### 1. Baixar o Docker
Acesse o site oficial para baixar a versão Desktop:
*  [Download Docker Desktop](https://www.docker.com)

### 2. Instalação no Windows
Siga as instruções oficiais detalhadas para garantir que o motor do Docker funcione corretamente com o WSL 2 (Windows Subsystem for Linux):
*  [Guia de Instalação no Windows](https://docs.docker.com/docker-for-windows/install)

### 3. Executando o Container de Bioinformática
Após instalar o Docker, você pode carregar o ambiente configurado para este estudo de caso. Abra o terminal (PowerShell) e execute:
```bash
# Baixar a imagem do ambiente
docker pull waldeyr/bioinfo_basic:v1.0

# Iniciar o container em modo interativo
docker run -it --rm waldeyr/bioinfo_basic:v1.0 bash

Opção 2: Instalação Manual (Linux Fedora >= 31)
Caso prefira utilizar uma Máquina Virtual ou uma instalação nativa, utilize os comandos abaixo para configurar o ambiente do zero.

1. Preparação do Sistema
Bash
mkdir /home/bioinfo
cd /home/bioinfo
dnf update -y
dnf install libXcomposite libXcursor libXi libXtst libXrandr alsa-lib mesa-libEGL libXdamage mesa-libGL libXScrnSaver perl perl-CGI wget nano git -y
dnf groupinstall "Development Tools" -y

2. Instalação do Anaconda
Bash
wget [https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh](https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh)
chmod +x Anaconda3-2020.11-Linux-x86_64.sh
./Anaconda3-2020.11-Linux-x86_64.sh
export PATH="/home/anaconda3/bin:$PATH"

3. Configuração de Canais e Ferramentas (Bioconda)
Utilizamos o gerenciador conda para instalar as ferramentas específicas de bioinformática:

Bash
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

# Instalação dos softwares do pipeline
conda install -c bioconda sra-tools fastqc fastp spades glimmer blast seqkit -y
pip install quast

#  Montagem de Genoma procarioto

Este repositório fornece um fluxo de trabalho automatizado para a montagem *de novo* de genomas bacterianos a partir de dados do NCBI SRA. 

O script foi desenhado para ser **universal**: você escolhe o microrganismo (Ex: *Bacillus*, *Klebsiella*, *E. coli*), fornece o código de acesso e o pipeline executa todo o processamento, do download à estatística final.

##  Ferramentas e Lógica
O pipeline integra as ferramentas clássicas da bioinformática (seguindo a metodologia do Prof. Waldeyr Mendes):
- **Download:** SRA Toolkit
- **Qualidade:** FastQC & fastp (Filtro rigoroso Q30)
- **Montagem:** SPAdes (Algoritmo de Grafos de De Bruijn)
- **Processamento:** SeqKit (Filtro de tamanho > 1000bp)
- **Validação:** QUAST

##  Como Executar
1. Certifique-se de que o Docker está rodando com a imagem `waldeyr/bioinfo_basic:v1.0`.
2. Escolha um código de acesso SRR no [NCBI SRA](https://www.ncbi.nlm.nih.gov/sra).
3. Execute o script passando o código escolhido:

```bash
bash pipeline_procarioto.sh SRR36298167

## Créditos e Referências
- Ambiente Docker desenvolvido pelo Prof. Waldeyr (imagem `waldeyr/bioinfo_basic:v1.0`).
- Baseado no roteiro de estudos de [Programação para Bioinformática/Curso de Especialização em Bioinformática].
