# -*- coding: utf-8 -*-
# Orignal code by Steven Alcock (ESS) and Harry Walton (STFC).

#import serial
import binascii
import math
import logging
import sys
import time


LOG_FILE = 'log.txt'
LOG_FORMAT= logging.Formatter(\
  "%(asctime)s %(filename)s, %(lineno)d %(levelname)s %(message)s")
CONSOLE_FORMAT = logging.Formatter("%(levelname)s: %(message)s")
LOG_FILE_MODE = 'w'


logger = logging.getLogger()
if logger:
      [logger.removeHandler(handler) for handler in logger.handlers[:]]
logger.setLevel(logging.DEBUG)          
handler = logging.FileHandler(LOG_FILE, mode = LOG_FILE_MODE)           
handler.setFormatter(LOG_FORMAT)
handler.setLevel(logging.DEBUG)
logger.addHandler(handler)
consolehandler = logging.StreamHandler()
consolehandler.setFormatter(CONSOLE_FORMAT)
consolehandler.setLevel(logging.INFO)
logger.addHandler(consolehandler)

# Parse input script and coordinate the requested register reads and writes
# TODO: better error-handling for malformed input files
def cmd_interpreter(ser, const, mst_addr, slv_addr, script):

    logging.info("*****************  STARTING  *******************") 
    logging.debug("Script_file is %s", script)
    logging.debug("Const_file is %s", const)
    logging.debug("***********************************************")

        
    # default the base address to 0
    base_addr = 0
    seq_number = 0

    # open command script (this specifies the reads/writes to issue)
    script_path = script
    fpr = open(script_path, 'r')    
    
    # parse script and execute read/writes accordingly
    for line in fpr:

        logging.debug("Parsing %s", script) 
        logging.debug("Read line %s :", line[:-1])  #remove carriage return as loggin will append one
        word_arr = line.split(" ")

        # ignore commented lines
        if ("#" == word_arr[0][0]) or ('\n' == word_arr[0][0]):
            continue

        # define behaviour for pauses
        elif "PAUSE" == word_arr[1].rstrip():
            if (raw_input("Paused. Press a key. 'q' to quit") == 'q'):
                print("quitting...")
                sys.exit(0)
        
        # define behaviour for messages
        elif "MSG" == word_arr[1]:
            logging.info("%s", line[:-1])
            seq_number -= 1  # dont increment seq_number for messages
        
        # register writes
        elif "SET" == word_arr[1]:
            set(word_arr, ser, const, mst_addr, slv_addr, base_addr, seq_number)

        # special case for handling time-of-flight measurements
        elif "TSET" == word_arr[1]:
            set_cmd = "0 SET S " + word_arr[3] + " 0xCAFEBABE"
            #print set_cmd
            set(set_cmd.split(" "), ser, const, mst_addr, slv_addr, base_addr, seq_number)

            get_cmd = "0 GET M " + word_arr[4]
            #print get_cmd
            tx_time = get(get_cmd.split(" "), ser, const, mst_addr, slv_addr, base_addr, seq_number)
            #print tx_time[0]
            get_cmd = "0 GET M " + word_arr[5]
            #print get_cmd
            rx_time = get(get_cmd.split(" "), ser, const, mst_addr, slv_addr, base_addr, seq_number)
            #print rx_time[0]
            tof_calc = format((rx_time[0] - tx_time[0])/2, '08x')
            #print str((rx_time[0] - tx_time[0])/2)
            tof_cmd = "0 SET M TMOF 0x" + tof_calc
            print tof_cmd
            set(tof_cmd.split(" "), ser, const, mst_addr, slv_addr, base_addr, seq_number)                    
            # resend set_cmd
            set(set_cmd.split(" "), ser, const, mst_addr, slv_addr, base_addr, seq_number)            

        # register reads
        elif "GET" == word_arr[1]: 
            get(word_arr, ser, const, mst_addr, slv_addr, base_addr, seq_number)
        
        # Get with assert  (check read value against expectation)
        elif "AGET" == word_arr[1]:

            read_val = get(word_arr, ser, const, mst_addr, slv_addr, base_addr, seq_number)

            assert_val = -1
            if (word_arr[4][0:2] == "0x") or (word_arr[4][0:2] == "0X"):
                assert_val = int(word_arr[4],16)
            if assert_val != read_val[0]:
                logging.info("%s MISMATCH. AssertGet on address %s returned %s, expected %s", word_arr[0], word_arr[2], hex(read_val[0]), word_arr[4])
            else:
                logging.info("%s o.k." % word_arr[0])

        elif "PGET" == word_arr[1]:
            read_val[0] = ""
            if (word_arr[4][0:2] == "0x") or (word_arr[4][0:2] == "0X"):
                assert_val = int(word_arr[4],16)
            while assert_val != read_val[0]:
                read_val = get(word_arr, ser, const, mst_addr, slv_addr, base_addr, seq_number)
                time.sleep(1)

                
        # Increment sequence number for next command
        seq_number += 1
        seq_number = (seq_number)%256   # HGW added
        logging.debug("******** Sequence No.= %s", seq_number)

    logging.info("Finished")

        
def get_addr_file(loc_key, mst_addr, slv_addr):
    if loc_key == "M":
        addr_file = mst_addr
    elif loc_key == "S":
        addr_file = slv_addr
    else:
        logging.error("Please specify whether the register write is for the Master ('M') or a Slave ('S')")
        sys.exit() # todo: necessary? 
    logging.debug(addr_file)               
    return addr_file

# Generate flat 32-bit register value from decimal string
def data_parse(data_str):
    data_reg = [int(data_str, 10)]
    return data_reg

def hexdata_parse(data_str):
    data_reg = [int(data_str, 16)]
    return data_reg
       
# Handle register write protocol
def write(ser, const_file, addr, data, seq):
    
    # Track index number within write command
    tx_ind = 0
    rx_ind = 0
    pad = 0

    logging.debug("Setting write start address to %s", hex(addr))
    tx_pkt(ser, const_file, "ICS_HEADER", "ICS_WR_INIT", addr, pad, tx_ind, seq)
    tx_ind += 1
    rx_pkt(ser, const_file, "SLV_HEADER", "SLV_WR_INIT", 0, 0, rx_ind, seq)
    rx_ind += 1
    
    for reg in data:
        logging.debug("Writing data %s", hex(reg))
        tx_pkt(ser, const_file, "ICS_HEADER", "ICS_WR_DATA", pad, reg, tx_ind, seq)
        tx_ind += 1

    tx_pkt(ser, const_file, "ICS_HEADER", "ICS_WR_TERM", pad, pad, tx_ind, seq)
    rx_pkt(ser, const_file, "SLV_HEADER", "SLV_WR_TERM", 0, 0, rx_ind, seq)  
    

# Handle register read protocol
def read(ser, const_file, start_addr, end_addr, seq, tipe):

    # Track index number within write command
    tx_ind = 0
    rx_ind = 0
    pad = 0
    read_word = []
    logging.debug("Setting read start address to %s", hex(start_addr))
    tx_pkt(ser, const_file, "ICS_HEADER", "ICS_RD_INIT", start_addr, end_addr, tx_ind, seq)
    tx_ind += 1
    rx_pkt(ser, const_file, "SLV_HEADER", "SLV_RD_INIT", 0, 0, rx_ind, seq)
    rx_ind += 1
    
    for i in range (start_addr, end_addr+1):
        read_word.append(rx_pkt(ser, const_file, "SLV_HEADER", "SLV_RD_DATA", 0, 0, rx_ind, seq))
        rx_ind += 1

    tx_pkt(ser, const_file, "ICS_HEADER", "ICS_RD_TERM", pad, pad, tx_ind, seq) 
    rx_pkt(ser, const_file, "SLV_HEADER", "SLV_RD_TERM", 0, 0, rx_ind, seq)
    
    return read_word
    
    
# Handle received bytes from serial connection
def rx_pkt(ser, const_file, head, cmd, word1, word2, ind, seq):
    data = ser.read(16)
    #print binascii.hexlify(data)
#    global deleteme
#    if deleteme == 1 :
#        logging.info('rx_pkt called data=ser.read(16) with results data= ')
#        for i in data:
#            logging.info([ binascii.hexlify(i) ] )
        
    # If the full packet has been received, parse for errors
    if len(data) == 16:
        if data[15] != chksum_gen(data[0:15]):
           logging.error("Host received wrong checksum") 
            

        # TODO: make this more elegant
        elif (data[0] != (const_lookup(head, const_file))[0]) or (data[1] != (const_lookup(head, const_file))[1]):
            logging.error( "Host received unrecognised header: %s", binascii.hexlify(data[0:2]))
        elif (data[2] != (const_lookup(cmd, const_file))[0]) or (data[3] != (const_lookup(cmd, const_file))[1]):
            if (data[2] == (const_lookup("SLV_CHK_ERR", const_file))[0]) and (data[3] == (const_lookup("SLV_CHK_ERR", const_file))[1]):
                logging.error("Slave recevied bad checksum, data[2],[3] =") #data[2])
                print("data[2],data[3]=", data[2],data[3])
                
            elif (data[2] == (const_lookup("SLV_IND_ERR", const_file))[0]) and (data[3] == (const_lookup("SLV_IND_ERR", const_file))[1]):
                logging.error("Slave received bad index")
            else:
                logging.error("Host received wrong command")
        elif (ord(data[12]) != (ind >> 8) & 0xff) or (ord(data[13]) != (ind >> 0) & 0xff):
            logging.error("Wrong index")
        elif ord(data[14]) != seq:
            logging.error("Wrong sequence")
        # Read the data if appropriate
        elif cmd == "SLV_RD_DATA":
            read_val = 0
            for i in range (4, 8):
                read_val = read_val + (ord(data[i]) << 8*(7-i))
            return read_val
    else:
        logging.error("Not enough data received")

    
# Generate packet bytes and send them over serial connection
def tx_pkt(ser, const_file, head, cmd, pay1, pay2, ind, seq):
    head_bytes = const_lookup(head, const_file)
    cmd_bytes  = const_lookup(cmd, const_file)
    pay1_bytes = byte_conv(pay1, 4)
    pay2_bytes = byte_conv(pay2, 4)
    ind_bytes  = byte_conv(ind, 2)
    seq_byte   = byte_conv(seq, 1)
    wr_str     = (head_bytes + cmd_bytes + pay1_bytes + 
                  pay2_bytes + ind_bytes + seq_byte)
    chksum     = chksum_gen(wr_str)
    wr_str     += chksum
    ser.write(wr_str)

    
# Convert a word consisting of bytes into an array of chars
def byte_conv(word, bytes):
    byte_arr = [0] * bytes
    for i in range (0, bytes):
        byte_arr[i] = chr((word >> (8*(bytes-1-i))) & 0xff)
    return byte_arr
    
    
# Calculate simple modulo-8 additive checksum for byte string
def chksum_gen(str):
    sum = 0
    for i in str:
        sum += ord(i)
    sum = sum & 0xff
    sum = chr(sum)
    return sum
    
    
# Extract address value and data tipe from register name according to lookup file
def addr_lookup(reg_name, file):

    address = 0
    tipe = 0
    fpr = open(file, 'r')
    not_found = True
 
    for line in fpr:
        word_arr = line.split(" ")

        if word_arr[0] == reg_name:
            not_found = False
            address = int(word_arr[1], 0)
            tipe = word_arr[2].rstrip()
            break
    fpr.close()
    if (not_found):
            logging.info("!!! Couldn't fnd address of %s in %s", reg_name,file)
            sys.exit(0)
    return address, tipe
    
    
# Extract command constants from tipe name according to VHDL source definition file
def const_lookup(const_name, file):
    fpr = open(file, 'r')
    value = 0
    bytes = [0, 0]
    
    for line in fpr:
        find_var = line.find(const_name)
        if find_var > 0:
            find_var = line.find(":=")
            if find_var > 0:
                value = line[find_var+5: find_var+9]
                bytes[0] = chr(int(value[0:2], 16))  
                bytes[1] = chr(int(value[2:5], 16))
               
                
    fpr.close()
    return bytes

def set(word_arr, ser, const, mst_addr, slv_addr, base_addr, seq_number):
        # determine if the register is for the master or a slave
    addr_file = get_addr_file(word_arr[2], mst_addr, slv_addr)

    # Lookup address from address map file            
    addr, tipe = addr_lookup(word_arr[3], addr_file)
        
    if 0 == tipe:
        logging.error("Attempt to lookup  in %s, returned addr=  tipe= ", addr_file) #, (word_arr[2], address_file, addr, tipe) ) 
        
    # Extract data for different address types
    if "LW" == tipe:
        if (word_arr[4][0:2] == "0X") or (word_arr[4][0:2] == "0x"):  
            data = hexdata_parse(word_arr[4].rstrip())
        else:
            data = data_parse(word_arr[4].rstrip())
    else:
        logging.warning("Address-type not recognised - Check the log file, %s, for details.", LOG_FILE )
        
    logging.debug('Attempting write to %s = %s with %s', word_arr[2], hex(base_addr+addr), hex(data[0]))
    write(ser, const, base_addr + addr, data, seq_number)
 
def get(word_arr, ser, const, mst_addr, slv_addr, base_addr, seq_number):
        # determine if the register is for the master or a slave
    addr_file = get_addr_file(word_arr[2], mst_addr, slv_addr)

    # Lookup address from address map file
    addr, tipe = addr_lookup(word_arr[3].rstrip(), addr_file)    
    end_addr = addr # block transactions not implemented
      
    logging.info('Attempting read from %s = %s', word_arr[3].rstrip(), hex(base_addr+addr))
    read_val = read(ser, const, base_addr + addr, base_addr + end_addr, seq_number, tipe)
    logging.info("%s Read-value: %s", word_arr[0], hex(read_val[0]))
    return read_val

