   
   cd /root
   
   curl -O ftp://ftp.ncbi.nih.gov/blast/executables/release/2.2.24/blast-2.2.24-x64-linux.tar.gz
   tar xzf blast-2.2.24-x64-linux.tar.gz
   cp blast-2.2.24/bin/* /usr/local/bin
   cp -r blast-2.2.24/data /usr/local/blast-data
   cd /mnt
   gunzip trinity-nematostella.renamed.fa.gz 
   curl -O ftp://ftp.ncbi.nih.gov/refseq/M_musculus/mRNA_Prot/mouse.protein.faa.gz
   gunzip mouse.protein.faa.gz
   formatdb -i mouse.protein.faa -o T -p T
   formatdb -i trinity-nematostella.renamed.fa -o T -p F
   blastall -i trinity-nematostella.renamed.fa -d mouse.protein.faa -e 1e-3 -p blastx -o nema.x.mouse -a 8 -v 4 -b 4
   blastall -i mouse.protein.faa -d trinity-nematostella.renamed.fa -e 1e-3 -p tblastn -o mouse.x.nema -a 8 -v 4 -b 4
   python /usr/local/share/eel-pond/make-uni-best-hits.py nema.x.mouse nema.x.mouse.homol
   python /usr/local/share/eel-pond/make-reciprocal-best-hits.py nema.x.mouse mouse.x.nema nema.x.mouse.ortho
   python /usr/local/share/eel-pond/make-namedb.py mouse.protein.faa mouse.namedb
   python -m screed.fadbm mouse.protein.faa
   python /usr/local/share/eel-pond/annotate-seqs.py trinity-nematostella.renamed.fa nema.x.mouse.ortho nema.x.mouse.homol
   cp trinity-nematostella.renamed.fa.annot nematostella.fa
