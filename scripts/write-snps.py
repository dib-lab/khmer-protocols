#! /usr/bin/env python2
#
# This file is part of khmer, http://github.com/ged-lab/khmer`, and is
# Copyright (C) Michigan State University, 2009-2014. It is licensed under
# the three-clause BSD license; see doc/LICENSE.txt.
# Contact: khmer-project@idyll.org
# Author Sherine Awad
import sys, getopt
import glob
from collections import defaultdict
import numpy
import argparse

def main(argv):
    
   parser=argparse.ArgumentParser()
   parser.add_argument("outfile", help="Enter output file name") 
   args=parser.parse_args()
   outfp=args.outfile
   nones=0
   snps=0
   index=1
   vcfs=list()
   filelist = glob.glob('*.vcf')
   dic={}
   outfp=open(sys.argv[1], 'w') 
   j=0
   for every in filelist:
       name=every.split('.')
       vcf=name[0]
       vcfs.append(vcf)
   mat=numpy.zeros((2000000,len(vcfs)+2),int)
   indeces= []
   indeces.append('zero')
   for r1 in filelist:
      print 'processing', r1, index
      i=0
      j=j+1
      for line in open(r1):
        i=i+1 
        rec=line.split('\t')
        if line.startswith('#'):  
            continue 
                 
        else:
               ivalue=str(rec[0])+'-'+str(rec[1])
               if(ivalue in indeces):
                          oldindex=indeces.index(ivalue)
                          mat[oldindex][j]=1
               else: 
                          mat[index][j]=1
                          indeces.append(ivalue)
                          index+=1
   print len(indeces)
   deli=" "
   zero="0"
   one="1"
   outfp.write(str(' ').rstrip('\n'))
   outfp.write(str(deli).rstrip('\n'))
   for every in vcfs:
             outfp.write(str(every).rstrip('\n'))
             outfp.write(str(deli).rstrip('\n'))
   print >> outfp ,'\n'
   itr1=1
   while itr1 < len(indeces) :
          itr2=1 
          outfp.write(str(indeces[itr1]).rstrip('\n')) 
          outfp.write(str(deli).rstrip('\n'))
          while itr2 <= j: 
                  outfp.write(str(mat[itr1][itr2]).rstrip('\n'))
                  outfp.write(str(deli).rstrip('\n'))
                  itr2+=1 
          print >> outfp ,'\n' 
          itr1+=1 
   outfp.close()
if __name__ == '__main__':
    main(sys.argv[1:])
