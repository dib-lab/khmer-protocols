   cd /usr/local/share
   git clone https://github.com/ged-lab/screed.git -b protocols-v0.8.3
   cd screed
   python setup.py install
   
   pip install git+https://github.com/ged-lab/screed.git@protocols-v0.8.3#egg=screed
   cd /usr/local/share
   git clone https://github.com/ged-lab/khmer.git -b protocols-v0.8.5
   cd khmer
   make install
   pip install git+https://github.com/ged-lab/khmer.git@protocols-v0.8.3#egg=khmer
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
   cd /usr/local/share
   git clone https://github.com/ged-lab/screed.git -b protocols-v0.8.3
   cd screed
   python setup.py install
   
   pip install git+https://github.com/ged-lab/screed.git@protocols-v0.8.3#egg=screed
   cd /usr/local/share
   git clone https://github.com/ged-lab/khmer.git -b protocols-v0.8.5
   cd khmer
   make install
   pip install git+https://github.com/ged-lab/khmer.git@protocols-v0.8.3#egg=khmer
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
   cd /mnt/work
   python /usr/local/share/khmer/sandbox/write-trimmomatic.py > trim.sh
   more trim.sh
   bash trim.sh
   This is a prime example of scripting to make your life much easier
   and less error prone.  Take a look at this file sometime --
   'more /usr/local/share/khmer/sandbox/write-trimmomatic.py' -- to get
   some idea of how this works.
   for i in *.pe.fq.gz *.se.fq.gz
   do
        echo working with $i
   done
   for i in *.pe.qc.fq.gz
   do
      /usr/local/share/khmer/scripts/extract-paired-reads.py $i
   done
   24HourB_GCCAAT_L002_R1_001.fastq.gz 	      	     - the original data
   24HourB_GCCAAT_L002_R2_001.fastq.gz
   24HourB_GCCAAT_L002_R1_001.pe.fq.gz		     - adapter trimmed pe
   24HourB_GCCAAT_L002_R1_001.pe.qc.fq.gz	     - FASTX filtered
   24HourB_GCCAAT_L002_R1_001.pe.qc.fq.gz.pe	     - FASTX filtered PE
   24HourB_GCCAAT_L002_R1_001.pe.qc.fq.gz.se	     - FASTX filtered SE
   24HourB_GCCAAT_L002_R1_001.se.fq.gz		     - adapter trimmed orphans
   24HourB_GCCAAT_L002_R1_001.se.qc.fq.gz	     - FASTX filtered orphans
   rm *.fastq.gz
   rm *.pe.fq.gz *.se.fq.gz
   rm *.pe.qc.fq.gz
   24HourB_GCCAAT_L002_R1_001.pe.qc.fq.gz.pe   - FASTX filtered PE
   24HourB_GCCAAT_L002_R1_001.pe.qc.fq.gz.se   - FASTX filtered SE
   24HourB_GCCAAT_L002_R1_001.se.qc.fq.gz      - FASTX filtered orphans
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
   mkdir save
   mv *.qc.fq.gz save
   du -sk save
   cd /usr/local/share
   git clone https://github.com/ged-lab/screed.git -b protocols-v0.8.3
   cd screed
   python setup.py install
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
   cd /mnt/work
   python /usr/local/share/khmer/sandbox/write-trimmomatic.py > trim.sh
   more trim.sh
   bash trim.sh
   for i in *.pe.fq.gz *.se.fq.gz
   do
        echo working with $i
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
   mkdir save
   mv *.qc.fq.gz save
   du -sk save
