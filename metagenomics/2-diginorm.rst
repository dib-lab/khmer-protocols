================================
2. Running digital normalization
================================

.. |memuse| replace:: 4e9

.. shell start

.. ::

   set -x
   set -e
   source /home/ubuntu/work/bin/activate

.. note::

   Make sure you're running in screen!

Start with the QC'ed files from :doc:`1-quality` or copy them into a
working directory; 

Run a First Round of Digital Normalization
------------------------------------------

Normalize everything to a coverage of 20, starting with the (more valuable)
PE reads; keep pairs using ``-p``, and include orphans with ``-u``.

.. parsed-literal::

   cd /mnt/work
   normalize-by-median.py -p -k 20 -C 20 -M |memuse| \\
      --savetable normC20k20.ct -u orphans.fq.gz *.pe.qc.fq.gz

This produces a set of '.keep' files, as well as a normC20k20.ct
file containing k-mer counts that we will use in the next step.

Note the ``-x`` and ``-N`` parameters.  These specify how much
memory diginorm should use.  The product of these should be less than
the memory size of the machine you selected.  (See `choosing hash
sizes for khmer
<http://khmer.readthedocs.org/en/latest/choosing-hash-sizes.html>`__
for more information.)

Error-trim Our Data
--------------------

Use 'filter-abund' to trim off any k-mers that are abundance-1 in
high-coverage reads.  The -V option is used to ignore low coverage
reads that are prevalent in variable abundance data sets:
::

   filter-abund.py -V -Z 18 normC20k20.ct *.keep && \
      rm *.keep normC20k20.ct

This produces .abundfilt files containing the trimmed sequences.

The process of error trimming could have orphaned reads, so split the
PE file into still-interleaved and non-interleaved reads

::

   for file in *.pe.*.abundfilt
   do
      extract-paired-reads.py ${file} && \
           rm ${file}
   done

This leaves you with PE files (*.pe) and SE files (*.se).  Next, concatenate
all of the *.se files into orphan files
::

   gzip -9c orphans.fq.gz.keep.abundfilt *.se > orphans.keep.abundfilt.fq.gz && \
      rm orphans.fq.gz.keep.abundfilt *.se

Normalize Down to C=5
---------------------

Now that we've eliminated many more erroneous k-mers, let's ditch some more
high-coverage data.  First, normalize the paired-end reads 

.. parsed-literal::
    
   normalize-by-median.py -C 5 -k 20 -M |memuse| \\
      --savetable normC5k20.ct -p *.abundfilt.pe \\
      -u orphans.keep.abundfilt.fq.gz && \\
      rm *.abundfilt.pe orphans.keep.abundfilt.fq.gz

Compress and Combine the Files
------------------------------

Now let's tidy things up.  Here are the paired files (kak =
keep/abundfilt/keep) 
::
   
   for file in *.keep.abundfilt.pe.keep
   do 
      newfile=${file/fq.gz.keep.abundfilt.pe.keep/kak.fq}
      mv ${file} ${newfile}
      gzip -9 ${newfile}
   done

and here are the orphaned reads
::

   mv orphans.keep.abundfilt.fq.gz.keep orphans.kak.fq && \
      gzip orphans.kak.fq

-----

If you are *not* doing partitioning (see :doc:`3-partition`), you may
want to remove the k-mer hash tables::

   rm *.ct

Read Stats
----------

Try running

::

   readstats.py *.kak.fq.gz orphans.kak.fq.gz

after a long wait, you'll see::

   ---------------
   861769600 bp / 8617696 seqs; 100.0 average length -- SRR606249.pe.qc.fq.gz
   79586148 bp / 802158 seqs; 99.2 average length -- SRR606249.se.qc.fq.gz
   531691400 bp / 5316914 seqs; 100.0 average length -- SRR606249.pe.qc.fq.gz
   89903689 bp / 904157 seqs; 99.4 average length -- SRR606249.se.qc.fq.gz

   173748898 bp / 1830478 seqs; 94.9 average length -- SRR606249.pe.kak.qc.fq.gz
   8825611 bp / 92997 seqs; 94.9 average length -- SRR606249.se.kak.qc.fq.gz
   52345833 bp / 550900 seqs; 95.0 average length -- SRR606249.pe.kak.qc.fq.gz
   10280721 bp / 105478 seqs; 97.5 average length -- SRR606249.se.kak.qc.fq.gz
   
   ---------------

This shows you how many sequences were in the original QC files, and
how many are left in the 'kak' files.  Not bad -- considerably more
than 80% of the reads were eliminated in the kak!

----

Next: :doc:`3-partition`
