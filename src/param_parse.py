 # Register parsing script
# Steven Alcock, ESS Detector Group
# Generates VHDL, EPICS, Python, and documentation from common json register map
# July 2019

import sys
import json
from copy import copy

import vhdl_pkg_gen
import vhdl_entity_gen
#import vhdl_inst_gen
import ctl_py_gen
import subprocess
import os
from pathlib import Path
import argparse

#packages for documentation generation
import pandas as pd
from tabulate import tabulate
import pdfkit
from reportlab.platypus import SimpleDocTemplate, Image, Table
from reportlab.lib.pagesizes import letter
from reportlab.platypus import TableStyle
from reportlab.lib import colors
from reportlab.lib.units import cm



####################################################################################################
### Global parameters
####################################################################################################

USE_PARAM_MAP   = True
GEN_VHDL_PKG    = False
GEN_VHDL_ENTITY = False
GEN_VHDL_INST   = False
GEN_EPICS       = False
GEN_CTL_PY      = False
GEN_DOCS        = True

# print output to terminal
PRINT_SCREEN = False
# print output to relevant output file
WRITE_FILE = True

DEBUG =          False

####################################################################################################
### Main program function
####################################################################################################

def dir_path(path):
    if os.path.isdir(path):
        return path
    else:
        raise argparse.ArgumentTypeError("readable_dir:{path} is not a valid path")


def main():


    # run argument parser to determine the file paths we are going to work with
    parser = argparse.ArgumentParser(description = "Generate an all")
    parser.add_argument("p", metavar= "Parameter Description Path", type = dir_path, help = "Path to directory containing the parameter maps, default= ../../param_def/", default="../../param_def/")
    parser.add_argument("--d",metavar= "Parameter Definition File",  type = str,  help = "Path to parameter definition file(param_def.json)")
    parser.add_argument("--o", metavar= "Output Path",type = str, help = "Path to output directory")

    args = parser.parse_args()
    PARAM_DIR  = Path(args.p)

    if args.d is None:
        PARAM_DEF = Path(str(PARAM_DIR) + "/../det_param_gen/param_def.json")

        if os.path.isfile(PARAM_DEF):
            print("No Definition File specified, assuming default file structure")

        else:
            raise SystemExit("No Definition File specified, and can't find the param_def.json file at " + str(PARAM_DEF))
    else:
        PARAM_DEF  = Path(args.d)


    if args.o is None:
        OUTPUT_DIR = Path(str(PARAM_DIR) + "/../det_param_gen/output/")
        if os.path.isdir(OUTPUT_DIR):
            print("No Output Directory specified, assuming default file structure " + str(OUTPUT_DIR))

        else:
            raise SystemExit("No Output Directory specified, and can't find default output directory")
    else:
        OUTPUT_DIR  = Path(args.o)

    #go to the directory containing parameter definitions

    for filename in os.listdir(PARAM_DIR):

        if checkIsParam(filename):

            pathname = str(PARAM_DIR) + "/" + str(filename)
            json_file = parse_param(Path(pathname), PARAM_DEF, PARAM_DIR, OUTPUT_DIR)

            # get file pointers for input json and output VHDL files
            fin_json, json_data = json_parse(json_file)

            # generate addresses for each register in the register space
            addr_gen(json_data)

            if GEN_VHDL_PKG:
                vhdl_pkg_gen.vhdl_gen(json_data, OUTPUT_DIR,filename)

            # generate VHDL file
            if GEN_VHDL_ENTITY:
                vhdl_entity_gen.vhdl_gen(json_data, OUTPUT_DIR, filename)

                # don't try to generate an instantiation template without generating the entity first
                #if GEN_VHDL_INST:
                    #vhdl_inst_gen.vhdl_gen(json_data)

            # TODO generate EPICS (or new JSON for existing EPICS generation script, tbd)

            # generate Python slow control register map
            if GEN_CTL_PY:
                ctl_py_gen.ctl_py_gen(json_data, OUTPUT_DIR, filename)

            # TODO generate docs
            if GEN_DOCS:
                dummy_file(json_data)#need to run this to get a more readable data for further document generation
                doc_gen(json_data)#tidy text file, html file generation
                table_gen(json_data)#table in a text file generated
                pdf_gen(json_data)#table in a pdf generated

            # close files
            fin_json.close()


####################################################################################################
### File IO
####################################################################################################

#check if a file in the parameter directory
def checkIsParam(filename):

    if "param_map" and ".json" in str(filename):
        return True
    else:
        return False


# open input file, load json data for reading
def json_parse(json_file):
    fin = open(json_file, "r")
    data = json.load(fin)
    return fin, data


# write string to std_out or to the specified file
def text_out(string,fout):
    if WRITE_FILE:
        fout.write(string + '\n')
    if PRINT_SCREEN:
        print( string )


# def text_out(string, fout):
#     if WRITE_FILE:
#         fout.write(string + '\n')
#     if PRINT_SCREEN:
#         print(string)

# pad the string to arbitrary width
def pad_str(input, width):
    result = ("{:<"+ str(width) + "}").format(input)
    return result

# generate a string of spaces in multiples of four (soft tab)
def tabs(indent):
    return " " * 4 * indent


####################################################################################################
### Register Address Generation from json data
####################################################################################################
def parse_param(json_file, PARAM_DEF, PARAM_DIR, OUTPUT_DIR):

    # get file pointers for input json and output VHDL files
    fin_json, json_data = json_parse(json_file)

    print("parsing the file" + str(os.path.abspath(Path(json_file))))

    # Change space full name param to include "register"
    space_full_name = json_data["space full name"]
    split_string = space_full_name.split("Space")
    json_data["space full name"] =  split_string[0] + "Register Space" + split_string[1]



    json_data["space label"] =  json_data["space label"]
    if DEBUG:
        print("new label is: " + json_data["space label"])

    #Add the git hash of the current head as a parameter
    json_data = add_git_hash(json_data, PARAM_DIR)

    #Add a loopback register at the start of the parameter map
    json_data = add_loopback(json_data)

    # Expand parameters to generate the EPICS cmd file
    if GEN_EPICS:
        expand_param_to_cmd(json_data, PARAM_DEF, OUTPUT_DIR)

    # Expand parameters to registers based on type definition file
    json_data_reg = expand_param_to_reg(json_data, PARAM_DEF)

    # Create a new json file so that we can check that they are the same!
    reg_map_file = write_regmap(json_data_reg,OUTPUT_DIR)

    return reg_map_file

def expand_param_to_cmd(json_data, PARAM_DEF, OUTPUT_DIR):

    # Read the parameter definition file
    fin_json, param_data = json_parse(PARAM_DEF)
    param_def = param_data["def"]

    #create a temporary list
    param_list = []

    #initialise the base offset

    base_offset = json_data["address offset"]
    current_offset = int(base_offset, 16)

    if DEBUG:
        print("The Base offset is: " + str(current_offset))
    # populate that dictionary

    reg_idx = current_offset
    addr_idx = 0

    for param_entry in json_data["parameter map"]:

        if DEBUG:
            print("Current offset is:" + str(current_offset))

        #Determine the parameter type
        param_type = param_def[param_entry["type"]]

        #print("Param Type is : " + param_entry["type"])

        #Perform Vector expansion first (mirroring vhdl reg expansion)
        vec = 1
        if "vec" in param_entry:

            vec = int(param_entry["vec"])

        if DEBUG:
            print("vec is : " + str(vec))

        #Create the correct name





        for element in range(0,vec):



            #First we copy whats in the parameter map, making a new pv template file for each element of the vector
            pv_entry = []
            pv_entry = param_entry.copy() #https://www.programiz.com/python-programming/methods/list/copy
            pv_entry["label"] = json_data["space label"] + "_" + pv_entry["label"]
            offsets = []

            if "default" in param_entry:

                default = param_entry["default"]

                if "incr" in param_entry:

                    new_default = int(default[3:10],16)+element*(int(param_entry["incr"]))

                else:
                    new_default = int(default[3:10],16)

                pv_entry["default"] = str(new_default)

            #Next we determine the register offsets
            for reg in range(0,int(param_type["regs"])):

                current_offset = int(base_offset, 16) + addr_idx + element*4 + reg*vec*4     #reg_idx is the register that we last used at the previous parameter.
                                                            #*4 is important because each register is 4 bytes wide
                if DEBUG:
                    print(param_entry["label"] + " param_idx " + str(addr_idx) + " reg " + str(reg) + " vec " + str(element)  + " " + hex(current_offset))

                offsets.append(hex(current_offset))



            #Adding them as a new dictionary key called "offsets"
            pv_entry["offset"] = offsets


            #Expand to give the database type
            pv_entry["db_file"] = param_type["db_file"]

            #Add access type
            pv_entry["access"] = param_type["access"]

            #Determine the name to use
            if vec > 1 :
                pv_entry["label"] = pv_entry["label"].upper().replace("_","-") + "-" + format(element, "02d")
            else:
                pv_entry["label"] = pv_entry["label"].upper().replace("_","-")


            #Next we add the new entry to our temporary list
            param_list.append(pv_entry)

        addr_idx = current_offset - int(base_offset, 16) + 4 # increment the next address

    # Expand for rings and nodes



    if ("nodes" in json_data) and ("rings" in json_data):

        ring_list = []

        for ring in range(0,int(json_data["rings"])):

            for node in range(0,int(json_data["nodes"])):

                for param_entry in param_list:

                    #First we copy whats in the parameter map, making a new pv template file for each element of the vector
                    pv_entry = []
                    pv_entry = param_entry.copy() #https://www.programiz.com/python-programming/methods/list/copy

                    offsets = []

                    for offset in param_entry["offset"]:

                        current_offset = int(offset, 16) + ring*(int(json_data["ring space"], 16)) + node*(int(json_data["node space"], 16))

                        offsets.append(hex(current_offset))

                    #Adding them as a new dictionary key called "offsets"
                    pv_entry["offset"] = offsets

                    pv_entry["label"] = param_entry["label"] + "-R" + format(ring, "02d") + "-N" + format(node, "02d")

                    #Next we add the new entry to our temporary list
                    ring_list.append(pv_entry)

        param_list = ring_list

    param_map_file = str(OUTPUT_DIR) +"/EPICS/"+json_data["space label"]+"_cmd_map.json"

    print("writing param cmd map to: " + str(param_map_file))

    with open(Path(param_map_file), 'w') as outfile:
        json.dump(param_list, outfile, indent=4)


    #Now write the command file, leave macros to be expanded for the topology

        # Assumes that we only want one device connected to the IOC (unlike demonstrator)

    db_template = """dbLoadRecords("{db_file}", "SFX="{label}", SYS=$(SYS), DEV=$(DEV), COM=$(COM),{regs} PRO=$(PROTO)")\n"""
    return_str = ""
    return_str += "\n"

    for param_entry in param_list:


        # make the registers string

        regs = ""
        reg_idx = 0
        for reg in  param_entry["offset"]:
            regs += " REG" + str(reg_idx) + "=" + str(twos_complement(reg,32)) + ","
            reg_idx = reg_idx + 1

        if "default" in param_entry:
            regs += " DEFAULT=" + param_entry["default"] + ","

        if "pini" in param_entry:
            regs += " PINI=" + param_entry["pini"] + ","

        if "max" in param_entry:
            regs += " MAX=" + param_entry["max"] + ","

        if "min" in param_entry:
            regs += " MIN=" + param_entry["min"] + ","

        if "scan" in param_entry:
            regs += " SCAN=" + param_entry["scan"] + ","

        if DEBUG:
            print(regs)
        #create a new line
        return_str += db_template.format(db_file = param_entry["db_file"],label = param_entry["label"], regs = regs  )

    if DEBUG:
        print(return_str)


    ## ** TODO add the expansion for the different topologies ** ##

    # Write it to an output file
    cmd_filename = str(OUTPUT_DIR)+"/EPICS/"+json_data["space label"]+".cmd"

    print("writing cmd file to: " + str(cmd_filename))

    cmd_file = open(Path(cmd_filename), "w")
    cmd_file.write(return_str)
    cmd_file.close()



def expand_param_to_reg(json_data,PARAM_DEF):

    # Read the parameter definition file
    fin_json, param_data = json_parse(PARAM_DEF)
    param_def = param_data["def"]

    # Define a register description list
    reg_desc = ["Lower","Middle","Upper"]

    #create a temporary list
    reg_data = []

    # populate that dictionary
    for param_entry in json_data["parameter map"]:


        #Determine the parameter type
        param_type = param_def[param_entry["type"]]

        #Perform expansion, changing description as required
        for reg in range(1,int(param_type["regs"])+1):

            #First we copy whats in the parameter map
            reg_entry = []
            reg_entry = param_entry.copy() #https://www.programiz.com/python-programming/methods/list/copy

            #Then expand the descriptions and labels
            if reg == 2 and (int(param_type["regs"]) == 2):

                reg_entry["label"] = param_entry["label"] + "_" + str(reg-1)
                reg_entry["desc"] = "Upper 32 bits of "+ param_entry["desc"]

            elif int(param_type["regs"]) > 1:

                reg_entry["label"] = param_entry["label"] + "_" +  str(reg-1)
                reg_entry["desc"] = reg_desc[reg-1] +" 32 bits of "+ param_entry["desc"]

            #Determine the register type
            reg_entry["type"] = param_type["access"]

            #Add the width
            reg_entry["width"] = "32"

            #Add default values if not specified.
            #Defaults currently assume that a register going over mutliple regs has 0x0 default
            if "default" not in param_entry:
                reg_entry["default"] = "x\"00000000\""

            # increase the reg map index
            reg_data.append(reg_entry)

    #Add the temporary dictionary to the original
    json_data["parameter map"] = reg_data

    # Change the name of parameter map to register map
    json_data["register map"] = json_data.pop("parameter map")

    # Add "data bus width"  parameter always "32"
    json_data["data bus width"] = "32"

    return json_data



def add_git_hash(json_data, PARAM_DIR):


    # Add the current git hash as a parameter to json_data
    process = subprocess.Popen(['git', 'rev-parse', 'HEAD'], shell=False, stdout=subprocess.PIPE, cwd=str(PARAM_DIR) + "/../") # the change directory works only for defined directory structure!!
    git_head_hash = (process.communicate()[0].strip())[0:8]

    print("Current Git Hash of HEAD is: " + str(git_head_hash))

    reg_entry = {}
    reg_entry["label"] = "PHASH"
    reg_entry["type"] = "ROH" #so that it's displayed as a set of characters in EPICS
    reg_entry["default"] = "x\"" + git_head_hash.decode('utf-8').upper() + "\""
    space_label = json_data["space label"]
    reg_entry["desc"] = space_label + " Param Desc Git #"
    if "device" in json_data and json_data["device"] == "ring":
        reg_entry["pini"] = "0"
    reg_entry["scan"] = "Passive"
    json_data["parameter map"].insert(0,reg_entry) # add it to the start of the list

    return json_data

def add_loopback(json_data):

    reg_entry = {}
    reg_entry["label"] = "LPBK"
    reg_entry["type"] = "RW"
    reg_entry["desc"] = "Loopback Register"
    if "device" in json_data and json_data["device"] == "ring":
        reg_entry["pini"] = "0"
    reg_entry["scan"] = "Passive"
    json_data["parameter map"].insert(0,reg_entry) # add it to the start of the list

    return json_data

def write_regmap(json_data, OUTPUT_DIR):

    reg_map_file = str(OUTPUT_DIR)+"/register_map/"+json_data["space label"]+"_map.json"

    print("writing reg map to: " + str(reg_map_file))

    with open(Path(reg_map_file), 'w') as outfile:
        json.dump(json_data, outfile, indent=4)


    return reg_map_file

def addr_gen(json_data):



    # generate addresses for each register in the register space
    addr = int(json_data["address offset"], 0)
    tmp_arr = list()
    tmp_list = list()
    index = 0
    ro_type = False

    # pass over register map and expand vectorised registers into temporary list
    for entry in json_data["register map"]:
        if entry["type"] == "RO":
            ro_type = True;
        if "vec" in entry:
            for i in range(int(entry["vec"])):
                tmp_list.append(copy(entry))
            tmp_arr.append([index, tmp_list])
            tmp_list = list()

        index += 1

    if(ro_type == True):
        json_data["ro_pres"] = "True"

    # insert temporary list into register map
    index = 0
    vec_pos = 0
    for i in tmp_arr:
        vec_offset = 0

        # review
        vec_label = i[1][0]["label"]

        for j in i[1]:
            new_label = vec_label + format(vec_offset, '02d')
            j["label"] = new_label
            vec_offset += 1

        json_data["register map"][i[0] + vec_pos:i[0] + vec_pos] = i[1]
        vec_pos += vec_offset
        json_data["register map"].pop(i[0] + vec_pos)
        vec_pos -= 1


    # add addresses
    for entry in json_data["register map"]:
        entry["addr"] = "x\"" + (str('{:08x}'.format(addr))) + "\""
        addr += 4

def twos_complement(hexstr,bits):
    value = int(hexstr,16)
    if value & (1 << (bits-1)):
        value -= 1 << bits
    return value

def padhexa(s):
    return '0x' + s[2:].zfill(8)
####################################################################################################
### Documentation (may move to separate file)
####################################################################################################
#NEEDED TO GENERATE A TIDY TEXT FILE
def dummy_file(json_data):
    fout_name_dummy = json_data["space label"] + "_docs" + "_dummy" + ".txt"
    fout_dummy = open(fout_name_dummy, "w")
    text_out("label".upper() + "," +"address".upper()+ "," + "type".upper() + ","+"width".upper() + "," + "description".upper(),fout_dummy)
    for i in json_data["register map"]:
        text_out(i["label"]+','+i["addr"]+','+i["type"]+','+i["width"]+','+i["desc"],fout_dummy)
#GENERATING A TIDY TEXT FILE AND HTML FILE
def doc_gen(json_data):
    fout_name_dummy = json_data["space label"] + "_docs"+"_dummy" + ".txt"
    df = pd.read_csv(fout_name_dummy, sep=',')

    fout_name = json_data["space label"] + "_docs" + ".txt"
    fout = open(fout_name, "w")
    fout.write(df.to_string(header =True, index = False))
    print("Generating documentation in file " + fout_name)
    fin_name_html=json_data["space label"] + "_docs"+"_web" + ".html"
    pdff=json_data["space label"] + "_docs"+"_web" + ".pdf"
    web=df.to_html(fin_name_html)
    pdfkit.from_file(fin_name_html, pdff)
    #open(pdff,rb)
    print("Generating pdf documentation in file " + pdff)


#CREATING A LIST OF LIST (needed for table creation)
def create_list(json_data):
    list=[]
    list.append(["LABEL","ADDRESS","TYPE","WIDTH","DESCRIPTION"])
    for i in json_data["register map"]:
        list.append([i["label"],i["addr"],i["type"],i["width"],i["desc"]])

    return list

#CREATING A PDF DOCUMENT
def pdf_gen(json_data):
    pdf_file=json_data["space label"] + "_docs" + ".pdf"
    pdf = SimpleDocTemplate(pdf_file,Ppagesize=letter)
    #CREATING A TABLE
    table=Table(create_list(json_data))
    #creating table TableStyle
    style=TableStyle([('BACKGROUND',(0,0),(4,0),colors.steelblue),
    ('TEXTCOLOR',(0,0),(-1,0), colors.whitesmoke),
    ('ALIGN',(0,0),(-1,-1),"CENTER"),
    ('FONTSIZE',(0,0),(-1,0),13),
    ('BOTTOMPADDING',(0,0),(-1,0),12),
    ('BACKGROUND',(0,1),(-1,-1),colors.whitesmoke)])

    table.setStyle(style)
    rowNumb = len(create_list(json_data))
    for i in range(1, rowNumb):
        if i % 2 == 0:
            bc = colors.lightsteelblue
        else:
            bc = colors.whitesmoke
        ts = TableStyle(
        [('BACKGROUND', (0,i),(-1,i), bc)])
        table.setStyle(ts)
    #im=Image("logo.png",2.28 * inch,1.40*inch)
    table1=Table([[Image("logo.png",2.62 * cm,1.60*cm)," ","Register Map Documentation"]],colWidths=[3* cm,0.5*cm,11.5*cm,],
                    rowHeights=[1.62* cm])
    style1=TableStyle([('ALIGN',(0,0),(-1,0),"LEFT"),
    ('TEXTCOLOR',(0,0),(-1,0), colors.steelblue),
    ('FONTSIZE',(-1,0),(-1,0), 18),
    ('BOTTOMPADDING',(-1,0),(-1,0),24)
    ])
    table1.setStyle(style1)
    elements=[]
    elements.append(table1)
    elements.append(table)

    pdf.build(elements)
#CREATING A TABLE IN A TEXT FILE
def table_gen(json_data):
    fout_name_table= json_data["space label"] + "_docs" + "_table" + ".txt"
    fout_table = open(fout_name_table, "w")
    headers={"label" : "LABEL","type" : "TYPE","desc" : "DESCRIPTION", "scan" : "SCAN","width" : "WIDTH","default" : "DEFAULT ADDRESS","addr" : "ADDRESS","vec" : "VECTOR"}


    fout_table.write(tabulate(json_data["register map"],headers,tablefmt="fancy_grid"))
    print("Generating a table in file"+fout_name_table)




    # Display the register map in a nice way and write to file
    # TODO: replace this code with something better

############################################s########################################################
### main entry point
### (must be the last lines of this file, otherwise functions are not declared in order)
####################################################################################################

if __name__== "__main__":
    main()
