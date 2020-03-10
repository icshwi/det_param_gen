import datetime
import os
import sys

# get global functions from reg_parse.py
import param_parse as r

def ctl_py_gen(json_data):
    print "hello"

    fout = open_txt_file(json_data);

    # Generate header
    print_head(json_data, fout)

    print_addr(json_data, fout)

####################################################################################################
### Python Helper Functions
### TODO: commonality with vhdl_entity_gen?
####################################################################################################

# create output text file for register map
def open_txt_file(data):
    fout_name = r.OUTPUT_DIR + data["space label"] + "_map.txt"
    fout = open(fout_name, "w")

    print("Generating text register map for Python slow control in file " + fout_name)

    return fout


def print_head(json_data, fout):
    r.text_out("# Register map generated at: " + datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S"), fout)
    r.text_out("# using: " + os.getcwd() + '/' + sys.argv[0], fout)
    r.text_out("# Register definition file: " + sys.argv[1], fout)
    r.text_out("# Project: " + json_data["project name"], fout)
    r.text_out("# Register space: " + json_data["space full name"], fout)
    r.text_out("", fout)

def print_addr(json_data, fout):

    addr_off = 0
    prefix = ""

    if "rings" in json_data:
        rings = int(json_data["rings"], 0)
        ring_label = 1
    else:
        rings = 1
        ring_label = 0

    if "nodes" in json_data:
        nodes = int(json_data["nodes"], 0)
        node_label = 1
    else:
        nodes = 1
        node_label = 0

    for i in range(rings):
        for j in range(nodes):
            if ring_label:
                prefix = "_" + str(i)
                addr_off = i * int(json_data["ring space"], 0)
                if node_label:
                    prefix += "_" + str(j)
                    addr_off += j * int(json_data["node space"], 0)

            for entry in json_data["register map"]:
                addr = int(vhdlhex_to_pythonhex(entry["addr"]), 0) + addr_off
                r.text_out(entry["label"] + prefix + " 0x" + format(addr, '08x') + " LW", fout)

def vhdlhex_to_pythonhex(string):
    var = "0x" + string[2:-1]
    return var