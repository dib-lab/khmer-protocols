Variant calling
================ 

We are using Podar dataset from ... 

Install software
~~~~~~~~~~~~~~~~

You'll want an m1.large or m1.xlarge for this.

First, we need to install the `BWA aligner
<http://bio-bwa.sourceforge.net/>`__::

   cd /root
   wget -O bwa-0.7.5.tar.bz2 http://sourceforge.net/projects/bio-bwa/files/bwa-0.7.5a.tar.bz2/download

   tar xvfj bwa-0.7.5.tar.bz2
   cd bwa-0.7.5a
   make

   cp bwa /usr/local/bin

We also need a new version of `samtools <http://samtools.sourceforge.net/>`__::

   cd /root
   curl -O -L http://sourceforge.net/projects/samtools/files/samtools/0.1.19/samtools-0.1.19.tar.bz2
   tar xvfj samtools-0.1.19.tar.bz2
   cd samtools-0.1.19
   make
   cp samtools /usr/local/bin
   cp bcftools/bcftools /usr/local/bin
   cd misc/
   cp *.pl maq2sam-long maq2sam-short md5fa md5sum-lite wgsim /usr/local/bin/

Download data
=============

Download the reference genome and the resequencing reads::

   cd /mnt

   curl -O http://athyra.idyll.org/~mahmoud4/all.fa 

   curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR606/SRR606249/SRR606249_1.fastq.gz
   curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR606/SRR606249/SRR606249_2.fastq.gz


Do the mapping
~~~~~~~~~~~~~~

Now let's map all of the reads to the reference.  Start by indexing the
reference genome::

   cd /mnt

   bwa index ref.fa 

Now, do the mapping of the raw reads to the reference genome::


   bwa aln ref.fa SRR606249_1.fastq.gz  > SRR606249_1.sai
 
   bwa aln ref.fa SRR606249_2.fastq.gz  > SRR606249_2.sai


Make a SAM file (this would be done with 'samse' if these were single
reads)::

   bwa sampe ref.fa SRR606249_1.sai SRR606249_2.sai  SRR606249_1.fastq.gz SRR606249_2.fastq.gz> SRR606249.sam


This file contains all of the information about where each read hits
on the reference.

Next, index the reference genome with samtools::

   samtools faidx ref.fa

Convert the SAM into a BAM file::

   samtools import ref.fa.fai SRR606249.sam SRR606249.bam

Sort the BAM file::

   samtools sort SRR606249.bam SRR606249.sorted

And index the sorted BAM file::

   samtools index SRR606249.sorted.bam

At this point you can visualize with tview or Tablet.

'samtools tview' is a text interface that you use from the command
line; run it like so::

   samtools tview SRR606249.sorted.bam ref.fa

The '.'s are places where the reads align perfectly in the forward direction,
and the ','s are places where the reads align perfectly in the reverse
direction.  Mismatches are indicated as A, T, C, G, etc.

You can scroll around using left and right arrows; to go to a specific
coordinate, use 'g' and then type in the contig name and the position.
For example, type 'g' and then 'rel606:553093<ENTER>' to go to
position 553093 in the BAM file.

For the `Tablet viewer <http://bioinf.scri.ac.uk/tablet/>`__, click on
the link and get it installed on your local computer.  Then, start it
up as an application.  To open your alignments in Tablet, you'll need
three files on your local computer: ``ref.fa``, ``SRR606249.sorted.bam``,
and ``SRR606249.sorted.bam.bai``.  You can copy them over using Dropbox,
for example.

Calling SNPs
~~~~~~~~~~~~

You can use samtools to call SNPs like so::

   samtools mpileup -uD -f ref.fa SRR606249.sorted.bam | bcftools view -bvcg - > SRR606249.raw.bcf

(See the 'mpileup' docs `here <http://samtools.sourceforge.net/mpileup.shtml>`__.)

Now convert the BCF into VCF::

   bcftools view SRR606249.raw.bcf > SRR606249.vcf

You can check out the VCF file by using 'tail' to look at the bottom::

   tail *.vcf

To further analyze the VCF file, take a look at this IPython notebook: `hw5-variant-solutions.ipynb <http://nbviewer.ipython.org/github/beacon-center/2013-intro-computational-science/blob/master/hw5-files/hw5-variant-solutions.ipynb>`__.

Other resources
---------------

5 things to know about the samtools mpileup tool: http://massgenomics.org/2012/03/5-things-to-know-about-samtools-mpileup.html

VCF file format specification: http://www.1000genomes.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-41
