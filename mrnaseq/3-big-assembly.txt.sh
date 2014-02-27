   cd /root
   
   curl -L http://sourceforge.net/projects/trinityrnaseq/files/latest/download?source=files > trinity.tar.gz
   tar xzf trinity.tar.gz
   cd trinityrnaseq*/
   export FORCE_UNSAFE_CONFIGURE=1
   make
   cd /root
   curl -O -L http://sourceforge.net/projects/bowtie-bio/files/bowtie/0.12.7/bowtie-0.12.7-linux-x86_64.zip
   unzip bowtie-0.12.7-linux-x86_64.zip
   cd bowtie-0.12.7
   cp bowtie bowtie-build bowtie-inspect /usr/local/bin
   cd /root
   curl -L http://sourceforge.net/projects/samtools/files/latest/download?source=files >samtools.tar.bz2
   tar xjf samtools.tar.bz2
   mv samtools-* samtools-latest
   cd samtools-latest/
   make
   cp samtools bcftools/bcftools misc/* /usr/local/bin
   cd /mnt/work
   for i in *.pe.qc.keep.abundfilt.fq.gz
   do
   python /usr/local/share/khmer/scripts/split-paired-reads.py $i
   done
   
   cat *.1 > left.fq
   cat *.2 > right.fq
   
   gunzip -c *.se.qc.keep.abundfilt.fq.gz >> left.fq
   /root/trinityrnaseq*/Trinity.pl --left left.fq --right right.fq --seqType fq -JM 10G
