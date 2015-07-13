==============================
3. Running the Actual Assembly
==============================

.. shell start

All of the below should be run in screen, probably...  You will want
at least 15 GB of RAM, maybe more.

(If you start up a new machine, you'll need to go to
:doc:`1-quality` and go through the Install Software section.)

.. note::

   You can start this tutorial with the contents of EC2/EBS snapshot
   snap-7b0b872e.

Installing Trinity
------------------

.. ::

   set -x
   set -e
   echo 3-big-assembly compileTrinity `date` >> ${HOME}/times.out

To install Trinity:
::

   mkdir -p ${HOME}/src
   cd ${HOME}/src
   
   wget https://github.com/trinityrnaseq/trinityrnaseq/archive/v2.0.4.tar.gz \
     -O trinity.tar.gz
   tar xzf trinity.tar.gz
   cd trinityrnaseq*/
   make |& tee trinity-build.log

Build the files to assemble
---------------------------

.. ::

   echo 3-big-assembly extractReads `date` >> ${HOME}/times.out

For paired-end data, Trinity expects two files, 'left' and 'right';
there can be orphan sequences present, however.  So, below, we split
all of our interleaved pair files in two, and then add the single-ended
seqs to one of 'em. :
::

   cd ${HOME}/projects/eelpond/digiresult
   for file in *.pe.qc.keep.abundfilt.fq.gz
   do
      split-paired-reads.py ${file}
   done
   
   cat *.1 > left.fq
   cat *.2 > right.fq
   
   gunzip -c *.se.qc.keep.abundfilt.fq.gz >> left.fq

..
   # parallel version
   cd ${HOME}/projects/eelpond/digiresult
   ls *.pe.qc.keep.abundfilt.fq.gz | parallel split-paired-reads.py
   cat *.1 > left.fq & cat *.2 > right.fq
   gunzip -c *.se.qc.keep.abundfilt.fq.gz >> left.fq

Assembling with Trinity
-----------------------

.. ::

   echo 3-big-assembly assemble `date` >> ${HOME}/times.out

Run the assembler! ::

   cd ${HOME}/projects/eelpond
   ${HOME}/src/trinity*/Trinity --left digiresult/left.fq \
     --right digiresult/right.fq --seqType fq --max_memory 14G \
     --CPU ${THREADS:-2}

Note that this last two parts (``--max_memory 14G --CPU ${THREADS:-2}``) is the
maximum amount of memory and CPUs to use.  You can increase (or decrease) them
based on what machine you rented. This size works for the m1.xlarge machines.

Once this completes (on the Nematostella data it might take about 12 hours),
you'll have an assembled transcriptome in
``${HOME}/projects/eelpond/trinity_out_dir/Trinity.fasta``.

You can now copy it over via Dropbox, or set it up for BLAST (see
:doc:`installing-blastkit`).

.. ::

   echo 3-big-assembly DONE `date` >> ${HOME}/times.out

.. shell stop

Next: :doc:`5-building-transcript-families` (or :doc:`installing-blastkit`).
