import datetime
import math
import os
import sys

# get global functions from reg_parse.py
import reg_parse as r


def vhdl_gen(json_data):
    print("Parsing for vecs")

    fout = open_vhd_pkg_file(json_data);
    
    # Generate VHDL Package header
    print_head(json_data, fout)

    # Generate VHDL entity declaration
    vhdl_package_code(json_data, fout)

####################################################################################################
### VHDL Helper Functions
### TODO: commonality with vhdl_entity_gen?
####################################################################################################

# open input file, load json data for reading, and create output VHDL file
def open_vhd_pkg_file(data):
    fout_name = r.OUTPUT_DIR + data["space label"] + "_pkg.vhd"
    fout = open(fout_name, "w")

    print("Generating VHDL register package code in file " + fout_name)

    return fout


# Generate VHDL header
def print_head(json_data, fout):
    # metadata
    r.text_out("-- Register package generated at: " + datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S"), fout)
    r.text_out("-- using: " + os.getcwd() + '/' + sys.argv[0], fout)
    r.text_out("-- Register definition file: " + sys.argv[1], fout)
    r.text_out("-- Project: " + json_data["project name"], fout)
    r.text_out("-- Register space: " + json_data["space full name"], fout)
    r.text_out("", fout)
    # VHDL libraries 
    r.text_out("library IEEE;", fout)
    r.text_out("use IEEE.STD_LOGIC_1164.ALL;", fout)
    r.text_out("use IEEE.NUMERIC_STD.ALL;", fout)
    r.text_out("", fout)

def vhdl_package_code(json_data, fout):

    indent = 0
    r.text_out("package " + json_data["space label"] + "_pkg" " is", fout)
    indent += 1
    gen_types(indent, json_data, fout)
    vhdl_init_values(indent, json_data, fout)
    if "ro_pres" in json_data:
        vhdl_init_assign(indent, json_data, "RO", fout)
    vhdl_init_assign(indent, json_data, "RW", fout)
    vhdl_addr_assign(indent, json_data, fout)
    indent -= 1
    r.text_out("end package;", fout)

def gen_types(indent, json_data, fout):

    r.text_out("", fout)

    vec_set = set()
    for entry in json_data["register map"]:
        if "vec" in entry:
            vec_set.add((entry["vec"], entry["width"]))

    entry_dic = dict()
    for entry in vec_set:
        type_name = "t_arr" + entry[0].lstrip() + "x" + entry[1].lstrip()

        # define types in package
        r.text_out(r.tabs(indent) + "type " + type_name +
                   " is array (0 to " + entry[0] + "-1) of std_logic_vector(" +
                   entry[1] + "-1 downto 0);", fout)

        # create dictionary of type names for future use
        entry_dic[entry] = type_name

    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "-- todo: fix alignment", fout)

    if "ro_pres" in json_data:
        # create custom register type
        r.text_out(r.tabs(indent) + "type " + get_ro_t(json_data["space label"]) +
                   " is record", fout)
        indent += 1
        gen_records(indent, json_data, "RO", entry_dic, fout)
        indent -= 1
        r.text_out(r.tabs(indent) + "end record " + get_ro_t(json_data["space label"]) +
                   ";", fout)
        r.text_out("", fout)

    r.text_out(r.tabs(indent) + "type " + get_rw_t(json_data["space label"]) +
               " is record", fout)
    indent += 1
    gen_records(indent, json_data, "RW", entry_dic, fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end record " + get_rw_t(json_data["space label"]) +
               ";", fout)
    r.text_out("", fout)



def get_ro_t(label):
    t_ro = "t_" + label + "_ro"
    return t_ro

def get_rw_t(label):
    t_rw = "t_" + label + "_rw"
    return t_rw

def gen_records(indent, json_data, r_type, entry_dic, fout):
    vec_cnt = 1
    for entry in json_data["register map"]:
        if entry["type"] == r_type:
            if "vec" in entry:
                vec_tar = entry["vec"]
                if vec_cnt == 1 and vec_tar > 1:
                    label = entry["label"][:-2] + "xx"
                    r.text_out(r.tabs(indent) + label + " : " +
                               entry_dic[(entry["vec"], entry["width"])] + ";", fout)
                    vec_cnt += 1
                else:
                    if int(vec_tar) == int(vec_cnt):
                        vec_cnt = 1
                    else:
                        vec_cnt += 1
           
            else:
                r.text_out(r.tabs(indent) + entry["label"] + " : std_logic_vector(" +
                           entry["width"] + "-1 downto 0);", fout)


def vhdl_init_values(indent, json_data, fout):

    r.text_out(r.tabs(indent) + "-- Define initialisation constants", fout)
    for entry in json_data["register map"]:
        if "default" in entry:
            default = entry["default"]
        else:
            default = "(others => '0')"
        r.text_out(r.tabs(indent) + "constant C_" + entry["label"] + "_INIT : " +
                   "std_logic_vector(" + entry["width"] + "-1 downto 0) := " +
                   default + ";", fout)

    r.text_out("", fout)

def vhdl_init_assign(indent, json_data, r_type, fout):

    if r_type == "RO":
        type_label = get_ro_t(json_data["space label"])
    else:
        type_label = get_rw_t(json_data["space label"])

    r.text_out(r.tabs(indent) + "-- Assign initialisation constants", fout)
    r.text_out(r.tabs(indent) + "constant C_" + (json_data["space label"]).upper() + "_" + 
               r_type + " : " + type_label + " := (", fout)

    indent += 1

    vec_cnt = 1
    line = ""
    post_indent = 0
    for entry in json_data["register map"]:            
        if entry["type"] == r_type:
            vec_slice = "(" + entry["width"] + "-1 downto 0)"
            if line != "":
                r.text_out(line, fout)
            if "vec" in entry:
                vec_tar = entry["vec"]
                if vec_cnt == 1 and vec_tar > 1:
                    label = entry["label"][:-2] + "xx"
                    vec_cnt += 1
                    post_indent = 1
                    header   = label + " => (\n" + r.tabs(indent + post_indent)
                    trailer  = ","
                else:
                    if int(vec_cnt) == int(vec_tar):
                        vec_cnt  = 1
                        post_indent = (-1)
                        if vec_tar == 1:
                            header   = label + " => (\n" + r.tabs(indent + post_indent)
                        else:
                            header   = ""
                        operator = ""
                        trailer  = "\n" + r.tabs(indent + post_indent) + "),"
                    else:
                        vec_cnt  += 1
                        post_indent = 0
                        header   = ""
                        operator = ""
                        trailer  = ","

            else:
                post_indent = 0
                header   = entry["label"] + " => "
                operator = " =>"
                trailer  = ","

            line = r.tabs(indent) + header + "C_" + entry["label"] + "_INIT" + vec_slice + trailer
            indent += post_indent

    r.text_out(line[:-1], fout)
    indent -= 1
    r.text_out(r.tabs(indent) + ");", fout)
    r.text_out("", fout)

def vhdl_addr_assign(indent, json_data, fout):

    r.text_out(r.tabs(indent) + "-- Assign initialisation constants in case they are needed in multiple files", fout)
    r.text_out(r.tabs(indent) + "-- Addresses are 32-bits: correct sizing implemented in .vhd files", fout)

    vec_cnt = 1
    for entry in json_data["register map"]:
        r.text_out(r.tabs(indent) + "constant C_" + entry["label"] + "_ADDR : std_logic_vector(31 downto 0) := " + entry["addr"] + ";", fout)

    r.text_out("", fout)
