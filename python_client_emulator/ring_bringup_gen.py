# Script to generate the ring bring-up script
# If the register names in the address map change, they must be manually updated here too

# ring and number of nodes
# modify as required
# note that rings are logical (ie each ring has a clockwise and counter-clockwise direction)
# only the logical ring is specified (directionality handled in code)
# ie ring 0 uses xcvrs 0, 1; ring 11 uses xcvrs 22, 23
# tuple ordering is [ring id, number of nodes]
TOPOLOGY = [
    [ 0, 0],
    [ 1, 0],
    [ 2, 2], # ring on Trenz SFP+ FMC J4 and J5
    [ 3, 0], # ring on Trenz SFP+ FMC J6 and J7
    [ 4, 0],
    [ 5, 0],
    [ 6, 0],
    [ 7, 0],
    [ 8, 0],
    [ 9, 0],
    [10, 0],
    [11, 0]
]

# Direct output to file, console, or both
WRITE_FILE = True
PRINT_SCREEN = True

# Define ring-pair offsets:
# eg ring 0 correponds to GTY0 (lower) and GTY1 (upper); ring 1 is GTY2 (lower) and GTY3 (upper), etc
UPPER = 1
LOWER = 0

FSM_IDLE = 0
FSM_INTEGRITY = 1
FSM_RUN = 2

####################################################################################################
### Main program function
####################################################################################################

def main():

    # open file for writing output script
    fout = open_txt_file()

    # initialise variable for printing line numbers in script
    index = 0
    # print a title comment with the topology
    index = print_title(index, TOPOLOGY, fout)

    # remove all unused rings from topology
    cfg = get_cfg(TOPOLOGY)
    # parse topology constant and define a bitmask
    cfg_mask, cfg_mask_n = get_cfg_mask(TOPOLOGY)

    # reset the master
    index = rst_master(index, fout)
    # reset the transceivers
    index = rst_xcvrs(index, cfg_mask, cfg_mask_n, fout)

    # put the master tx fsms in idle state
    index = tx_idle(index, fout)
    # put the master rx fsms in idle state
    index = rx_idle(index, fout)

    # set up (at the moment fake) timestamps on the master
    # index = master_time(index, cfg_mask_n, fout)

    # bring up all rings defined in topology    
    for ring in cfg:

        # bring up all nodes on current ring
        for slv in range(ring[1]):
            # slvs are 1-indexed
            this_slv = slv + 1
            # bring up tx fsm
            index = tx_bringup(index, ring, LOWER, fout)
            # apply gtwiz_reset_rx_pll_and_datapath_in
            if slv == 0:
                index = gt_rx_reset(index, ring, LOWER, fout)
                # set up (currenyl fake) timestamps on the master. 
                # Do here, after reset, since rx reset will stop the rxusrclk
                # and hence the rxengine timestamp incrementing in currnet design.
                index = master_time(index, cfg_mask_n, fout)
            # wait for clocks to lock
            index = check_comms(index, ring, LOWER, fout)
            # set up slow control
            index = setup_sctl(index, ring, this_slv, LOWER, fout)
            # measure time of flight
            index = measure_tof(index, ring, this_slv, LOWER, fout)
            # reverse interconnect
            index = rev_intc(index, ring, slv, UPPER, fout)

        # push RNS into run state
        index = text_out(index, " SET M " + set_3reg_pair(ring, "RNS", FSM_RUN, FSM_RUN), fout)
        index = text_out(index, " MSG  Ring set up complete!", fout)

        # sanity check successful bring up
        index = get_all_nodes(index, cfg, fout)

        # santity check all timestamps
        index = get_all_times(index, cfg, fout)        

        # set up bulk data transmission
        index = bulkdata_init(index, ring, fout)

    # print success
    index = text_out(index, " MSG  System set up complete!", fout)


#######################################################################


# create output text file
def open_txt_file():
    #fout_name = r.OUTPUT_DIR + data["space label"] + "_map.txt"
    fout_name = "ring_bringup.txt"
    fout = open(fout_name, "w")
    return fout

# write text to file and/or console
def text_out(index, string, fout):
    if index != None:
        index_str = str(index)
    else:
        index_str = ""

    if WRITE_FILE:
        fout.write(index_str + string + '\n')
    if PRINT_SCREEN:
        print(index_str + string)

    if index != None:
        index += 1
    return index

# print a title comment with the topology
def print_title(index, topology, fout):
    text_out(None, "#", fout)
    msg_ring = "Ring number:     "
    msg_node = "Number of nodes: "
    for ring in topology:
        msg_ring += (format(ring[0], '02d') + " ")
        msg_node += (format(ring[1], '02d') + " ")

    index = text_out(index, " MSG  " + "*** Ring topology ***", fout)
    index = text_out(index, " MSG  " + msg_ring, fout)
    index = text_out(index, " MSG  " + msg_node, fout)

    return index

# remove all unused rings from topology
def get_cfg(topology):
    cfg = list()
    for ring in topology:
        if ring[1] != 0:
            cfg.append(ring)
    return cfg

# parse the topology and generate a bitmask showing the rings used
def get_cfg_mask(topology):
    mask = 0xFFFFFFFF   
    for ring in topology:
        if ring[1] != 0:
            bitmask = (1 << (2*ring[0]))
            mask = mask ^ (1 << (2*ring[0]))
            bitmask = (1 << (2*ring[0])+1)
            mask = mask ^ (1 << (2*ring[0]+1))

    mask_n = mask ^ 0xFFFFFFFF
    mask   = "0x" + format(mask, '08X')
    mask_n = "0x" + format(mask_n, '08X')

    return mask, mask_n

# reset the master
def rst_master(index, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Check board has emerged from reset", fout)
    index = text_out(index, " AGET M SRST 0x00000000", fout)
    return index

# reset the transceivers
def rst_xcvrs(index, cfg_mask, cfg_mask_n, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Power-down all CPLLS", fout)
    index = text_out(index, " SET M PDPL 0xFFFFFFFF", fout)
    index = text_out(index, " AGET M PDPL 0xFFFFFFFF", fout)

    index = text_out(index, " MSG  Power up CPPLs", fout)
    index = text_out(index, " SET M PDPL " + cfg_mask, fout)
    index = text_out(index, " AGET M PDPL " + cfg_mask, fout)

    index = text_out(index, " Reset all GTYs", fout)
    index = text_out(index, " SET M RGTY 0xFFFFFFFF", fout)
    index = text_out(index, " AGET M RGTY 0xFFFFFFFF", fout)

    index = text_out(index, " MSG  Power up GTYs", fout)
    index = text_out(index, " SET M RGTY " + cfg_mask, fout)
    index = text_out(index, " AGET M RGTY " + cfg_mask, fout)

    index = text_out(index, " MSG Check reset ctl sees GTYs out of rst", fout)
    index = text_out(index, " AGET M RTXD " + cfg_mask_n, fout)
    index = text_out(index, " AGET M RRXD " + cfg_mask_n, fout)

    return index

# put the master tx fsms in idle state
def tx_idle(index, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Put all TX engines into TXIDLEs state", fout)
    index = text_out(index, " SET M TNS00 0x00000000", fout)
    index = text_out(index, " SET M TNS01 0x00000000", fout)
    index = text_out(index, " SET M TNS02 0x00000000", fout)

    index = text_out(index, " MSG  Check status of all TX engines", fout)
    index = text_out(index, " AGET M TCS00 0x00000000", fout)
    index = text_out(index, " AGET M TCS01 0x00000000", fout)
    index = text_out(index, " AGET M TCS02 0x00000000", fout)

    index = text_out(index, " MSG  Check status of all TX engines", fout)
    index = text_out(index, " AGET M TS00 0xDEADBEEF", fout)
    index = text_out(index, " AGET M TS01 0xDEADBEEF", fout)
    index = text_out(index, " AGET M TS02 0xDEADBEEF", fout)

    return index 

# put the master rx fsms in idle state
def rx_idle(index, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Put all RX engines into RXIDLE state", fout)
    index = text_out(index, " SET M RNS00 0x00000000", fout)
    index = text_out(index, " SET M RNS01 0x00000000", fout)
    index = text_out(index, " SET M RNS02 0x00000000", fout)

    index = text_out(index, " MSG  Check status of all RX engines", fout)
    index = text_out(index, " AGET M RNS00 0x00000000", fout)
    index = text_out(index, " AGET M RNS01 0x00000000", fout)
    index = text_out(index, " AGET M RNS02 0x00000000", fout)

    return index

# set up (at the moment fake) timestamps on the master
def master_time(index, cfg_n, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Set up the master tyml (low bytes) register", fout)
    index = text_out(index, " SET M TYML 0x01010101", fout)
    index = text_out(index, " AGET M TYML 0x01010101", fout)
    
    index = text_out(index, " MSG  Set up the master tymh (high bytes) register", fout)
    index = text_out(index, " SET M TYMH 0xCAFE0000", fout)
    index = text_out(index, " AGET M TYMH 0xCAFE0000", fout)

    index = text_out(index, " MSG  Simulate arrival of a strobe", fout)
    index = text_out(index, " SET M LDST 0x00000001", fout)
    index = text_out(index, " SET M LDST 0x00000000", fout)

    index = text_out(index, " MSG  Check time is counting", fout)
    for i in range(24):
        if((int(cfg_n, 0) >> i) & 0x1) == 1:
            index = text_out(index, " GET M MS" + format(i, '02d'), fout)

    return index

# Forces master tx engine fsm to send 0x959595BC on ring
def tx_bringup(index, ring, xcvr, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Instruct relevant state machine to move to bring up", fout)

    tns = set_3reg_pair(ring, "TNS", "0", "1")
    tcs = set_3reg_pair(ring, "TCS", "0", "1")
    
    index = text_out(index, " SET M " + tns , fout)
    index = text_out(index, " AGET M " + tns, fout)

    return index

def gt_rx_reset(index, ring, xcvr, fout):
    text_out(None, '#', fout)
    index = text_out(index, " MSG  Restart clock correction by asserting rx pll and datapath reset ", fout)
    rsrx = 1 << (ring[0] + xcvr + 2) # + 3 to allow for offset of rings from 0
    index = text_out(index, " SET M RSRX " + format(rsrx, '#010x'), fout)
    index = text_out(index, " MSG  de-assert rx pll and datapath reset ", fout)
    index = text_out(index, " SET M RSRX" + " 0x00000000", fout)
    return index


# Forces master tx engine fsm to send 0x959595BC on ring
def tx_slowctl(index, ring, xcvr, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Instruct relevant state machine to move to slow control", fout)

    tns = set_3reg_pair(ring, "TNS", "0", "2")
    index = text_out(index, " SET M " + tns, fout)
    index = text_out(index, " AGET M " + tns, fout)
    rns = set_3reg_pair(ring, "RNS", "0", "2")
    index = text_out(index, " SET M " + rns, fout)
    index = text_out(index, " AGET M " + rns, fout)

    return index

# reads all expected node IDs on all rings to verify their presence
def get_all_nodes(index, cfg, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Check presence of all nodes:", fout)
    for ring in cfg:
        index = text_out(index, " MSG  Ring " + str(ring[0]), fout)
        for slv in range(ring[1]):
            index = text_out(index, " MSG  Node " + str(slv + 1), fout)
            index = text_out(index, " GET S NDID_SLV_" + str(ring[0]) + "_" + str(slv + 1), fout)
    return index

# reads all expected node timestamps on all rings to verify their presence
def get_all_times(index, cfg, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Check all timestamps:", fout)
    for ring in cfg:
        ms = "MS" + format(ring[0]*2, '02d')
        index = text_out(index, " GET M " + ms, fout)
        ms = "MS" + format(ring[0]*2+1, '02d')
        index = text_out(index, " GET M " + ms, fout)
        for slv in range(ring[1]):
            index = text_out(index, " GET S TMSP_SLV_" + str(ring[0]) + "_" + str(slv + 1), fout)
    return index

def bulkdata_init(index, ring, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Tell both rings to launch bulk data packets for all nodes", fout)

    tns_val = 0

    # for both transceivers
    for i in range(2):
        ring_inst = 2*ring[0] + i
        mn = "MN" + format(ring_inst, '02d')
        # bits 0x003F define the minimum node ID (hard-coded to Node 1 here)
        max_node = format(ring[1], '02x')
        # bits 0x3F00 defines the maximum node ID, as determined by the number of rings
        min_node = format(1, '02x')
        index = text_out(index, " SET M " + mn + " 0x0000" + max_node + min_node, fout)

        ring_inst += 1
        tns_val += (2 << (((ring_inst-1)%8)*4))

    # push Master fsm into bulk data state
    tns = set_3reg_pair(ring, "TNS", "2", "2")
    index = text_out(index, " SET M " + tns, fout)

    return index

# generate slave register address based on ring id and node id
def sctl_get(index, reg, ring, slv, fout):
    index = text_out(index, " GET S " + reg + "_" + str(ring) + "_" + str(slv), fout)
    return index

def sctl_set(index, reg, val, ring, slv, fout):
    index = text_out(index, " SET S " + reg + "_" + str(ring) + "_" + str(slv) + " " + val, fout)
    return index

# not used
# generate a PAUSE statement
def pause(index, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Pause to allow time for slave PLL to lock", fout)
    index = text_out(index, " PAUSE", fout)
    return index

# generate a PGET statement, which polls the specified register
# until it returns the correct value
# used here to check slave is returned 0x959595BC,
# proving it has locked to the received GT clock
def check_comms(index, ring, xcvr, fout):
    text_out(None, "#", fout)
    index = text_out(index, " MSG  Check relevant snapshot registers", fout)

    scaled_ring = 2*ring[0] + int(xcvr)
    ts = "TS" + format((scaled_ring), '02d')
    rs = "RS" + format((scaled_ring), '02d')

    index = text_out(index, " MSG  Both registers must be 0x959595BC", fout)
    index = text_out(index, " MSG  Polling " + ts + " and " + rs, fout)

    index = text_out(index, " PGET M " + ts + " 0x959595BC", fout)
    index = text_out(index, " PGET M " + rs + " 0x959595BC", fout)

    text_out(None, "#", fout)

    return index

# Test slow control and rename slave
def setup_sctl(index, ring, slv, xcvr, fout):
    text_out(None, "#", fout)

    index = text_out(index, " MSG  Set-up slow control on ring", fout)

    index = text_out(index, " MSG  Use lower xcvr for initial set up.", fout)
    index = text_out(index, " SET M TDIR 0x00000000", fout)
    #index = text_out(index, " MSG  Use upper xcvr for initial set up.", fout)
    #text_out(index, " SET M TDIR 0xFFFFFFFF", fout)

    index = tx_slowctl(index, ring, xcvr, fout)
    index = text_out(index, " MSG  Test slow control by reading VERS register", fout)
    index = sctl_get(index, "VERS_SLV", ring[0], 0, fout)

    index = text_out(index, " MSG  Also see which ring (CW/CCW) was selected for clock recovery", fout)
    index = sctl_get(index, "CSEL_SLV", ring[0], 0, fout)

    index = text_out(index, " MSG  Name slave", fout)
    index = sctl_set(index, "NDID_SLV", "0x" + format(slv, '08x'), ring[0], 0, fout)
    index = text_out(index, " MSG  Check newly named slave exists", fout)
    index = sctl_get(index, "VERS_SLV", ring[0], slv, fout)

    return index

def measure_tof(index, ring, slv, xcvr, fout):

    text_out(None, "#", fout)
    slv1 = "STME_SLV_" + str(ring[0]) + "_" + str(slv)
    rm = "RM" + format((ring[0]*2 + xcvr), '02d')
    tm = "TM" + format((ring[0]*2 + xcvr), '02d')
    arg = slv1 + " " + tm + " " + rm
    index = text_out(index, " MSG  Measure ToF using " + arg, fout)
    index = text_out(index, " TSET X " + arg, fout)

    return index


def rev_intc(index, ring, slv, xcvr, fout):

    text_out(None, "#", fout)

    if ring[1] == slv + 1:

        # todo: incorporate into tx_bringup function?
        index = text_out(index, " MSG  Close ring on final node.", fout)   
        index = text_out(index, " SET M " + set_3reg_pair(ring, "TNS", 1, 2), fout)
          # reset rx pll and datapath to reinitiate clock correction
        index = gt_rx_reset(index, ring, xcvr, fout)
        index = check_comms(index, [ring[0], ring[1]], xcvr, fout)

    index = text_out(index, " MSG  Can now reverse slave interconnect to forward traffic to next node", fout)
    # TODO - switch between 0x00000000 and 0xFFFFFFFF
    index = sctl_set(index, "RVSR_SLV", "0x00000000", ring[0], slv + 1, fout)
    index = text_out(index, " MSG  Node set up complete!", fout)

    return index


def set_3reg_pair(ring, reg, val1, val2):
    xcvr_lo = 2*ring[0]
    xcvr_hi = xcvr_lo + 1
    reg_lbl = reg + format(xcvr_lo/8, '02d')

    reg_val = "0x00000000"
    # +1 account for 0-offset
    val_pos = xcvr_lo%8 + 1
    reg_val = reg_val[:-val_pos] + str(val2) + reg_val[len(reg_val) - val_pos + 1:]
    val_pos = xcvr_hi%8 + 1
    reg_val = reg_val[:-val_pos] + str(val1) + reg_val[len(reg_val) - val_pos + 1:]

    return reg_lbl + " " + reg_val


if __name__== "__main__":
    main()

