import sys
import json
from copy import copy

####################################################################################################
### File IO
####################################################################################################

# get name of json file for parsing
def get_file():
    reg_file = args.paramMap
    print("Parsing file: " + reg_file)
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
### Register Expansion from Parameter Map json data
####################################################################################################



####################################################################################################
### Register Address Generation from json data
####################################################################################################
def addr_gen(json_data):

    # generate loopback signal if necessary
    if LOOPBACK_EN == True:
        loopback_entry = {"label": "loopback", "type": "RW", "width": "32", "desc": "Loopback register"}
        json_data["register map"].insert(0, loopback_entry)    

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

