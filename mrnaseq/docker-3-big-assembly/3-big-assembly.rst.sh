#! /bin/bash

### code block at 3-big-assembly.rst:33

cd ${HOME}

wget https://github.com/trinityrnaseq/trinityrnaseq/archive/v2.0.4.tar.gz \
  -O trinity.tar.gz
tar xzf trinity.tar.gz
cd trinityrnaseq*/
make |& tee trinity-build.log

### code block at 3-big-assembly.rst:54

cd /mnt/work
for file in *.pe.qc.keep.abundfilt.fq.gz
do
   split-paired-reads.py ${file}
done

cat *.1 > left.fq
cat *.2 > right.fq

gunzip -c orphans.keep.abundfilt.fq.gz >> left.fq

### code block at 3-big-assembly.rst:75

${HOME}/trinity*/Trinity --left left.fq \
  --right right.fq --seqType fq --max_memory 14G \
  --CPU ${THREADS:-2}
