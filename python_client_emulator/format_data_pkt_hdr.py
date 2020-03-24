#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Nov  7 12:03:04 2019
 A simple command line calculator to format data packet headers.
 At command line type:
     
         python format_ring_data.py <nodeid> <numdatawrds> <numdatawrdswrtn>
         
         example: python format_data_pkt_hdr.py 3 4 2
         >>> 0x184004dc
         
@author: Harry Walton, RAL
"""

import sys

def main(): 
    
    NODEID_H_C = 31  
    NODEID_L_C = 27
    NUMDATAWRDS_H_C = 26  
    NUMDATAWRDS_L_C = 18  
    DPRSVD_H_C    = 17
    DPRSVD_L_C   = 17
    NUMDATAWRTN_H_C = 16;
    NUMDATAWRTN_L_C = 8;       
    HDRK_H_C  =  7;
    HDRK_L_C = 0;
    DATAHDRK_C = 0xDC; # K28.6 not comma 
    
    nodeid, numdatawrds, numdatawrdswrtn = get_args()

    #numdatawrds = 2**(NUMDATAWRDS_H_C - NUMDATAWRDS_L_C + 1)-1
    
    nodeid_str = format(nodeid, '0'+ str(NODEID_H_C - NODEID_L_C + 1) + 'b')
    numwrds_str = format(numdatawrds, '0'+ str(NUMDATAWRDS_H_C - NUMDATAWRDS_L_C + 1) + 'b')
    dprsvd_str = format(0, '0'+ str(DPRSVD_H_C  - DPRSVD_L_C  + 1) + 'b')
    numwrtn_str = format(numdatawrdswrtn, '0'+ str(NUMDATAWRTN_H_C - NUMDATAWRTN_L_C + 1) + 'b')
    hdr_str = format(DATAHDRK_C, '0'+ str(HDRK_H_C - HDRK_L_C + 1) + 'b')

    wrd = nodeid_str + numwrds_str + dprsvd_str + numwrtn_str + hdr_str 

    print(hex(int(wrd, 2)))
    return 


def get_args():
    if len(sys.argv) != 4:
        print ("ERROR Expected 3 input args : nodeid, numdatawrds, numdatawrdswrtn")
        sys.exit()
    else:
        nodeid, numdatawrds, numdatawrdswrtn = sys.argv[1],sys.argv[2],sys.argv[3]
    return int(nodeid), int(numdatawrds), int(numdatawrdswrtn)

if __name__== "__main__":
    main()       