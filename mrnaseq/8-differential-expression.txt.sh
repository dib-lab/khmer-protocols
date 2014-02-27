   cd /mnt
   mkdir ebseq
   cd ebseq
   cp ../rsem/0-vs-6-hour.matrix .
   rsem-run-ebseq 0-vs-6-hour.matrix 5,5 0-vs-6-hour.changed
   python /usr/local/share/eel-pond/extract-and-annotate-changed.py 0-vs-6-hour.changed /mnt/nematostella.fa 0-vs-6-hour.changed.csv
   python /usr/local/share/eel-pond/plot-expression.py 0-vs-6-hour.matrix 5,5 0-vs-6-hour.changed.csv
