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

.. ::

   set -x
   set -e
   source /home/ubuntu/work/bin/activate
   echo 8-compile-trinity START `date` >> ${HOME}/times.out

To install Trinity:
::

   cd ${HOME}
   
   wget https://github.com/trinityrnaseq/trinityrnaseq/archive/v2.0.4.tar.gz \
     -O trinity.tar.gz
   tar xzf trinity.tar.gz
   cd trinityrnaseq*/
   make |& tee trinity-build.log
   
   echo 8-compile-trinity DONE `date` >> ${HOME}/times.out



Assembling with Trinity
-----------------------

.. ::

   echo 9-big-assembly START `date` >> ${HOME}/times.out

Run the assembler!
::

   ${HOME}/trinity*/Trinity --left left.fq \
     --right right.fq --seqType fq --max_memory 14G \
     --CPU 2

Note that this last two parts (``--max_memory 14G --CPU ${THREADS:-2}``) is the
maximum amount of memory and CPUs to use.  You can increase (or decrease) them
based on what machine you rented. This size works for the m1.xlarge machines.

Once this completes (on the Nematostella data it might take about 12 hours),
you'll have an assembled transcriptome in
``${HOME}/projects/eelpond/trinity_out_dir/Trinity.fasta``.

You can now copy it over via Dropbox, or set it up for BLAST (see
:doc:`installing-blastkit`).

.. ::

   echo 9-big-assembly DONE `date` >> ${HOME}/times.out

.. shell stop
