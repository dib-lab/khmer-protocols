   /usr/local/share/khmer/scripts/normalize-by-median.py -p -k 20 -C 20 -N 4 -x 3e9 --savehash normC20k20.kh *.pe.qc.fq.gz
   /usr/local/share/khmer/scripts/normalize-by-median.py -C 20 --loadhash normC20k20.kh --savehash normC20k20.kh *.se.qc.fq.gz
   /usr/local/share/khmer/scripts/filter-abund.py -V normC20k20.kh *.keep
   for i in *.pe.*.abundfilt;
   do 
      /usr/local/share/khmer/scripts/extract-paired-reads.py $i
   done
   for i in *.se.qc.fq.gz.keep.abundfilt
   do
      pe_orphans=$(basename $i .se.qc.fq.gz.keep.abundfilt).pe.qc.fq.gz.keep.abundfilt.se
      newfile=$(basename $i .se.qc.fq.gz.keep.abundfilt).se.qc.keep.abundfilt.fq.gz
      cat $i $pe_orphans | gzip -c > $newfile
   done
   for i in *.abundfilt.pe
   do
      newfile=$(basename $i .fq.gz.keep.abundfilt.pe).keep.abundfilt.fq
      mv $i $newfile
      gzip $newfile
   done
   rm *.se.qc.fq.gz.keep.abundfilt
   rm *.pe.qc.fq.gz.keep.abundfilt.se
   rm *.keep
   rm *.abundfilt
   rm *.qc.fq.gz
   rm *.kh
