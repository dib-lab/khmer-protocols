   # apt-get -y install r-base-core r-cran-gplots
   # cd /root
   # curl -O http://deweylab.biostat.wisc.edu/rsem/src/rsem-1.2.8.tar.gz
   # tar xzf rsem-1.2.8.tar.gz
   # cd rsem-1.2.8
   # make
   # cd EBSeq
   # make
   # echo 'export PATH=$PATH:/root/rsem-1.2.8' >> ~/.bashrc
   # source ~/.bashrc
   # cd /root
   # curl -O -L http://sourceforge.net/projects/bowtie-bio/files/bowtie/0.12.7/bowtie-0.12.7-linux-x86_64.zip
   # unzip bowtie-0.12.7-linux-x86_64.zip
   # cd bowtie-0.12.7
   # cp bowtie bowtie-build bowtie-inspect /usr/local/bin
   # cd /mnt
   # mkdir rsem
   # cd rsem
   # ln -fs ../nematostella.fa .

   # python /usr/local/share/eel-pond/make-transcript-to-gene-map-file.py nematostella.fa nematostella.fa.tr_to_genes
   rsem-prepare-reference --transcript-to-gene-map nematostella.fa.tr_to_genes nematostella.fa nema
   ln -fs /data/*.pe.qc.fq.gz .
   ls -1 *.pe.qc.fq.gz > list.txt
   n=1
   for filename in $(cat list.txt)
   do
       echo mapping $filename
       gunzip -c $filename > ${n}.fq
       /usr/local/share/khmer/scripts/split-paired-reads.py ${n}.fq
       rsem-calculate-expression --paired-end ${n}.fq.1 ${n}.fq.2 nema -p 4 ${n}.fq
       rm ${n}.fq ${n}.fq.[12] ${n}.fq.transcript.bam ${n}.fq.transcript.sorted.bam
       n=$(($n + 1))
   done
   rsem-generate-data-matrix [0-9].fq.genes.results 10.fq.genes.results > 0-vs-6-hour.matrix
   rsem-generate-data-matrix 1.fq.genes.results 3.fq.genes.results > results.matrix
