==========================================================================================
1. Full data set nonstreaming through assembly, does not diginorm w/ disk flush before asm 
==========================================================================================

.. shell start

Boot up an m3.xlarge machine from Amazon Web Services running Ubuntu
14.04 LTS (ami-59a4a230); this has about 15 GB of RAM, and 2 CPUs, and
will be enough to complete the assembly of the Nematostella data
set. If you are using your own data, be aware of your space
requirements and obtain an appropriately sized machine ("instance")
and storage ("volume").

.. note::

   The raw data for this tutorial is available as public snapshot
   snap-f5a9dea7.

Install software
----------------

On the new machine, run the following commands to update the base
software:
::

   sudo apt-get update && \
   sudo apt-get -y install screen git curl gcc make g++ python-dev unzip \
            default-jre pkg-config libncurses5-dev r-base-core r-cran-gplots \
            python-matplotlib python-pip python-virtualenv sysstat fastqc \
            trimmomatic bowtie samtools blast2 wget
.. ::

   set -x
   set -e

   echo Clearing times.out
   touch ${HOME}/times.out
   mv -f ${HOME}/times.out ${HOME}/times.out.bak
   echo 0-install START `date` >> ${HOME}/times.out

Install `khmer <http://khmer.readthedocs.org>`__ from its source code.
::

   cd ~/
   python2.7 -m virtualenv work
   source work/bin/activate
   pip install -U setuptools
   git clone --branch v2.0 https://github.com/dib-lab/khmer.git
   cd khmer
   make install
   echo 0-install DONE `date` >> ${HOME}/times.out

The use of ``virtualenv`` allows us to install Python software without having
root access. If you come back to this protocol in a different terminal session
you will need to run::

        source ~/work/bin/activate

Find your data
--------------

Link in mounted data:
::

   cd /mnt
   sudo mkdir -p work
   cd work
   
   sudo ln -fs /home/ubuntu/data/*.fastq.gz .

Now, do an ``ls`` to list the files.  If you see only one entry,
``*.fastq.gz``, then the ln command above didn't work properly.  One
possibility is that your files aren't in /mnt/data; another is that
their names don't end with ``.fastq.gz``.


Run FastQC on all your files
----------------------------

We can use FastQC to look at the quality of
your sequences::

   fastqc *.fastq.gz

Find the right Illumina adapters
--------------------------------

You'll need to know which Illumina sequencing adapters were used for
your library in order to trim them off. Below, we will use the TruSeq3-PE.fa
adapters
::

   cd /mnt/work
   wget https://anonscm.debian.org/cgit/debian-med/trimmomatic.git/plain/adapters/TruSeq3-PE.fa

.. note: jessica swapped above link from "https://sources.debian.net/data/main/t/trimmomatic/0.33+dfsg-1/adapters/TruSeq3-PE.fa" because that one doesn't exist anymore, and it's still the TruSeq3-PE.fa file


Adapter trim each pair of files
-------------------------------

.. ::

(From this point on, you may want to be running things inside of
screen, so that you can leave it running while you go do something
else; see :doc:`../amazon/using-screen` for more information.)

Run
::

   echo 1-trim START `date` >> ${HOME}/times.out

   rm -f orphans.fq.gz

   for filename in *_R1_*.fastq.gz
   do
        # first, make the base by removing fastq.gz
        base=$(basename $filename .fastq.gz)
        echo $base
        
        # now, construct the R2 filename by replacing R1 with R2
        baseR2=${base/_R1_/_R2_}
        echo $baseR2
        
        # finally, run Trimmomatic
        TrimmomaticPE ${base}.fastq.gz ${baseR2}.fastq.gz \
           ${base}.qc.fq.gz s1_se \
           ${baseR2}.qc.fq.gz s2_se \
           ILLUMINACLIP:TruSeq3-PE.fa:2:40:15 \
           LEADING:2 TRAILING:2 \
           SLIDINGWINDOW:4:2 \
           MINLEN:25
        
        # save the orphans
        gzip -9c s1_se s2_se >> orphans.fq.gz
        rm -f s1_se s2_se
   done
   echo 1-trim DONE `date` >> ${HOME}/times.out
   
   zcat *R1* > left.fq
   zcat *R2* > right.fq

   gunzip orphans.fq.gz >> left.fq
   

Installing Trinity
------------------
Flush the disk cache, then install trinity

.. ::
   cd ${HOME}

   echo 2-flush-disk START `date` >> ${HOME}/times.out
   echo 3 | sudo tee /proc/sys/vm/drop_caches
   echo 2-flush-disk DONE `date` >> ${HOME}/times.out

   set -x
   set -e
   source /home/ubuntu/work/bin/activate
   echo 3-compile-trinity START `date` >> ${HOME}/times.out

To install Trinity:
::

   cd ${HOME}
   
   wget https://github.com/trinityrnaseq/trinityrnaseq/archive/v2.0.4.tar.gz \
     -O trinity.tar.gz
   tar xzf trinity.tar.gz
   cd trinityrnaseq*/
   make |& tee trinity-build.log
   
   echo 3-compile-trinity DONE `date` >> ${HOME}/times.out



Assembling with Trinity
-----------------------

.. ::


Run the assembler!
::

   cd /mnt/work   

   echo 4-big-assembly START `date` >> ${HOME}/times.out

   ${HOME}/trinity*/Trinity --left left.fq \
     --right right.fq --seqType fq --max_memory 14G \
     --CPU 2

   echo 4-big-assembly DONE `date` >> ${HOME}/times.out


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
