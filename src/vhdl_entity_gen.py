# VHDL functions for register parsing script
# Generates VHDL entity from input json register map
# Steven Alcock, ESS Detector Group
# July 2019

import datetime
import math
import os
import sys

# get global functions from reg_parse.py
import reg_parse as r
import vhdl_pkg_gen as v

GEN_PORT_RECORD = True

####################################################################################################
### VHDL File Generation
####################################################################################################

# Generate VHDL register code based on input json_data file
def vhdl_gen(json_data):

    fout = open_vhd_file(json_data);

    # Generate VHDL header
    print_head(json_data, fout)

    # Generate VHDL entity declaration
    vhdl_entity_code(json_data, fout)

    # Generate VHDL architecture declaration
    vhdl_arch_code(json_data, fout)

    fout.close()


# Generate VHDL entity declaration
def vhdl_entity_code(json_data, fout):

    indent = 1

    r.text_out("entity " + json_data["space label"] + " is", fout)
    r.text_out("generic (", fout)
    generic_intfc(indent, json_data, fout)
    r.text_out(");", fout)
    r.text_out("port (", fout)
    axi_port_intfc(indent, fout)
    reg_port_intfc(indent, json_data, fout)
    r.text_out(");", fout)
    r.text_out("end " + json_data["space label"] + ";", fout)

# Generate VHDL architecture
def vhdl_arch_code(json_data, fout):

    # Generate VHDL signal declarations
    vhdl_signal_code(json_data, fout)

    # Generate VHDL architecture body
    vhdl_body_code(json_data, fout)


# Generate VHDL signal declarations
def vhdl_signal_code(json_data, fout):

    # ignore length of prefix for signals
    #max_name = json_data["max name"]
 
    indent = 0
    arch_header(indent, json_data["space label"], fout)
    indent += 1
    const_sig_def(indent, json_data, fout)
    axi_sig_def(indent, fout)
    reg_sig_def(indent, json_data, fout)

    
# Generate VHDL architecture body
def vhdl_body_code(json_data, fout):

    # architecture begin
    indent = 0
    arch_begin(indent, fout)
    indent += 1
    default_assign(indent, fout)
    axi_write_infra(indent, fout)
    axi_write_regs(indent, fout, json_data)
    axi_read_infra(indent, fout)
    axi_read_regs(indent, fout, json_data)
    indent -= 1
    arch_end(indent, fout)

####################################################################################################
### VHDL Helper Functions
####################################################################################################

# create output VHDL file
def open_vhd_file(data):
    fout_name = r.OUTPUT_DIR + data["space label"] + ".vhd"
    fout = open(fout_name, "w")

    print("Generating VHDL register entity code in file " + fout_name)

    return fout

############################################################################################


# Generate VHDL header
def print_head(json_data, fout):
    # metadata
    r.text_out("-- Register map generated at: " + datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S"), fout)
    r.text_out("-- using: " + os.getcwd() + '/' + sys.argv[0], fout)
    r.text_out("-- Register definition file: " + sys.argv[1], fout)
    r.text_out("-- Project: " + json_data["project name"], fout)
    r.text_out("-- Register space: " + json_data["space full name"], fout)
    r.text_out("", fout)
    # VHDL libraries 
    r.text_out("library IEEE;", fout)
    r.text_out("use IEEE.STD_LOGIC_1164.ALL;", fout)
    r.text_out("use IEEE.NUMERIC_STD.ALL;", fout)
    #r.text_out("use work.common_pkg.fn_stdlv_pad;", fout)
    r.text_out("use work." + json_data["space label"] + "_pkg.all;", fout)
    if GEN_PORT_RECORD:
        r.text_out("use work.axi4lite_pkg.all;", fout)
    r.text_out("", fout)

### todo: auto alignment ###

def arch_header(indent, space_label, fout):
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "architecture behavioral of " + space_label + " is", fout)

def arch_begin(indent, fout):
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "begin", fout)

def arch_end(indent, fout):
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "end;", fout)

def generic_intfc(indent, json_data, fout):
    r.text_out(r.tabs(indent) + "C_AXI_ADDR_WIDTH : integer := " + json_data["addr bus width"] + ";", fout)
    r.text_out(r.tabs(indent) + "C_AXI_DATA_WIDTH : integer := " + json_data["data bus width"] + "", fout)

def reg_port_intfc(indent, json_data, fout):
    label = json_data["space label"]
    if "ro_pres" in json_data:
        r.text_out(r.tabs(indent) + "RO_REGS_IN     : in  " + v.get_ro_t(label) + ";", fout)
    r.text_out(r.tabs(indent) + "RW_REGS_OUT    : out " + v.get_rw_t(label) + "", fout)

def axi_port_intfc(indent, fout):
    r.text_out(r.tabs(indent) + "S_AXI_ACLK     : in  std_logic;", fout)
    r.text_out(r.tabs(indent) + "S_AXI_ARESETN  : in  std_logic;", fout)

    if GEN_PORT_RECORD:
        r.text_out(r.tabs(indent) + "S_AXI_SIGS_IN  : in  t_axi4lite_mosi;", fout)
        r.text_out(r.tabs(indent) + "S_AXI_SIGS_OUT : out t_axi4lite_miso;", fout)
    else:
        r.text_out(r.tabs(indent) + "S_AXI_AWADDR   : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);", fout)
        r.text_out(r.tabs(indent) + "S_AXI_AWPROT   : in  std_logic_vector(2 downto 0);", fout)
        r.text_out(r.tabs(indent) + "S_AXI_AWVALID  : in  std_logic;", fout)
        r.text_out(r.tabs(indent) + "S_AXI_AWREADY  : out std_logic;", fout)
        r.text_out(r.tabs(indent) + "S_AXI_WDATA    : in  std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);", fout)
        r.text_out(r.tabs(indent) + "S_AXI_WSTRB    : in  std_logic_vector((C_AXI_DATA_WIDTH/8)-1 downto 0);", fout)
        r.text_out(r.tabs(indent) + "S_AXI_WVALID   : in  std_logic;", fout)
        r.text_out(r.tabs(indent) + "S_AXI_WREADY   : out std_logic;", fout)
        r.text_out(r.tabs(indent) + "S_AXI_BRESP    : out std_logic_vector(1 downto 0);", fout)
        r.text_out(r.tabs(indent) + "S_AXI_BVALID   : out std_logic;", fout)
        r.text_out(r.tabs(indent) + "S_AXI_BREADY   : in  std_logic;", fout)
        r.text_out(r.tabs(indent) + "S_AXI_ARADDR   : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);", fout)
        r.text_out(r.tabs(indent) + "S_AXI_ARPROT   : in  std_logic_vector(2 downto 0);", fout)
        r.text_out(r.tabs(indent) + "S_AXI_ARVALID  : in  std_logic;", fout)
        r.text_out(r.tabs(indent) + "S_AXI_ARREADY  : out std_logic;", fout)
        r.text_out(r.tabs(indent) + "S_AXI_RDATA    : out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);", fout)
        r.text_out(r.tabs(indent) + "S_AXI_RRESP    : out std_logic_vector(1 downto 0);", fout)
        r.text_out(r.tabs(indent) + "S_AXI_RVALID   : out std_logic;", fout)
        r.text_out(r.tabs(indent) + "S_AXI_RREADY   : in  std_logic;", fout)

def const_sig_def(indent, json_data, fout):
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "constant C_EMPTY_STATUS : " +
                                "std_logic_vector(" + json_data["data bus width"] +
                                "-1 downto 0) := x\"ba_ad_ba_ad\";", fout)
    lsb = int(json_data["data bus width"])/32 + 1
    r.text_out(r.tabs(indent) + "-- formula used by Python script is C_AXI_DATA_WIDTH/2 + 1", fout)
    r.text_out(r.tabs(indent) + "-- not done directly in VHDL becuase generics can't be used in case statements", fout)
    r.text_out(r.tabs(indent) + "constant C_ADDR_LSB : integer := " + str(lsb) + ";", fout)
    
    num_regs = len(json_data["register map"])
    addr_width = str(int(math.ceil(math.log(num_regs, 2))) + 1 - 1) 
    json_data["addr opt width"] = addr_width
    r.text_out(r.tabs(indent) + "constant C_OPT_ADDR_BITS : integer := " + addr_width + ";", fout)
    r.text_out(r.tabs(indent) + "constant C_ADDR_MSB : integer := C_OPT_ADDR_BITS + C_ADDR_LSB;", fout)

def axi_sig_def(indent, fout):
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "-- internal AXI4LITE signals", fout)
    r.text_out(r.tabs(indent) + "signal axi_awaddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);", fout)
    r.text_out(r.tabs(indent) + "signal axi_awready  : std_logic;", fout)
    r.text_out(r.tabs(indent) + "signal axi_wready   : std_logic;", fout)
    r.text_out(r.tabs(indent) + "signal axi_bresp    : std_logic_vector(1 downto 0);", fout)
    r.text_out(r.tabs(indent) + "signal axi_bvalid   : std_logic;", fout)
    r.text_out(r.tabs(indent) + "signal axi_araddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);", fout)
    r.text_out(r.tabs(indent) + "signal axi_arready  : std_logic;", fout)
    r.text_out(r.tabs(indent) + "signal axi_rdata    : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);", fout)
    r.text_out(r.tabs(indent) + "signal axi_rdata_r  : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);", fout)
    r.text_out(r.tabs(indent) + "signal axi_rresp    : std_logic_vector(1 downto 0);", fout)
    r.text_out(r.tabs(indent) + "signal axi_rvalid   : std_logic;", fout)

def reg_sig_def(indent, json_data, fout):
    label = json_data["space label"]
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "-- internal register signals", fout)
    if "ro_pres" in json_data:
        r.text_out(r.tabs(indent) + "signal ro_regs      : " + v.get_ro_t(label) + ";", fout)
    r.text_out(r.tabs(indent) + "signal rw_regs      : " + v.get_rw_t(label) + ";", fout)
    r.text_out(r.tabs(indent) + "signal reg_rden     : std_logic;", fout)
    r.text_out(r.tabs(indent) + "signal reg_wren     : std_logic;", fout)
    r.text_out(r.tabs(indent) + "signal reg_dout     : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);", fout)
    r.text_out(r.tabs(indent) + "signal reg_byte_ind : integer;", fout)
    r.text_out(r.tabs(indent) + "signal reg_aw_en    : std_logic;", fout)

def default_assign(indent, fout):
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + get_axi_port("AWREADY", "OUT") + " <= axi_awready;", fout)
    r.text_out(r.tabs(indent) + get_axi_port("WREADY", "OUT") + "  <= axi_wready;", fout)
    r.text_out(r.tabs(indent) + get_axi_port("BRESP", "OUT") + "   <= axi_bresp;", fout)
    r.text_out(r.tabs(indent) + get_axi_port("BVALID", "OUT") + "  <= axi_bvalid;", fout)
    r.text_out(r.tabs(indent) + get_axi_port("ARREADY", "OUT") + " <= axi_arready;", fout)
    r.text_out(r.tabs(indent) + get_axi_port("RDATA", "OUT") + "   <= axi_rdata_r;", fout)
    r.text_out(r.tabs(indent) + get_axi_port("RRESP", "OUT") + "   <= axi_rresp;", fout)
    r.text_out(r.tabs(indent) + get_axi_port("RVALID", "OUT") + "  <= axi_rvalid;", fout)

def axi_write_infra(indent, fout):

    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "-- AXI Write infrastructure", fout)
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "RW_REGS_OUT <= rw_regs;", fout)
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "process(S_AXI_ACLK)", fout)
    r.text_out(r.tabs(indent) + "begin", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if rising_edge(S_AXI_ACLK) then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if S_AXI_ARESETN = '0' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_awready <= '0';", fout)
    r.text_out(r.tabs(indent) + "reg_aw_en   <= '1';", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if axi_awready = '0' and " + get_axi_port("AWVALID", "IN") +
    " = '1' and " + get_axi_port("WVALID", "IN") + " = '1' and reg_aw_en = '1' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_awready <= '1';", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "elsif " + get_axi_port("BREADY", "IN") + " = '1' and " +
    "axi_bvalid = '1' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "reg_aw_en   <= '1';", fout)
    r.text_out(r.tabs(indent) + "axi_awready <= '0';", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_awready <= '0';", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end process;", fout)
    
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "process(S_AXI_ACLK)", fout)
    r.text_out(r.tabs(indent) + "begin", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if rising_edge(S_AXI_ACLK) then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if S_AXI_ARESETN = '0' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_awaddr <= (others => '0');", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if axi_awready = '0' and " + get_axi_port("AWVALID", "IN") + 
    " = '1' and " + get_axi_port("WVALID", "IN") + " = '1' and reg_aw_en = '1' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_awaddr <= " + get_axi_port("AWADDR", "IN") + ";", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end process;", fout)

    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "process(S_AXI_ACLK)", fout)
    r.text_out(r.tabs(indent) + "begin", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if rising_edge(S_AXI_ACLK) then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if S_AXI_ARESETN = '0' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_wready <= '0';", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if axi_wready = '0' and " + get_axi_port("WVALID", "IN") + 
    " = '1' and " + get_axi_port("AWVALID", "IN") + " = '1' and reg_aw_en = '1' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_wready <= '1';", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_wready <= '0';", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end process;", fout)

    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "reg_wren <= axi_wready and " + get_axi_port("WVALID", "IN") + 
    " and axi_awready and " + get_axi_port("AWVALID", "IN") + ";", fout)

def axi_write_regs(indent, fout, json_data):
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "-- AXI Register Write Process", fout)
    r.text_out("", fout)

    r.text_out(r.tabs(indent) + "process(S_AXI_ACLK)", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "variable loc_addr : std_logic_vector(C_OPT_ADDR_BITS downto 0);", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "begin", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if rising_edge(S_AXI_ACLK) then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if S_AXI_ARESETN = '0' then", fout)
    indent += 1
    if "ro_pres" in json_data:
        r.text_out(r.tabs(indent) + "ro_regs <= RO_REGS_IN;", fout)
    r.text_out(r.tabs(indent) + "rw_regs <= C_" + json_data["space label"].upper() + "_RW;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    if "ro_pres" in json_data:
        r.text_out(r.tabs(indent) + "-- Register the external (engine etc.) values into the ro registers every cycle", fout)
        r.text_out(r.tabs(indent) + "ro_regs <= RO_REGS_IN;", fout)
    r.text_out(r.tabs(indent) + "loc_addr := axi_awaddr(C_ADDR_MSB downto C_ADDR_LSB);", fout)
    r.text_out(r.tabs(indent) + "if reg_wren = '1' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "-- read-only registers not included here", fout)
    r.text_out(r.tabs(indent) + "case loc_addr is", fout)
    indent += 1
    for entry in json_data["register map"]:
        if entry["type"] == "RW":
            r.text_out(r.tabs(indent) + "-- " + entry["addr"] + ", " + entry["desc"], fout)
            r.text_out(r.tabs(indent) + "when " + "C_" + entry["label"] + "_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>", fout)
            indent += 1
            r.text_out(r.tabs(indent) + "for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop", fout)
            indent += 1
            r.text_out(r.tabs(indent) + "if " + get_axi_port("WSTRB", "IN") + "(byte_index) = '1' then", fout)
            indent += 1
            if "vec" in entry:
                label = entry["label"][:-2] + "xx" + "(" + entry["label"][-2:] + ")"
            else:
                label = entry["label"]
            r.text_out(r.tabs(indent) + "rw_regs." + label +
                                        "(byte_index*8+7 downto byte_index*8) <= " +
                                        get_axi_port("WDATA", "IN") + "(byte_index*8+7 downto byte_index*8);", fout)
            indent -= 1
            r.text_out(r.tabs(indent) + "end if;", fout)
            indent -= 1
            r.text_out(r.tabs(indent) + "end loop;", fout)
            indent -= 1

    r.text_out(r.tabs(indent) + "when others => ", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "-- null", fout)

    indent -= 2
    r.text_out(r.tabs(indent) + "end case;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end process;", fout)

def axi_read_infra(indent, fout):

    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "-- AXI Read infrastructure", fout)
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "process(S_AXI_ACLK)", fout)
    r.text_out(r.tabs(indent) + "begin", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if rising_edge(S_AXI_ACLK) then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if S_AXI_ARESETN = '0' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_bvalid <= '0';", fout)
    r.text_out(r.tabs(indent) + "axi_bresp  <= \"00\"; --need to work more on the responses", fout)
    indent -= 1        
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if axi_awready = '1' and " + get_axi_port("AWVALID", "IN") +
    " = '1' and axi_wready = '1' and " + get_axi_port("WVALID", "IN") + " = '1' and axi_bvalid = '0' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_bvalid <= '1';", fout)
    r.text_out(r.tabs(indent) + "axi_bresp  <= \"00\";", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "elsif " + get_axi_port("BREADY", "IN") + " = '1' and axi_bvalid = '1' then -- check if bready is asserted while bvalid is high", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_bvalid <= '0';                             -- (there is a possibility that bready is always asserted high)", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end process;", fout)

    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "process(S_AXI_ACLK)", fout)
    r.text_out(r.tabs(indent) + "begin", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if rising_edge(S_AXI_ACLK) then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if S_AXI_ARESETN = '0' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_arready <= '0';", fout)
    r.text_out(r.tabs(indent) + "axi_araddr  <= (others => '1');", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if axi_arready = '0' and " + get_axi_port("ARVALID", "IN") + " = '1' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_arready <= '1';", fout)
    r.text_out(r.tabs(indent) + "axi_araddr  <= " + get_axi_port("ARADDR", "IN") + ";", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_arready <= '0';", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end process;", fout)

    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "process(S_AXI_ACLK)", fout)
    r.text_out(r.tabs(indent) + "begin", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if rising_edge(S_AXI_ACLK) then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if S_AXI_ARESETN = '0' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_rvalid <= '0';", fout)
    r.text_out(r.tabs(indent) + "axi_rresp  <= \"00\";", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if axi_arready = '1' and " + get_axi_port("ARVALID", "IN") +
    " = '1' and axi_rvalid = '0' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_rvalid <= '1';", fout)
    r.text_out(r.tabs(indent) + "axi_rresp  <= \"00\"; -- 'OKAY' response", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "elsif axi_rvalid = '1' and " + get_axi_port("RREADY", "IN") + " = '1' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_rvalid <= '0';", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end process;", fout)

    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "reg_rden <= axi_arready and " + get_axi_port("ARVALID", "IN") + 
    " and (not axi_rvalid);", fout)

    r.text_out("", fout)

    r.text_out(r.tabs(indent) + "process(S_AXI_ACLK) is", fout)
    r.text_out(r.tabs(indent) + "begin", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if rising_edge(S_AXI_ACLK) then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if S_AXI_ARESETN = '0' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_rdata_r <= (others => '0');", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "else", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "if reg_rden = '1' then", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_rdata_r <= axi_rdata;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end if;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end process;", fout)

def axi_read_regs(indent, fout, json_data):
    r.text_out("", fout)
    r.text_out(r.tabs(indent) + "-- AXI Register Read Process", fout)
    r.text_out("", fout)

    if "ro_pres" in json_data:
        r.text_out(r.tabs(indent) + "process(ro_regs, rw_regs, axi_araddr, S_AXI_ARESETN, reg_rden) is", fout)
    else:
        r.text_out(r.tabs(indent) + "process(rw_regs, axi_araddr, S_AXI_ARESETN, reg_rden) is", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "variable loc_addr :std_logic_vector(C_OPT_ADDR_BITS downto 0);", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "begin", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "-- Address decoding for reading registers", fout)
    r.text_out(r.tabs(indent) + "loc_addr := axi_araddr(C_ADDR_MSB downto C_ADDR_LSB);", fout)
    r.text_out(r.tabs(indent) + "case loc_addr is", fout)
    indent += 1
    for entry in json_data["register map"]:
        r.text_out(r.tabs(indent) + "-- " + entry["addr"] + ", " + entry["desc"], fout)
        r.text_out(r.tabs(indent) + "when " + "C_" + entry["label"] + "_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>", fout)
        indent += 1
        if "vec" in entry:
            label = entry["label"][:-2] + "xx" + "(" + entry["label"][-2:] + ")"
        else:
            label = entry["label"]
        if entry["type"] == "RO":
            r.text_out(r.tabs(indent) + "axi_rdata <= ro_regs." + label + ";", fout)
        else:
            r.text_out(r.tabs(indent) + "axi_rdata <= rw_regs." + label + ";", fout)
        indent -= 1
    r.text_out(r.tabs(indent) + "when others => ", fout)
    indent += 1
    r.text_out(r.tabs(indent) + "axi_rdata <= C_EMPTY_STATUS;", fout)
    indent -= 2
    r.text_out(r.tabs(indent) + "end case;", fout)
    indent -= 1
    r.text_out(r.tabs(indent) + "end process;", fout)


def get_axi_port(record, dir):
    if GEN_PORT_RECORD:
        port = "S_AXI_SIGS_" + dir + "." + record.lower()
    else:
        port = "S_AXI_" + record.upper()
    return port
