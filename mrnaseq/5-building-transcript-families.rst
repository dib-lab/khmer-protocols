===============================
5. Building transcript families
===============================

.. shell start

Install khmer, screed, and BLAST.  (See :doc:`1-quality` and
:doc:`installing-blastkit`).  I would suggest using an m1.large or
m1.xlarge machine.

.. ::

   set -x
   set -e
   echo 5-building-transcript-families install `date` >> ${HOME}/times.out

You'll also need to setup a personal program binary directory::

   mkdir -p ${HOME}/bin
   export PATH=${PATH}:${HOME}/bin
   echo 'export PATH=${PATH}:${HOME}/bin' >> ${HOME}/.bashrc

Then install a script::

   cd ${HOME}/bin
   wget https://raw.githubusercontent.com/ctb/eel-pond/protocols-v0.8.3/rename-with-partitions.py
   chmod u+x rename-with-partitions.py

Copy in your data
=================

You need your assembled transcriptome (from
e.g. :doc:`3-big-assembly`).  Put it in the project directory as 
'trinity-nematostella-raw.fa.gz'::

   cd ${HOME}/projects/eelpond
   gzip -c trinity_out_dir/Trinity.fasta > trinity-nematostella-raw.fa.gz

For the purposes of your first run through, I suggest just grabbing my copy
of the Nematostella assembly::

   cd ${HOME}/projects/eelpond/
   curl -O https://s3.amazonaws.com/public.ged.msu.edu/trinity-nematostella-raw.fa.gz

Run khmer partitioning
======================

.. ::

   echo 5-building-transcript-families partition `date` >> ${HOME}/times.out

Partitioning runs a de Bruijn graph-based clustering algorithm that will
cluster your transcripts by transitive sequence overlap.  That is, it will
group transcripts into transcript families based on shared sequence. ::

   cd ${HOME}/projects/eelpond
   mkdir partitions
   cd partitions
   do-partition.py -x 1e9 -N 4 --threads ${THREADS:-1} nema \
     ../trinity-nematostella-raw.fa.gz

.. ::

   echo 5-building-transcript-families rename `date` >> ${HOME}/times.out

This should take about 15 minutes, and outputs a file ending in '.part'
that contains the partition assignments.  Now, group and rename the
sequences::

   cd ${HOME}/projects/eelpond/partitions
   rename-with-partitions.py nema trinity-nematostella-raw.fa.gz.part
   mv trinity-nematostella-raw.fa.gz.part.renamed.fasta.gz \
     trinity-nematostella.renamed.fa.gz

Looking at the renamed sequences
================================

Let's look at the renamed sequences::

   cd ${HOME}/projects/eelpond/partitions
   gunzip -c trinity-nematostella.renamed.fa.gz | head

You'll see that each sequence name looks like this::

   >nema.id1.tr16001 1_of_1_in_tr16001 len=261 id=1 tr=16001

Some explanation:

* ``nema`` is the prefix that you gave the rename script, above; modify
  accordingly for your own organism.  It's best to change it each time
  you do an assembly, just to keep things straight.

* ``idN`` is the unique ID for this sequence; it will never be repeated in this
   file.

* ``trN`` is the transcript family, which may contain one or more transcripts.

* ``1_of_1_in_tr16001`` tells you that this transcript family has only
  one transcript in it (this one!) Other transcript families may
  (will) have more.

* ``len`` is the sequence length.

.. ::

   echo 5-building-transcript-families DONE `date` >> ${HOME}/times.out

.. shell stop

Next: :doc:`6-annotating-transcript-families`
