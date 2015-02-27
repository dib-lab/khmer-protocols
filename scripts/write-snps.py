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

def main(argv):
   try:
      opts, args = getopt.getopt(argv,"hi:o:",["ofile="])
   except getopt.GetoptError:
      print 'write-snps.py  -o <outputfile>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'write-snps.py  -o <outputfile>'
         sys.exit()
      elif opt in ("-o", "--ofile"):
         outfp = arg
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
   for r1 in filelist:
      print 'processing', r1, index
      lines = open(r1, "r" ).readlines()
      j=j+1 
      i=0
      lines = tuple(lines)
      while i < len(lines):
          rec=lines[i].split('\t')
          if lines[i][0] in '#':
                 i+=1
                 pass
          else:
               i+=1
               if str(rec[1]) in dic:
                          oldindex=dic.get(rec[1])
                          mat[oldindex][j]=1
               else: 
                          mat[index][0]=str(rec[1])
                          mat[index][j]=1
                          dic[str(rec[1])]=index
                          index+=1
   snps=index
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
   while itr1 <= snps:
          itr2=1 
          outfp.write(str(mat[itr1][0]).rstrip('\n')) 
          outfp.write(str(deli).rstrip('\n'))
          while itr2 <= 11: 
                  outfp.write(str(mat[itr1][itr2]).rstrip('\n'))
                  outfp.write(str(deli).rstrip('\n'))
                  itr2+=1 
          print >> outfp ,'\n' 
          itr1+=1 
   outfp.close()
if __name__ == '__main__':
    main(sys.argv[1:])
