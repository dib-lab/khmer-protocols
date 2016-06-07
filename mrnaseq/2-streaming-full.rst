===========================================
2016-ep-streaming - Streaming, full dataset
===========================================

This is the same as 1-quality.rst in this repository, but the automatic data download is commented out because the full data set for this is mounted from the public amazon snapshot snap-f5a9dea7.

.. shell start

::

   sudo apt-get update && \
   sudo apt-get -y install screen git curl gcc make g++ python-dev unzip \
            default-jre pkg-config libncurses5-dev r-base-core r-cran-gplots \
            python-matplotlib python-pip python-virtualenv sysstat fastqc \
            trimmomatic bowtie samtools blast2
.. ::

   set -x
   set -e
   set -e pipefail

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
   git clone https://github.com/dib-lab/khmer.git
   cd khmer
   make install
   
Link in data from mounted volume.
::

   cd /mnt
   mkdir -p work
   cd work
   
   ln -fs /home/ubuntu/data/*.fastq.gz .


We can use FastQC to look at the quality of
your sequences::

   fastqc *.fastq.gz

::

   cd /mnt/work
   wget https://anonscm.debian.org/cgit/debian-med/trimmomatic.git/plain/adapters/TruSeq3-PE.fa

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
   
   echo 1-quality DONE `date` >> ${HOME}/times.out
   
   echo 1.5-interleave START `date` >> ${HOME}/times.out
   
   (for filename in *_R1_*.qc.fq.gz
   do
      base=$(basename $filename .qc.fq.gz)
      baseR2=${base/_R1_/_R2_}
      output=${base/_R1_/}.pe.qc.fq.gz

      interleave-reads.py ${base}.qc.fq.gz ${baseR2}.qc.fq.gz 
      echo 1.5-interleave DONE `date` >> ${HOME}/times.out

   done && zcat orphans.fq.gz) | \
      (echo 2-diginorm normalize1-pe `date` >> ${HOME}/times.out && \
      trim-low-abund.py -V -k 20 -Z 18 -C 2 - -o - -M 4e9 --diginorm \
      --diginorm-coverage=20 &&  \
      echo 2-diginorm normalize1-DONE `date` >> ${HOME}/times.out) | \
      (echo 3-extract START `date` >> ${HOME}/times.out && \
      extract-paired-reads.py --gzip  -p paired.gz -s single.gz && \
      echo 3-extract DONE `date` >> ${HOME}/times.out)
   
   
   echo 4-split-pairs START `date` >> ${HOME}/times.out
   split-paired-reads.py -1 left.fq -2 right.fq paired.gz
   gunzip -c single.gz >> left.fq
   echo 4-split-pairs DONE `date` >> ${HOME}/times.out

   
Installing Trinity
------------------
::

   source /home/ubuntu/work/bin/activate
   echo 3-big-assembly compileTrinity `date` >> ${HOME}/times.out

To install Trinity:
::
   
   cd ${HOME}
   
   wget https://github.com/trinityrnaseq/trinityrnaseq/archive/v2.0.4.tar.gz \
     -O trinity.tar.gz
   tar xzf trinity.tar.gz
   cd trinityrnaseq*/
   make |& tee trinity-build.log

Now we will be running Trinity:
::
   cd /mnt/work
   ${HOME}/trinity*/Trinity --left left.fq --right right.fq --seqType fq --max_memory 14G --CPU 2
   
   echo 3-big-assembly DONE `date` >> ${HOME}/times.out

.. shell stop
