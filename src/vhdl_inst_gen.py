# VHDL functions for register parsing script
# Generates VHDL instantiation template from input json register map
# Steven Alcock, ESS Detector Group
# July 2019

import reg_parse as r
import vhdl_entity_gen as v

def vhdl_gen(json_data):
    fout = open_vho_file(json_data)

    sig_gen(json_data, fout)
    inst_gen(json_data, fout)

    fout.close()


def sig_gen(json_data, fout):

    r.text_out("-- Local signals for connecting register map defined in " + json_data["space short name"], fout)

    # TODO: improve
    #max_name = json_data["max prefix"] + json_data["max name"] + len(json_data["register map"]["suffix"])
    max_name = json_data["max prefix"] + json_data["max name"]
    for i in json_data["register map"]["items"]:
        v.vhdl_sig_dec(i, json_data["register map"]["prefix"], json_data["register map"]["suffix"], \
                       max_name, v.SL, fout)
    r.text_out("\n\n", fout)
        

def inst_gen(json_data, fout):

    r.text_out("-- Instantiation of register space defined in " + json_data["space short name"], fout)
    indent = 1
    space_name = json_data["space short name"]
    max_name = json_data["max name"] + json_data["max prefix"] + len("_out")
    r.text_out(r.tabs(indent) + space_name + "_0" + ": entity work." + space_name, fout)

    indent += 1

    keys = ["vhdl sys ports", "vhdl cmd ports", "register map"]

    for i in keys:
        for j in json_data[i]["items"]:
            comma = v.get_delim(i, keys, j, json_data[i]["items"], ",")
           
            r.text_out(r.tabs(indent) + \
                r.pad_str(v.get_port_name(json_data[i]["prefix"], j), max_name) + \
                    " => " + \
                    json_data[i]["prefix"] + \
                    j["short name"] + \
                    json_data[i]["suffix"] + \
                    comma, fout)

    indent -= 1
    r.text_out(r.tabs(indent) + ");", fout)


def open_vho_file(data):
    fout_name = data["space short name"] + ".vho"
    fout = open(fout_name, "w")

    print("Generating VHDL register entity code in file " + fout_name)

    return fout
