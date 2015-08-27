=============
4. Assembling
=============

At last!  All that filtering and diginorming is done, and we can get
down to the serious business of assembling.  Huzzah!


.. shell start

Install MEGAHIT
---------------

We've found that `the MEGAHIT assembler (Li et al., 2015)
<http://www.ncbi.nlm.nih.gov/pubmed/25609793>`__ is a good, fast,
low-memory assembler for metagenomes (and transcriptomes), with no
downsides for short read assembly.  You might look at `the SPAdes
assembler <http://bioinf.spbau.ru/spades>`__ if you want to
combine long reads.

MEGAHIT is primarily distributed
`via GitHub <https://github.com/voutcn/megahit>`__, and you can
find the latest release `here <https://github.com/voutcn/megahit/releases/latest>`__.  We'll be using v1.0.2
::

   cd ~/
   curl -L https://github.com/voutcn/megahit/archive/v1.0.2.tar.gz > megahit.tar.gz
   tar xzf megahit.tar.gz
   cd megahit*
   make -j 4
   export PATH=$PATH:${PWD}

Install QUAST
-------------

We also want to use the QUAST tool to get statistics for the assemblies;
let's install that
::

   cd ~/
   curl -L http://sourceforge.net/projects/quast/files/quast-3.0.tar.gz/download > quast-3.0.tar.gz
   tar xvf quast-3.0.tar.gz

Running MEGAHIT
---------------

To run MEGAHIT, we need to give it a list of paired-end files, together
with the file full of orphans
::

   cd /mnt/work
   PE_FILES=$(ls -1 *.pe.qc.kak.fq.gz | tr '\n' ',')
   megahit --12 ${PE_FILES%,} -r orphans.qc.kak.fq.gz

If everything works, you should see ``ALL DONE.`` with some other information
at the end.  If this command works::

   ls megahit_out/done

then your assembly completed, and your final contigs are in ``megahit_out/final.contigs.fa``.

Getting statistics for the assembly
-----------------------------------

To get some basic stats for the assemblies, run
::

    ~/quast-3.0/quast.py megahit_out/final.contigs.fa -o report

and then look at ``report/report.txt``::

   less report/report.txt

This will give you all of your basic assembly statistics, should you care :).

----

Next: :doc:`5-mapping-and-quantitation`.
