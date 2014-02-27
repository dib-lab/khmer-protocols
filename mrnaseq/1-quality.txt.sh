   cd /usr/local/share
   git clone https://github.com/ged-lab/khmer.git -b protocols-v0.8.5
   cd khmer
   make install
   cd /root
   curl -O http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.30.zip
   unzip Trimmomatic-0.30.zip
   cd Trimmomatic-0.30/
   cp trimmomatic-0.30.jar /usr/local/bin
   cp -r adapters /usr/local/share/adapters
   cd /root
   curl -O http://hannonlab.cshl.edu/fastx_toolkit/libgtextutils-0.6.1.tar.bz2
   tar xjf libgtextutils-0.6.1.tar.bz2 
   cd libgtextutils-0.6.1/
   ./configure && make && make install
   
   cd /root
   curl -O http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit-0.0.13.2.tar.bz2
   tar xjf fastx_toolkit-0.0.13.2.tar.bz2
   cd fastx_toolkit-0.0.13.2/
   ./configure && make && make install
   cd /mnt
   mkdir work
   cd work
   
   ln -fs /data/*.fastq.gz .
   cd /mnt/work
   python /usr/local/share/khmer/sandbox/write-trimmomatic.py > trim.sh
   more trim.sh
   bash trim.sh
   for i in *.pe.fq.gz *.se.fq.gz
   do
      echo working with $i
   newfile="$(basename $i .fq.gz)"
   gunzip -c $i | fastq_quality_filter -Q33 -q 30 -p 50 | gzip -9c > "${newfile}.qc.fq.gz"
   done
   for i in *.pe.qc.fq.gz
   do
      /usr/local/share/khmer/scripts/extract-paired-reads.py $i
   done
   rm *.fastq.gz
   rm *.pe.fq.gz *.se.fq.gz
   rm *.pe.qc.fq.gz
   for i in *.pe.qc.fq.gz.pe
   do
      newfile="$(basename $i .pe.qc.fq.gz.pe).pe.qc.fq"
      mv $i $newfile
      gzip $newfile
   done
   for i in *.pe.qc.fq.gz.se
   do
     otherfile="$(basename $i .pe.qc.fq.gz.se).se.qc.fq.gz"
     gunzip -c $otherfile > combine
     cat $i >> combine
     gzip -c combine > $otherfile
     rm $i combine
   done
   chmod u-w *.qc.fq.gz
