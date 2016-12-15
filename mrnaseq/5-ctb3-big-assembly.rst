==============================
3. Running the Actual Assembly
==============================

.. docker::

   RUN apt-get -y install wget
   RUN pip install -U setuptools && pip install -U khmer==2.0

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
Flush the disk cache, then install trinity

.. ::

   echo 8-flush-disk START `date` >> ${HOME}/times.out
   echo 3 | sudo tee /proc/sys/vm/drop_caches
   echo 8-flush-disk DONE `date` >> ${HOME}/times.out

   set -x
   set -e
   source /home/ubuntu/work/bin/activate
   echo 9-compile-trinity START `date` >> ${HOME}/times.out

To install Trinity:
::

   cd ${HOME}
   
   curl -L https://github.com/trinityrnaseq/trinityrnaseq/archive/Trinity-v2.3.2.tar.gz > trinity.tar.gz
   tar xzf trinity.tar.gz
   cd trinityrnaseq*/
   make |& tee trinity-build.log
   
   echo 9-compile-trinity DONE `date` >> ${HOME}/times.out



Assembling with Trinity
-----------------------

.. ::


Run the assembler!
::

   echo 10-big-assembly START `date` >> ${HOME}/times.out

   ${HOME}/trinity*/Trinity --left left.fq \
     --right right.fq --seqType fq --max_memory 14G \
     --CPU 2

   echo 10-big-assembly DONE `date` >> ${HOME}/times.out


Note that this last two parts (``--max_memory 14G --CPU ${THREADS:-2}``) is the
maximum amount of memory and CPUs to use.  You can increase (or decrease) them
based on what machine you rented. This size works for the m1.xlarge machines.

Once this completes (on the Nematostella data it might take about 12 hours),
you'll have an assembled transcriptome in
``${HOME}/projects/eelpond/trinity_out_dir/Trinity.fasta``.

You can now copy it over via Dropbox, or set it up for BLAST (see
:doc:`installing-blastkit`).

.. ::


.. shell stop
