================================================
1. Quality Trimming and Filtering Your Sequences
================================================

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
   echo 1-quality INSTALL `date` >> ${HOME}/times.out

Install `khmer <http://khmer.readthedocs.org>`__ from its source code.
::

   cd ~/
   python2.7 -m virtualenv work
   source work/bin/activate
   pip install -U setuptools
   git clone --branch v2.0 https://github.com/dib-lab/khmer.git
   cd khmer
   make install

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

.. note::

   This protocol takes many hours (days!) to run, so you might not want
   to run it on all the data the first time.  If you're using the
   example data, you can work with a subset of it by running this command
   instead of the `ln -fs` command above::

      cd /mnt/data
      mkdir -p extract
      for file in *.fastq.gz
      do
          gunzip -c ${file} | head -400000 | gzip \
              > extract/${file%%.fastq.gz}.extract.fastq.gz
      done

   This will pull out the first 100,000 reads of each file (4 lines per record)
   and put them in the new ``/mnt/data/extract`` directory.  Then, do::

      rm -fr /mnt/work
      mkdir /mnt/work
      cd /mnt/work
      ln -fs /mnt/data/extract/*.fastq.gz /mnt/work

   to work with the subset data.

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

.. note::

   You'll need to make sure these are the right adapters for your
   data.  If they are the right adapters, you should see that some of
   the reads are trimmed; if they're not, you won't see anything
   get trimmed.
   

Adapter trim each pair of files
-------------------------------

.. ::

   echo 1-quality TRIM `date` >> ${HOME}/times.out

(From this point on, you may want to be running things inside of
screen, so that you can leave it running while you go do something
else; see :doc:`../amazon/using-screen` for more information.)

Run
::

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


Each file with an R1 in its name should have a matching file with an R2 --
these are the paired ends.

The paired sequences output by this set of commands will be in the
files ending in ``qc.fq.gz``, with any orphaned sequences all together
in ``orphans.fq.gz``.

Interleave the sequences
------------------------

Next, we need to take these R1 and R2 sequences and convert them into
interleaved form, for the next step.  To do this, we'll use scripts
from the `khmer package <http://khmer.readthedocs.org>`__, which we
installed above.

Now let's use a for loop again - you might notice this is only a minor
modification of the previous for loop...
::

   for filename in *_R1_*.qc.fq.gz
   do
        # first, make the base by removing .extract.fastq.gz
        base=$(basename $filename .qc.fq.gz)
        echo $base

        # now, construct the R2 filename by replacing R1 with R2
        baseR2=${base/_R1_/_R2_}
        echo $baseR2

        # construct the output filename
        output=${base/_R1_/}.pe.qc.fq.gz

        (interleave-reads.py ${base}.qc.fq.gz ${baseR2}.qc.fq.gz | \
            gzip > $output) && rm ${base}.qc.fq.gz ${baseR2}.qc.fq.gz
   done

.. ::

   echo 1-quality DONE `date` >> ${HOME}/times.out

The final product of this is now a set of files named
``*.pe.qc.fq.gz`` that are paired-end / interleaved and quality
filtered sequences, together with the file ``orphans.fq.gz`` that
contains orphaned sequences.

Finishing up
------------

Make the end product files read-only::

   chmod u-w *.pe.qc.fq.gz orphans.fq.gz

to make sure you don't accidentally delete them.

If you linked your original data files into /mnt/work, you can now do
::

   rm *.fastq.gz

to remove them from this location; you don't need them any more.

Things to think about
~~~~~~~~~~~~~~~~~~~~~

Note that the filenames, while ugly, are conveniently structured with the
history of what you've done to them.  This is a good strategy to keep
in mind.

Evaluate the quality of your files with FastQC again
----------------------------------------------------

We can once again use FastQC to look at the
quality of your newly-trimmed sequences::

   fastqc *.pe.qc.fq.gz

.. Saving the files
.. ----------------

.. Foo goes here.

.. @@CTB

