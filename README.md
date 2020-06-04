## Directory Stucture ##

This git repo should be included as a submodule.


## Making a Change to Parameter Map ##

1. Open the parameter map file you need to
2. Make the change
3. commit the change to the repository. This is important as the git hash is mapped into the register map
4. go to /src and run parse_param.py ../../param_def/

## Parameter Map Keys ##

The parameter definition files contain a map which contains key value pairs that are parsed and used to generate VHDL and EPICS. Only the label and type keys are required.

| Key       |Description     |Example Values    | 
| ------------- |-------------|----- |
| label    | The label used for the parameter ||
| type   | One of the types in param_def.json     |"MAC"|
| default|The default value written into firmware    |  `"x\"feedf00d\""` |
| min|Used to set the minimum allowable value of PV  |  `1000` |
| max|Used to set the maximum allowable value of PV  |  `1000` |
| pini| Process on init. Default is dependend on parameter type, normally TRUE   |  `0` |
| scan| PV scan rate. Default is dependend on parameter type. Use EPICS formatting  |  `Passive` |

## Example Parameter File ##
```
{
    "project name"    : "Detector Group Readout Slave",
    "space full name" : "User Configuration Register Space (Slave)",
    "space label"     : "usr_params_slv",
    "addr bus width"  : "32",
    "address offset"  : "0x40000000",
    "rings"           : "12",
    "ring space"      : "0x10000000",
    "nodes"           : "24",
    "node space"      : "0x00800000",
    "parameter map"    : [
        {"label": "ro_test", "type": "RO",	"default": "x\"feedf00d\"", "pini": "0","scan":"Passive", "desc": "Read only test register - should read 0xfeedfood"},
        {"label": "rw_test", "type": "RW",  "default": "x\"babacede\"", "pini": "0", "desc": "Read/write test register - initial value is 0xbabcede"},
        {"label": "resetn",  "type": "RW",  "default": "x\"00000000\"", "pini": "0", "desc": "Active-low reset for slave test data generator."},
        {"label": "idles",   "type": "RW",  "default": "x\"0000000a\"", "pini": "0", "desc": "Idle clock cycles between packets produed by slave test data generator."}
    ]
}
```
