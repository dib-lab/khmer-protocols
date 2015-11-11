#! /bin/bash

### code block at 2-diginorm.rst:42

cd /mnt/work
normalize-by-median.py -p -k 20 -C 20 -M 4e9 \
  --savegraph normC20k20.ct -u orphans.fq.gz \
  *.pe.qc.fq.gz

### code block at 2-diginorm.rst:69

filter-abund.py -V -Z 18 normC20k20.ct *.keep && \
   rm *.keep normC20k20.ct

### code block at 2-diginorm.rst:87

for file in *.pe.*.abundfilt
do 
   extract-paired-reads.py ${file} && \
         rm ${file}
done

### code block at 2-diginorm.rst:96

gzip -9c orphans.fq.gz.keep.abundfilt > orphans.keep.abundfilt.fq.gz && \
    rm orphans.fq.gz.keep.abundfilt
for file in *.pe.*.abundfilt.se
do
   gzip -9c ${file} >> orphans.keep.abundfilt.fq.gz && \
        rm ${file}
done

### code block at 2-diginorm.rst:107

for file in *.abundfilt.pe
do
   newfile=${file%%.fq.gz.keep.abundfilt.pe}.keep.abundfilt.fq
   mv ${file} ${newfile}
   gzip ${newfile}
done
