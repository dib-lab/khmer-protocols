.. shell start


for filename in *_R1_*.qc.fq.gz
do
     (base=$(basename $filename .qc.fq.gz)
     baseR2=${base/_R1_/_R2_}
     output=${base/_R1_/}.pe.qc.fq.gz)

     interleave-reads.py ${base}.qc.fq.gz ${baseR2}.qc.fq.gz  

done | \

     normalize-by-median.py -k 20 -C 20 -M 4e9 - -o - | \
     trim-low-abund.py -V -k 20 -Z 20 -C 3 - -o - -M 4e9 | \
     extract-paired-reads.py --gzip  -p paired.gz -s single.gz

.. shell stop
