# get global functions from reg_parse.py
import param_parse as r

def python_gen(json_data):

    fout = open_txt_file(json_data)

    for entry in json_data["register map"]["items"]:
        # TODO: add other data types to JSON
        r.text_out(entry["addr"] + " " + entry["short name"] + " " + "LW", fout)

def open_txt_file(data):
    fout_name = data["space short name"] + ".txt"
    fout = open(fout_name, "w")

    print("Generating address map for Python in file " + fout_name)

    return fout