## Directory Stucture ##

This git repo should be included as a submodule. As an example

implementation_def
│   ├── det_param_gen
│   │   ├── output
│   │   ├── README.md
│   │   └── src
│   ├── param_def.json
│   ├── param_map_ctl.json
│   ├── param_map_eng.json
│   ├── param_map_mst.json
│   ├── param_map_slv.json
│   └── param_map_usr.json


## Making a Change to Parameter Map ##

1. Open the parameter map file you need 
2. Make the change
3. commit the change to the repository. This is important as the git hash is mapped into the register map
4. go to /src and run run_all.sh

