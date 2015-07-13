=================================
2. Applying Digital Normalization
=================================

.. shell start

.. ::

   set -x
   set -e

.. note::

   You'll need ~15 GB of RAM for this, or more if you have a LOT of data.

Link in your data
-----------------

Make sure your data is in ``/mnt/work``::

   ls /mnt/work

Run digital normalization
-------------------------

.. ::

   echo 2-diginorm normalize1-pe `date` >> ${HOME}/times.out

Apply digital normalization to the paired-end reads ::

   cd /mnt/work
   normalize-by-median.py -p -k 20 -C 20 -N 4 \
     -x 3e9 --savetable normC20k20.ct -u orphans.fq.gz \
     *.pe.qc.fq.gz

.. ::

   echo 2-diginorm normalize1-se `date` >> ${HOME}/times.out

Note the ``-p`` in the normalize-by-median command -- when run on
PE data, that ensures that no paired ends are orphaned.  The ``-u`` tells
it that the following filename is unpaired.

.. @CTB fix below

Also note the ``--n_tables`` and ``--min_tablesize`` parameters.  These specify
how much memory diginorm should use.  The product of these should be less than
the memory size of the machine you selected.  The maximum needed for *any*
transcriptome should be in the ~60 GB range, e.g.
``-- n_tables 4 --min_tablesize 15e9``; for only a few hundred million reads,
16 GB should be plenty.  (See `choosing hash sizes for khmer`
<http://khmer.readthedocs.org/en/latest/choosing-hash-sizes.html>`__
for more information.)

Trim off likely erroneous k-mers
--------------------------------

.. ::

   echo 2-diginorm filter-abund `date` >> ${HOME}/times.out

Now, run through all the reads and trim off low-abundance parts of
high-coverage reads::

   filter-abund.py -V -Z 18 normC20k20.ct *.keep

This will turn some reads into orphans when their partner read is
removed by the trimming.

Rename files
~~~~~~~~~~~~

You'll have a bunch of ``keep.abundfilt`` files -- let's make things prettier.

.. ::
   
   echo 2-diginorm extract `date` >> ${HOME}/times.out

First, let's break out the orphaned and still-paired reads::

   for file in *.pe.*.abundfilt
   do 
      extract-paired-reads.py ${file}
   done

We can combine the orphaned reads into a single file::

   gzip -9c orphans.fq.gz.keep > orphans.keep.fq.gz
   for file in *.pe.*.abundfilt.se
   do
      gzip -9c $file >> orphans.keep.fq.gz
   done

We can also rename the remaining PE reads & compress those files::

   for file in *.abundfilt.pe
   do
      newfile=${file%%.fq.gz.keep.abundfilt.pe}.keep.abundfilt.fq
      mv ${file} ${newfile}
      gzip ${newfile}
   done

..
  # parallel version
  cd ${HOME}/projects/eel-pond/digiresult
  ls *.abundfilt.pe | parallel \
    'file={};
     newfile=${file%%.fq.gz.keep.abundfilt.pe}.keep.abundfilt.fq
     mv ${file} ${newfile}
     gzip ${newfile}'

This leaves you with a whole passel o' files, most of which you want to go
away!

.. ::

   echo 2-diginorm DONE `date` >> ${HOME}/times.out

So, finally, let's get rid of a lot of the old files ::

   rm *.keep *.abundfilt *.se
   rm diginorm/*
   rm abundfilt/*
   rmdir filteredreads diginorm abundfilt

Gut check
~~~~~~~~~

You should now have the following files in your directory (after typing
``ls digifilt``)::

   digifilt/6Hour_CGATGT_L002_R1_005.pe.qc.keep.abundfilt.fq.gz
   digifilt/6Hour_CGATGT_L002_R1_005.se.qc.keep.abundfilt.fq.gz

These files are, respectively, the paired (pe) quality-filtered (qc)
digitally normalized (keep) abundance-trimmed (abundfilt) FASTQ (fq)
gzipped (gz) sequences, and the orphaned (se) quality-filtered (qc)
digitally normalized (keep) abundance-trimmed (abundfilt) FASTQ (fq)
gzipped (gz) sequences.

Save all these files to a new volume, and get ready to assemble!

.. shell stop

Next: :doc:`3-big-assembly`.
