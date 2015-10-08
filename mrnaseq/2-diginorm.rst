for filename in *_R1_*.qc.fq.gz
do
     # first, make the base by removing .extract.fastq.gz
     (base=$(basename $filename .qc.fq.gz)
     echo $base

     # now, construct the R2 filename by replacing R1 with R2
     baseR2=${base/_R1_/_R2_}
     echo $baseR2

     # construct the output filename
     output=${base/_R1_/}.pe.qc.fq.gz)

done | \

     interleave-reads.py ${base}.qc.fq.gz ${baseR2}.qc.fq.gz | \
     normalize-by-median.py -k 20 -C 20 -M 4e9 - -o - | \
     trim-low-abund.py -V -k 20 -Z 20 -C 3 - -o - -M 4e9 | \
     extract-paired-reads.py --gzip  -p paired.gz -s single.gz
