=================================
2. Applying Digital Normalization
=================================

In this section, we'll apply `digital normalization
<http://arxiv.org/abs/1203.4802>`__ and `variable-coverage k-mer
abundance trimming <https://peerj.com/preprints/890/>`__ to the reads
prior to assembly.  This has the effect of reducing the computational
cost of assembly `without negatively affecting the quality of the
assembly <https://peerj.com/preprints/505/>`__.

.. shell start

.. ::

   set -x
   set -e
   source /home/ubuntu/work/bin/activate

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

Apply digital normalization to the paired-end reads
::

   cd /mnt/work
   normalize-by-median.py -p -k 20 -C 20 -N 4 \
     -x 3e9 --savetable normC20k20.ct -u orphans.fq.gz \
     *.pe.qc.fq.gz

Note the ``-p`` in the normalize-by-median command -- when run on
PE data, that ensures that no paired ends are orphaned.  The ``-u`` tells
it that the following filename is unpaired.

Also note the ``-x`` and ``-N`` parameters.  These specify how much
memory diginorm should use.  The product of these should be less than
the memory size of the machine you selected.  (See `choosing hash
sizes for khmer
<http://khmer.readthedocs.org/en/latest/choosing-hash-sizes.html>`__
for more information.)

Trim off likely erroneous k-mers
--------------------------------

.. ::

   echo 2-diginorm filter-abund `date` >> ${HOME}/times.out

Now, run through all the reads and trim off low-abundance parts of
high-coverage reads
::

   filter-abund.py -V -Z 18 normC20k20.ct *.keep && \
      rm *.keep normC20k20.ct

This will turn some reads into orphans when their partner read is
removed by the trimming.

Rename files
~~~~~~~~~~~~

You'll have a bunch of ``keep.abundfilt`` files -- let's make things prettier.

.. ::
   
   echo 2-diginorm extract `date` >> ${HOME}/times.out

First, let's break out the orphaned and still-paired reads
::

   for file in *.pe.*.abundfilt
   do 
      extract-paired-reads.py ${file} && \
            rm ${file}
   done

We can combine all of the orphaned reads into a single file
::

   gzip -9c orphans.fq.gz.keep.abundfilt > orphans.keep.abundfilt.fq.gz && \
       rm orphans.fq.gz.keep.abundfilt
   for file in *.pe.*.abundfilt.se
   do
      gzip -9c ${file} >> orphans.keep.abundfilt.fq.gz && \
           rm ${file}
   done

We can also rename the remaining PE reads & compress those files
::

   for file in *.abundfilt.pe
   do
      newfile=${file%%.fq.gz.keep.abundfilt.pe}.keep.abundfilt.fq
      mv ${file} ${newfile}
      gzip ${newfile}
   done

This leaves you with a bunch of files named ``*.keep.abundfilt.fq``,
which represent the paired-end/interleaved reads that remain after
both digital normalization and error trimming, together with
``orphans.keep.fq.gz``

Save all these files to a new volume, and get ready to assemble!

.. ::

   echo 2-diginorm DONE `date` >> ${HOME}/times.out

.. shell stop

Next: :doc:`3-big-assembly`.
