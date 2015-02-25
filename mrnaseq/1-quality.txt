================================================
1. Quality Trimming and Filtering Your Sequences
================================================

.. shell start

Boot up an m1.xlarge machine from Amazon Web Services running Ubuntu
12.04 LTS (ami-59a4a230); this has about 15 GB of RAM, and 2 CPUs, and
will be enough to complete the assembly of the Nematostella data set. If you
are using your own data, be aware of your space requirements and obtain an
appropriately sized machine ("instance") and storage ("volume").

.. note::

   The raw data for this tutorial is available as public snapshot
   snap-f5a9dea7.

Install software
----------------

.. Rackspace instructions
   15 GB I/O v1
   
   mkfs -t ext4 /dev/xvde
   mkdir /data
   mount /dev/xvde /data
   cd /data
   chmod -R a+rw /data
   mkdir nemo
   cd nemo
   curl -O http://athyra.idyll.org/~t/mrnaseq-subset.tar
   tar xvf mrnaseq-subset.tar

On the new machine, run the following commands to update the base
software and reboot the machine::

   apt-get update
   apt-get -y install screen git curl gcc make g++ python-dev unzip default-jre \
              pkg-config libncurses5-dev r-base-core r-cran-gplots \
              python-matplotlib python-pip python-virtualenv sysstat fastqc \
              trimmomatic fastx-toolkit bowtie samtools blast2
.. ::

   set -x
   set -e

   echo Clearing times.out
   mv -f ${HOME}/times.out ${HOME}/times.out.bak
   echo 1-quality INSTALL `date` >> ${HOME}/times.out

Now switch to the non-root user.

Since we have four CPUs on this machine we'll set a variable that we will use
elsewhere so that our programs make use of all the CPUs ::

   THREADS=4

Install `khmer <http://khmer.readthedocs.org>`_. We need some files from the
sandbox so we will download the full source repository instead of using
Python's pip command ::

   cd ${HOME}
   mkdir -p projects/eelpond
   python2.7 -m virtualenv projects/eelpond/env
   source ${HOME}/projects/eelpond/env/bin/activate
   mkdir -p src
   cd src
   git clone --branch v1.3 https://github.com/ged-lab/khmer.git
   cd khmer
   make install

The use of ``virtualenv`` allows us to install Python software without having
root access. If you come back to this protocol in a different terminal session
you will need to rerun ``source ${HOME}/projects/eelpond/env/bin/activate``
again.

Find your data
--------------

Either load in your own data (as in :doc:`0-download-and-save`) or
create a volume from snapshot snap-f5a9dea7 and mount it as
``${HOME}/data/nemo`` or other appropriate place. (again, this is the data
from `Tulin et al., 2013 <http://www.evodevojournal.com/content/4/1/16>`__).

Check::

   ls ${HOME}/data/nemo

If you see all the files you think you should, good!  Otherwise, debug.

If you're using the Tulin et al. data provided in the snapshot above,
you should see a bunch of files like::

   0Hour_ATCACG_L002_R1_001.fastq.gz

Link your data into a working directory
---------------------------------------

Rather than *copying* the files into the working directory, let's just
*link* them in -- this creates a reference so that UNIX knows where to
find them but doesn't need to actually move them around. :
::

   cd ${HOME}
   mkdir -p projects/eelpond/raw
   cd projects/eelpond/raw
   
   ln -fs ${HOME}/data/nemo/*.fastq.gz .

(The ``ln`` command does the linking.)

Now, do an ``ls`` to list the files.  If you see only one entry, ``*.fastq.gz``,
then the ln command above didn't work properly.  One possibility is that
your files aren't in /data; another is that their names don't end with
``.fastq.gz``.

.. note::

   This protocol takes many hours (days!) to run, so you might not want
   to run it on all the data the first time.  If you're using the
   example data, you can work with a subset of it by running this command
   instead of the `ln -fs` command above::

      cd ${HOME}/projects/eelpond
      mkdir -p extract
      for file in raw/*.fastq.gz
      do
          gunzip -c ${file} | head -400000 | gzip \
              > extract/${file%%.fastq.gz}.extract.fastq.gz
      done

   This will pull out the first 100,000 reads of each file (4 lines per record)
   and put them in the new ``${HOME}/projects/eelpond/extract`` directory.

OPTIONAL: Evaluate the quality of your files with FastQC
--------------------------------------------------------

If you installed Dropbox, we can use FastQC to look at the quality of your sequences::

   mkdir -p ${HOME}/Dropbox/fastqc
   cd ${HOME}/projects/eelpond/extract/
   fastqc --threads ${THREADS:-1} *.fastq.gz --outdir=${HOME}/Dropbox/fastqc

The output will be placed under the 'fastqc' directory in your Dropbox
on your local computer; look for the fastqc_report.html files, and
double click on them to load them into your browser.

Find the right Illumina adapters
--------------------------------

You'll need to know which Illumina sequencing adapters were used for
your library in order to trim them off. Below, we will use the TruSeq3-PE.fa
adapters::

   cd ${HOME}/projects/eelpond
   wget https://sources.debian.net/data/main/t/trimmomatic/0.32+dfsg-2/adapters/TruSeq3-PE.fa

.. note::

   You'll need to make sure these are the right adapters for your
   data.  If they are the right adapters, you should see that some of
   the reads are trimmed; if they're not, you won't see anything
   get trimmed.

Adapter trim each pair of files
-------------------------------

(From this point on, you may want to be running things inside of
screen, so that you detach and log out while it's running; see
:doc:`../amazon/using-screen` for more information.)

If you're following along using the Nematostella data, you should have a
bunch of files that look like this (use 'ls' to show them)::

   24HourB_GCCAAT_L002_R1_001.fastq.gz
                       ^^

Each file with an R1 in its name should have a matching file with an R2 --
these are the paired ends.

.. note::

   You'll need to replace <R1 FILE> and <R2 FILE>, below, with the
   names of your actual R1 and R2 files.  You'll also need to replace
   <SAMPLE NAME> with something that's unique to each pair of files.
   It doesn't really matter what, but you need to make sure it's different
   for each pair of files.

::
    
    # make a directory for this step
    mkdir ${HOME}/projects/eelpond/trimming_temp
    mkdir ${HOME}/projects/eelpond/trimmed

For *each* of these pairs, run the following ::
   
   cd ${HOME}/projects/eelpond/trimming_temp
   # run trimmomatic
   trimmomatic PE <R1 FILE> <R2 FILE> s1_pe s1_se s2_pe s2_se \
       ILLUMINACLIP:${HOME}/projects/eelpond/TruSeq3-PE.fa:2:30:10

   # interleave the remaining paired-end files
   interleave-reads.py s1_pe s2_pe | gzip -9c \
       > ../trimmed/<SAMPLE NAME>.pe.fq.gz

   # combine the single-ended files
   cat s1_se s2_se | gzip -9c > ../trimmed/<SAMPLE NAME>.se.fq.gz

   # clear the temporary files
   rm *

   # make it hard to delete the files you just created
   cd ../trimmed
   chmod u-w *

To get a basic idea of what's going on, please read the '#' comments
above, but, briefly, this set of commands:

* creates a temporary directory, 'trimming_temp'

* runs 'Trimmomatic' in that directory to trim off the adapters, and then
  puts remaining pairs (most of them!) in s1_pe and s2_pe, and any orphaned
  singletons in s1_se and s2_se.

* interleaves the paired ends and puts them back in the working directory

* combines the orphaned reads and puts them back in the working directory

At the end of this you will have new files ending in '.pe.fq.gz' and
'.se.fq.gz', representing the paired and orphaned quality trimmed
reads, respectively.

Automating things a bit
~~~~~~~~~~~~~~~~~~~~~~~

OK, once you've done this once or twice, it gets kind of tedious, doesn't it?
I've written a script to write these commands out automatically.  Run it
like so ::

   cd ${HOME}/projects/eelpond/raw
   python ${HOME}/src/khmer/sandbox/write-trimmomatic.py > trim.sh

Run this, and then look at 'trim.sh' using the 'more' command --::

   more trim.sh

.. ::

   echo 1-quality TRIM `date` >> ${HOME}/times.out

If it looks like it contains the right commands, you can run it by doing :
::

   bash trim.sh

.. note::

   This is a prime example of scripting to make your life much easier
   and less error prone.  Take a look at this file sometime --
   ``more ${HOME}/src/khmer/sandbox/write-trimmomatic.py`` -- to get
   some idea of how this works.



Quality trim each pair of files
-------------------------------

After you run this, you should have a bunch of '.pe.fq.gz' files and
a bunch of '.se.fq.gz' files.  The former are files that contain paired,
interleaved sequences; the latter contain single-ended, non-interleaved
sequences.

Next, for each of these files, run ::

   gunzip -c <filename> | fastq_quality_filter -Q33 -q 30 -p 50 | gzip -9c \
   > <filename>.qc.fq.gz

This uncompresses each file, removes poor-quality sequences, and then
recompresses it.  Note that (following `Short-read quality evaluation
<http://ged.msu.edu/angus/tutorials-2013/short-read-quality-evaluation.html>`_)
you can also trim to a specific length by putting in a ``fastx_trimmer
-Q33 -l 70 |`` into the mix.

If fastq_quality_filter complains about invalid quality scores, try
removing the -Q33 in the command; Illumina has blessed us with multiple
quality score encodings.

Automating this step
~~~~~~~~~~~~~~~~~~~~

.. ::

   echo 1-quality FILTER `date` >> ${HOME}/times.out

This step can be automated with a 'for' loop at the shell prompt.  Try :
::

   cd ${HOME}/projects/eelpond/
   mkdir filtered
   cd trimmed
   for file in *
   do
        echo working with ${file}
        newfile=${file%%.fq.gz}.qc.fq.gz
        gunzip -c ${file} | fastq_quality_filter -Q33 -q 30 -p 50 | gzip -9c \
            > ../filtered/${newfile}
   done

What this loop does is:

* for every file in our ``trimmed`` directory

* print out a message with the filename,

* construct a name 'newfile' that omits the trailing ``.fq.gz`` and add
  ``.qc.fq.gz``

* uncompresses the original file, passes it through fastq, recompresses it,
  and saves it to the ``filtered`` directory with the new filename.

.. parallel-version::

   ls * | parallel 'export file={}; \
   echo working with ${file};
   newfile=${file%%.fq.gz}.qc.fq.gz;
   gunzip -c ${file} | fastq_quality_filter -Q33 -q 30 -p 50 | gzip -9c \
   > ../filtered/${newfile}'

Extracting paired ends from the interleaved files
-------------------------------------------------

The fastx utilities that we're using to do quality trimming aren't
paired-end aware; they're removing individual sequences.  Because the
pe files are interleaved, this means that there may now be some orphaned
sequences in there.  Downstream, we will want to pay special attention
to the remaining paired sequences, so we want to separate out the pe
and se files.  How do we go about that?  Another script, of course!

The khmer script 'extract-paired-reads.py' does exactly that.
You run it on an interleaved file that may have some orphans, and it
produces .pe and .se files afterwards, containing pairs and orphans
respectively.

.. ::

   echo 1-quality EXTRACT `date` >> ${HOME}/times.out

To run it on all of the pe qc files, do :
::
   
   cd ${HOME}/projects/eelpond/
   mkdir filtered-pairs
   cd filtered-pairs
   for file in ../filtered/*.pe.qc.fq.gz
   do
      extract-paired-reads.py ${file}
   done

.. gnu-parallel-version:

   cd ${HOME}/projects/eelpond/
   mkdir filtered-pairs
   cd filtered-pairs
   ls ../filtered/*.pe.qc.fq.gz | parallel extract-paired-reads.py


.. ::

   echo 1-quality DONE `date` >> ${HOME}/times.out

Finishing up
------------

You should now have a whole mess of files. For example, in the Nematostella
data, for *each* of the original input files, you'll have::

   raw/24HourB_GCCAAT_L002_R1_001.fastq.gz 	             - the original data
   raw/24HourB_GCCAAT_L002_R2_001.fastq.gz
   trimmed/24HourB_GCCAAT_L002_R1_001.pe.fq.gz               - adapter trimmed pe
   trimmed/24HourB_GCCAAT_L002_R1_001.se.fq.gz		     - adapter trimmed orphans
   filtered/24HourB_GCCAAT_L002_R1_001.pe.qc.fq.gz           - FASTX filtered
   filtered/24HourB_GCCAAT_L002_R1_001.se.qc.fq.gz           - FASTX filtered orphans
   filtered-pairs/24HourB_GCCAAT_L002_R1_001.pe.qc.fq.gz.pe  - FASTX filtered PE
   filtered-pairs/24HourB_GCCAAT_L002_R1_001.pe.qc.fq.gz.se  - FASTX filtered SE

Yikes!  What to do?

Well, first, you can get rid of the original data.  You already have it on a
disk somewhere, right? ::
   
   rm raw/*
   rmdir raw

Next, you can get rid of the trimmed files, since you only want the QC files.
So ::

   rm -f trimmed/*
   rmdir trimmed

And, finally, you can toss the filtered files, because you've turned *those*
into ``*.pe`` and ``*.se`` files::
   
   rm filtered/*
   rmdir filtered

So now you should be left with only three files for each sample::

   filtered-pairs/24HourB_GCCAAT_L002_R1_001.pe.qc.fq.gz.pe   - FASTX filtered PE
   filtered-pairs/24HourB_GCCAAT_L002_R1_001.pe.qc.fq.gz.se   - FASTX filtered SE
   filtered-pairs/24HourB_GCCAAT_L002_R1_001.se.qc.fq.gz      - FASTX filtered orphans

Things to think about
~~~~~~~~~~~~~~~~~~~~~

Note that the filenames, while ugly, are conveniently structured with the
history of what you've done.  This is a good idea.

Also note that we've conveniently used a new directort for each step so that we
can remove unwanted files easily.  This is a good idea, too.

Renaming files
--------------

I'm a fan of keeping the files named somewhat sensibly, and keeping them
compressed.  Rename and compress the paired end files ::
   
   for file in filtered-pairs/*.pe
   do
      newfile=${file%%.pe.qc.fq.gz.pe}.pe.qc.fq
      mv $file $newfile
      gzip $newfile
   done

likewise with the single end files ::

   for file in filtered-pairs/*.se
   do
     otherfile=${file%%.pe.qc.fq.gz.se}.se.qc.fq.gz # the orphans
     gunzip -c ${otherfile} > combine
     cat ${file} >> combine
     gzip -c combine > ${otherfile} # now all the single reads together
     rm ${file} combine
   done


and finally, make the end product files read-only ::

   chmod u-w filtered-pairs/*

to make sure you don't accidentally delete something.

OPTIONAL: Evaluate the quality of your files with FastQC again
--------------------------------------------------------------

If you installed Dropbox, we can once again use FastQC to look at the
quality of your newly-trimmed sequences::

   mkdir -p ${HOME}/Dropbox/fastqc
   cd ${HOME}/projects/eelpond/filtered-pairs/
   fastqc --threads ${THREADS:-1} *.pe.qc.fq.gz \
       --outdir=${HOME}/Dropbox/fastqc

Again, the output will be placed under the 'fastqc' directory in your
Dropbox on your local computer; look for the fastqc_report.html files,
and double click on them to load them into your browser.

Saving the files
----------------

At this point, you should save these files, which will be used in two
ways: first, for assembly; and second, for mapping, to do quantitation
and ultimately comparative expression analysis.  You can save them by
doing this::

   du -sh ${HOME}/projects/eelpond/filtered-pairs

.. shell stop

This calculates the size of your data.

Now, create a volume of the given size (multiply by 1.1 to make sure you have
enough room, and then follow the instructions in :doc:`../amazon/index`.  Once
you've mounted it properly (I would suggest mounting it on ${HOME}/save
instead of ${HOME}/data!), then do ::

   rsync -av filtered-pairs ${HOME}/save

which will copy all of the files over from the ``filtered-pairs`` directory
onto the ``${HOME}/save`` disk.  Then ``umount ${HOME}/save`` and voila, you've
got a copy of the files!

Next stop: :doc:`2-diginorm`.

