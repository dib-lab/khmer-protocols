============================================================
6. Annotating transcript families
============================================================

.. shell start

.. ::

   echo 6-annotating-transcript-families START `date` >> ${HOME}/times.out

.. ::

   set -x
   set -e
   echo 6-annotating-transcript-families start `date` >> ${HOME}/times.out

You can start with the 'trinity-nematostella.renamed.fa.gz' file from the
previous page (:doc:`5-building-transcript-families`) _or_ download
a precomputed one::

      cd ${HOME}/projects/eelpond/partitions
      curl -O http://public.ged.msu.edu.s3.amazonaws.com/trinity-nematostella.renamed.fa.gz

.. note::

   The BLASTs below will take a *long* time, like 24-36 hours.  If you
   want to work with canned BLASTs, do::

      cd ${HOME}/projects/eelpond/annotation
      curl -O http://public.ged.msu.edu.s3.amazonaws.com/nema.x.mouse.gz
      curl -O http://public.ged.msu.edu.s3.amazonaws.com/mouse.x.nema.gz
      gunzip nema.x.mouse.gz
      gunzip mouse.x.nema.gz

   However, if you built your own transcript families, you'll need to
   rerun these BLASTs.

Doing a preliminary annotation against mouse
============================================

Now let's assign putative homology & orthology to these transcripts, by
doing BLASTs & reciprocal best hit analysis.  First, uncompress your
transcripts file::

   cd ${HOME}/projects/eelpond/
   mkdir annotation
   cd annotation
   gunzip -c ../partitions/trinity-nematostella.renamed.fa.gz \
     trinity-nematostella.renamed.fa

Now, grab the latest mouse RefSeq::

   cd ${HOME}/projects/eelpond/annotation
   for file in mouse.1.protein.faa.gz mouse.2.protein.faa.gz
   do
        curl -O ftp://ftp.ncbi.nih.gov/refseq/M_musculus/mRNA_Prot/${file}
   done
   gunzip mouse.[123].protein.faa.gz
   cat mouse.[123].protein.faa > mouse.protein.faa

.. ::

   echo 6-annotating-transcript-families blast `date` >> ${HOME}/times.out

Format both as BLAST databases::

   formatdb -i mouse.protein.faa -o T -p T
   formatdb -i trinity-nematostella.renamed.fa -o T -p F

And, now, if you haven't downloaded the canned BLAST data above, run
BLAST in both directions.  Note, this may take ~24 hours or longer;
you probably want to run it in screen:
::

    blastx -db mouse.protein.faa -query trinity-nematostella.renamed.fa \
       -evalue 1e-3 -num_threads 8 -num_descriptions 4 -num_alignments 4 \
       -out nema.x.mouse   
       tblastn -db trinity-nematostella.renamed.fa -query mouse.protein.faa \
       -evalue 1e-3 -num_threads 8 -num_descriptions 4 -num_alignments 4 \
       -out mouse.x.nema

Assigning names to sequences
============================

.. ::

   echo 6-annotating-transcript-families homolortho `date` >> ${HOME}/times.out

Now, calculate putative homology (best BLAST hit) and orthology
(reciprocal best hits)::

   make-uni-best-hits.py nema.x.mouse nema.x.mouse.homol
   make-reciprocal-best-hits.py nema.x.mouse mouse.x.nema nema.x.mouse.ortho

Prepare some of the mouse info::

   make-namedb.py mouse.protein.faa mouse.namedb
   python -m screed.fadbm mouse.protein.faa

And, finally, annotate the sequences::

   annotate-seqs.py trinity-nematostella.renamed.fa nema.x.mouse.ortho \
     nema.x.mouse.homol

After this last, you should see::

   207533 sequences total
   10471 annotated / ortho
   95726 annotated / homol
   17215 annotated / tr
   123412 total annotated

If any of these numbers are zero on the nematostella data, then you
probably need to redo the BLAST.

This will produce a file 'trinity-nematostella.renamed.fa.annot', which
will have sequences that look like this::

   >nematostella.id1.tr115222 h=43% => suppressor of tumorigenicity 7 protein isoform 2 [Mus musculus] 1_of_7_in_tr115222 len=1635 id=1 tr=115222 1_of_7_in_tr115222 len=1635 id=1 tr=115222

I suggest renaming this file to 'nematostella.fa' and using it for
BLASTs (see :doc:`installing-blastkit`). ::

   cp trinity-nematostella.renamed.fa.annot nematostella.fa

The annotate-seqs command will *also* produce two CSV files.  The first,
``trinity-nematostella.renamed.fa.annot.csv``, is small, and contains
sequence names linked to orthology and homology information.  The secnod,
``trinity-nematostella.renamed.fa.annot.large.csv``, is large, and
contains all of the same information as in the first but *also* contains
all of the actual DNA sequence in the last column.  (Some spreadsheet
programs may not be able to open it.)  You can do::

   cp *.csv ${HOME}/Dropbox

to copy them locally, if you have set up Dropbox (see:
:doc:`../amazon/installing-dropbox`).

.. ::

   echo 6-annotating-transcript-families DONE `date` >> ${HOME}/times.out

.. shell stop

Next: :doc:`7-expression-analysis`.
