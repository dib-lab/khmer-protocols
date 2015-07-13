=================================
2. Applying Digital Normalization
=================================

.. shell start

.. ::

   set -x
   set -e

.. note::

   You can start this tutorial with the contents of EC2/EBS snapshot
   snap-126cc847.

.. note::

   You'll need ~15 GB of RAM for this, or more if you have a LOT of data.

Link in your data
-----------------

Make sure your data is in ``${HOME}/projects/eelpond/filtered-pairs``::

   ls ${HOME}/projects/eelpond/filtered-pairs

If you've loaded it onto ``${HOME}/data/``, you can do::

   mkdir -p ${HOME}/projects/eelpond/filtered-pairs
   ln -fs ${HOME}/data/*.qc.fq.gz ${HOME}/projects/eelpond/filtered-pairs/

Run digital normalization
-------------------------

.. ::

   echo 2-diginorm normalize1-pe `date` >> ${HOME}/times.out

Apply digital normalization to the paired-end reads ::

   cd ${HOME}/projects/eelpond/
   mkdir diginorm
   cd diginorm
   normalize-by-median.py --paired -ksize 20 --cutoff 20 -n_tables 4 \
     --min-tablesize 3e8 --savetable normC20k20.ct \
     ../filtered-pairs/*.pe.qc.fq.gz

.. ::

   echo 2-diginorm normalize1-se `date` >> ${HOME}/times.out

and then to the single-end reads::

   normalize-by-median.py --cutoff 20 --loadtable normC20k20.ct \
     --savetable normC20k20.ct ../filtered-pairs/*.se.qc.fq.gz

Note the ``--paired`` in the first normalize-by-median command -- when run on
PE data, that ensures that no paired ends are orphaned.  However, it
will complain on single-ended data, so you have to give the data to it
separately.

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

   cd ${HOME}/projects/eelpond
   mkdir abundfilt
   cd abundfilt
   filter-abund.py --variable-coverage ../diginorm/normC20k20.ct \
     --threads ${THREADS:-1} ../diginorm/*.keep

This will turn some reads into orphans, but that's ok -- their partner
read was bad.

Rename files
~~~~~~~~~~~~

You'll have a bunch of 'keep.abundfilt' files -- let's make things prettier.

.. ::
   
   echo 2-diginorm extract `date` >> ${HOME}/times.out

First, let's break out the orphaned and still-paired reads::

   cd ${HOME}/projects/eel-pond
   mkdir digiresult
   cd digiresult
   for file in ../abundfilt/*.pe.*.abundfilt
   do 
      extract-paired-reads.py ${file}
   done

..
 # parallel version
 cd ${HOME}/projects/eel-pong
 mkdir digiresult
 cd digiresult
 ls ../abundfilt/*.pe* | parallel extract-paired-reads.py

We can combine the orphaned reads into a single file::

   cd ${HOME}/projects/eel-pond/abundfilt
   for file in *.se.qc.fq.gz.keep.abundfilt
   do
      pe_orphans=${file%%.se.qc.fq.gz.keep.abundfilt}.pe.qc.fq.gz.keep.abundfilt.se
      newfile=${file%%.se.qc.fq.gz.keep.abundfilt}.se.qc.keep.abundfilt.fq.gz
      cat ${file} ../digiresult/${pe_orphans} | gzip -c > ../digiresult/${newfile}
      rm ${pe_orphans}
   done

..
   # parallel version
   cd ${HOME}/projects/eel-pond/abundfilt
   ls *.se.qc.fq.gz.keep.abundfilt | parallel \
     'file={};
     pe_orphans=${file%%.se.qc.fq.gz.keep.abundfilt}.pe.qc.fq.gz.keep.abundfilt.se;
     newfile=${file%%.se.qc.fq.gz.keep.abundfilt}.se.qc.keep.abundfilt.fq.gz;
     cat ${file} ../digiresult/${pe_orphans} \
       | gzip -c > ../digiresult/${newfile} \
     rm ${pe_orphans}'

We can also rename the remaining PE reads & compress those files::

   cd ${HOME}/projects/eel-pond/digiresult
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
away! ::

   filtered-reads/6Hour_CGATGT_L002_R1_005.pe.qc.fq.gz
   filtered-reads/6Hour_CGATGT_L002_R1_005.se.qc.fq.gz
   diginorm/6Hour_CGATGT_L002_R1_005.pe.qc.fq.gz.keep
   diginorm/6Hour_CGATGT_L002_R1_005.se.qc.fq.gz.keep
   diginorm/normC20k20.ct
   abundfilt/6Hour_CGATGT_L002_R1_005.pe.qc.fq.gz.keep.abundfilt
   abundfilt/6Hour_CGATGT_L002_R1_005.se.qc.fq.gz.keep.abundfilt
   digiresult/6Hour_CGATGT_L002_R1_005.pe.qc.keep.abundfilt.fq.gz
   digiresult/6Hour_CGATGT_L002_R1_005.se.qc.keep.abundfilt.fq.gz

.. ::

   echo 2-diginorm DONE `date` >> ${HOME}/times.out

So, finally, let's get rid of a lot of the old files ::

   rm filteredreads/*
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
