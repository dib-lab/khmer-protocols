#! /bin/bash

### code block at 1-quality.rst:23

sudo apt-get update && \
sudo apt-get -y install screen git curl gcc make g++ python-dev unzip \
         default-jre pkg-config libncurses5-dev r-base-core r-cran-gplots \
         python-matplotlib python-pip python-virtualenv sysstat fastqc \
         trimmomatic bowtie samtools blast2 wget

### code block at 1-quality.rst:41

cd ~/
python2.7 -m virtualenv work
source work/bin/activate
pip install -U setuptools
git clone --branch v2.0 https://github.com/dib-lab/khmer.git
cd khmer
make install

### code block at 1-quality.rst:93

cd /mnt
mkdir -p work
cd work

ln -fs /mnt/data/*.fastq.gz .

### code block at 1-quality.rst:147

cd /mnt/work
wget https://sources.debian.net/data/main/t/trimmomatic/0.33+dfsg-1/adapters/TruSeq3-PE.fa

### code block at 1-quality.rst:171

rm -f orphans.fq.gz
for filename in *_R1_*.fastq.gz
do
     # first, make the base by removing fastq.gz
     base=$(basename $filename .fastq.gz)
     echo $base
     
     # now, construct the R2 filename by replacing R1 with R2
     baseR2=${base/_R1_/_R2_}
     echo $baseR2
     
     # finally, run Trimmomatic
     TrimmomaticPE ${base}.fastq.gz ${baseR2}.fastq.gz \
        ${base}.qc.fq.gz s1_se \
        ${baseR2}.qc.fq.gz s2_se \
        ILLUMINACLIP:TruSeq3-PE.fa:2:40:15 \
        LEADING:2 TRAILING:2 \
        SLIDINGWINDOW:4:2 \
        MINLEN:25
     
     # save the orphans
     gzip -9c s1_se s2_se >> orphans.fq.gz
     rm -f s1_se s2_se
done

### code block at 1-quality.rst:217

for filename in *_R1_*.qc.fq.gz
do
     # first, make the base by removing .extract.fastq.gz
     base=$(basename $filename .qc.fq.gz)
     echo $base
     # now, construct the R2 filename by replacing R1 with R2
     baseR2=${base/_R1_/_R2_}
     echo $baseR2
     # construct the output filename
     output=${base/_R1_/}.pe.qc.fq.gz
     (interleave-reads.py ${base}.qc.fq.gz ${baseR2}.qc.fq.gz | \
         gzip > $output) && rm ${base}.qc.fq.gz ${baseR2}.qc.fq.gz
done

### code block at 1-quality.rst:255

rm *.fastq.gz
