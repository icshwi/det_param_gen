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

####################################################################################################
### Global parameters
####################################################################################################

USE_PARAM_MAP   = True
GEN_VHDL_PKG    = True
GEN_VHDL_ENTITY = True
GEN_VHDL_INST   = False
GEN_EPICS       = False
GEN_CTL_PY      = True
GEN_DOCS        = False

# print output to terminal
PRINT_SCREEN = False
# print output to relevant output file
WRITE_FILE = True


OUTPUT_DIR = "../output/firmware/"
PARAM_DEF = "../param_map/param_def.json"

####################################################################################################
### Main program function
####################################################################################################

def main():

    # get input json file name
    json_file = get_file()
    
    
    
    # if required generate the register map and then use this to create the other files
    if USE_PARAM_MAP:
         
        json_file = parse_param(json_file)     
        
    # get file pointers for input json and output VHDL files
    fin_json, json_data = json_parse(json_file)

    # generate addresses for each register in the register space
    addr_gen(json_data)

    if GEN_VHDL_PKG:
        vhdl_pkg_gen.vhdl_gen(json_data)

    # generate VHDL file
    if GEN_VHDL_ENTITY:
        vhdl_entity_gen.vhdl_gen(json_data)

        # don't try to generate an instaniation template without generating the entity first
        #if GEN_VHDL_INST:
            #vhdl_inst_gen.vhdl_gen(json_data)

    # TODO generate EPICS (or new JSON for existing EPICS generation script, tbd)

    # generate Python slow control register map
    if GEN_CTL_PY:
        ctl_py_gen.ctl_py_gen(json_data)

    # TODO generate docs
    #if GEN_DOCS:
        #doc_gen(json_data)

    # close files
    fin_json.close()


####################################################################################################
### File IO
####################################################################################################

# get name of json file for parsing
def get_file():
    if len(sys.argv) != 2:
        print "Error - please specify a json register map to parse."
        sys.exit()
    else:
        reg_file = sys.argv[1]
        print("Parsing file: " + reg_file)
        if USE_PARAM_MAP:
            print("Using parameter definition at: " + PARAM_DEF)
    return reg_file


# open input file, load json data for reading
def json_parse(json_file):
    fin = open(json_file, "r")
    data = json.load(fin)
    return fin, data


# write string to std_out or to the specified file
def text_out(string, fout):
    if WRITE_FILE:
        fout.write(string + '\n')
    if PRINT_SCREEN:
        print(string)

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
def parse_param(json_file):
    
    # get file pointers for input json and output VHDL files
    fin_json, json_data = json_parse(json_file)
    
    print("parsing the file" + json_file)
    
    # Change space full name param to include "register"
    space_full_name = json_data["space full name"]
    split_string = space_full_name.split("Space")
    json_data["space full name"] =  split_string[0] + "Register Space" + split_string[1]
    
    # Change space label to include "regs"
    space_label = json_data["space label"]
    split_string = space_label.split("_")
   
    json_data["space label"] =  split_string[0] + "_regs_" + split_string[2]
    print("new label is: " + json_data["space label"])
    # Expand parameters to registers based on type definition file
    json_data = expand_param(json_data)
    
    # Change the name of parameter map to register map
    json_data["register map"] = json_data.pop("parameter map")
	
    # Add "data bus width"  parameter always "32"
    json_data["data bus width"] = "32"
		
    # Create a new json file so that we can check that they are the same!
    reg_map_file = write_regmap(json_data)
    
    return reg_map_file

def expand_param(json_data):
    
    fin_json, param_data = json_parse(PARAM_DEF)
    param_def = param_data["def"]
    
    reg_desc = ["Lower","Middle","Upper"]
    
    reg_data = []
    
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
         
         
    json_data["parameter map"] = reg_data        
        
        
    return json_data

def write_regmap(json_data):
    
    reg_map_file = OUTPUT_DIR+"/../register_map/"+json_data["space label"]+"_map.json"

    print("writing reg map to: " + reg_map_file)

    with open(reg_map_file, 'w') as outfile:
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


####################################################################################################
### Documentation (may move to separate file)
####################################################################################################

def doc_gen(json_data):

    fout_name = json_data["space short name"] + "_docs" + ".txt"
    fout = open(fout_name, "w")

    print("Generating documentation in file " + fout_name)

    # Display the register map in a nice way and write to file
    # TODO: replace this code with something better
    text_out(pad_str("short name", 20) + "\t" + "address" + "\t" + "type" + "\t" + "width" + "\t" + "desc", fout)
    for i in json_data["register map"]["items"]:
        text_out(pad_str(i["short name"], 20) + "\t" + i["addr"] + "\t\t" + i["type"] + "\t\t" + i["width"] + "\t\t" + i["desc"], fout)


####################################################################################################
### main entry point
### (must be the last lines of this file, otherwise functions are not declared in order)
####################################################################################################

if __name__== "__main__":
    main()
