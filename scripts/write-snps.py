#! /usr/bin/env python2
#
# This file is part of khmer, http://github.com/ged-lab/khmer`, and is
# Copyright (C) Michigan State University, 2009-2014. It is licensed under
# the three-clause BSD license; see doc/LICENSE.txt.
# Contact: khmer-project@idyll.org
# Author Sherine Awad
import sys
import glob
from collections import defaultdict
import numpy

def main():
   snps=0
   vcfs=list()
   filelist = glob.glob('*.vcf')
   outfp=open("snps.txt",'w')
   j=0
   for every in filelist:
      name=every.split('.')
      vcf=name[0]
      vcfs.append(vcf)
   mat=numpy.empty((2000000,len(vcfs)+10))
   index=1
   count =0
   for r1 in filelist:
      print 'processing', r1
      lines = open(r1, "r" ).readlines()
      j=j+1 
      i=0
      lines = tuple(lines)
      dic={}
      headerlines=0
      while i < len(lines):
           if lines[i][0] in '#':
                   i=i+1
                   pass
           else: 
                   rec=lines[i].split('\t')
                   if rec[1] in dic.keys(): 
                           oldindex=dic.get(rec[1])
                           mat[oldindex][j]=1.0
                   else:
                           mat[index][j]=1.0
                           mat[index][0]=rec[1]
                           dic[rec[1]]=index
                           index=index+1
                   i= i+1
   test=dic.get('1509.0')
   print 'test value is ', test
   snps=index
   deli="    "
   zero="0"
   one="1"
   outfp.write(str(' ').rstrip('\n'))
   outfp.write(str(deli).rstrip('\n'))
   for every in vcfs:
             outfp.write(str(every).rstrip('\n'))
             outfp.write(str(deli).rstrip('\n'))
   print >> outfp ,'\n' 
   for itr1 in range (1,int(snps)): 
          outfp.write(str(mat[itr1][0]).rstrip('\n')) 
          outfp.write(str(deli).rstrip('\n'))
          for itr2  in range (1,len(vcfs)): 
              if(mat[itr1][itr2] == 1.0):
                   outfp.write(str(one).rstrip('\n'))
                   outfp.write(str(deli).rstrip('\n'))
              else:
                   outfp.write(str(zero).rstrip('\n'))
                   outfp.write(str(deli).rstrip('\n')) 
          print >> outfp ,'\n'  
   outfp.close()
if __name__ == '__main__':
    main()
