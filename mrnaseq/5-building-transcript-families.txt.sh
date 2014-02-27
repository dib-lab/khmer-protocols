   cd /usr/local/share
   git clone https://github.com/ctb/eel-pond.git
   cd eel-pond
   git checkout protocols-v0.8.3
   cd /mnt
   gzip -c work/trinity_out_dir/Trinity.fasta > trinity-nematostella-raw.fa.gz
   python /usr/local/share/khmer/scripts/do-partition.py -x 1e9 -N 4 --threads 4 nema trinity-nematostella-raw.fa.gz
   python /usr/local/share/eel-pond/rename-with-partitions.py nema trinity-nematostella-raw.fa.gz.part
   mv trinity-nematostella-raw.fa.gz.part.renamed.fasta.gz trinity-nematostella.renamed.fa.gz
