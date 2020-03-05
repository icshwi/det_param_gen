-- Register package generated at: 05/03/2020 11:30:26
-- using: /home/jgc87821/ess/harmonized/src/reg_parse.py
-- Register definition file: ../param_map/param_map_ctl.json
-- Project: Detector Group Readout Master
-- Register space: Packet Engine Configuration Register Register Space (Master)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package ctl_regs_mst_pkg is


    -- todo: fix alignment
    type t_ctl_regs_mst_ro is record
        device_dna_0 : std_logic_vector(32-1 downto 0);
        device_dna_1 : std_logic_vector(32-1 downto 0);
        device_dna_2 : std_logic_vector(32-1 downto 0);
        build_time : std_logic_vector(32-1 downto 0);
        git_hash_0 : std_logic_vector(32-1 downto 0);
        git_hash_1 : std_logic_vector(32-1 downto 0);
        git_hash_2 : std_logic_vector(32-1 downto 0);
        PHASH : std_logic_vector(32-1 downto 0);
    end record t_ctl_regs_mst_ro;

    type t_ctl_regs_mst_rw is record
        global_rst : std_logic_vector(32-1 downto 0);
    end record t_ctl_regs_mst_rw;

    -- Define initialisation constants
    constant C_device_dna_0_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_device_dna_1_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_device_dna_2_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_build_time_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_git_hash_0_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_git_hash_1_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_git_hash_2_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_global_rst_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_PHASH_INIT : std_logic_vector(32-1 downto 0) := x"25DF3D44";

    -- Assign initialisation constants
    constant C_CTL_REGS_MST_RO : t_ctl_regs_mst_ro := (
        device_dna_0 => C_device_dna_0_INIT(32-1 downto 0),
        device_dna_1 => C_device_dna_1_INIT(32-1 downto 0),
        device_dna_2 => C_device_dna_2_INIT(32-1 downto 0),
        build_time => C_build_time_INIT(32-1 downto 0),
        git_hash_0 => C_git_hash_0_INIT(32-1 downto 0),
        git_hash_1 => C_git_hash_1_INIT(32-1 downto 0),
        git_hash_2 => C_git_hash_2_INIT(32-1 downto 0),
        PHASH => C_PHASH_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants
    constant C_CTL_REGS_MST_RW : t_ctl_regs_mst_rw := (
        global_rst => C_global_rst_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants in case they are needed in multiple files
    -- Addresses are 32-bits: correct sizing implemented in .vhd files
    constant C_device_dna_0_ADDR : std_logic_vector(31 downto 0) := x"c0001000";
    constant C_device_dna_1_ADDR : std_logic_vector(31 downto 0) := x"c0001004";
    constant C_device_dna_2_ADDR : std_logic_vector(31 downto 0) := x"c0001008";
    constant C_build_time_ADDR : std_logic_vector(31 downto 0) := x"c000100c";
    constant C_git_hash_0_ADDR : std_logic_vector(31 downto 0) := x"c0001010";
    constant C_git_hash_1_ADDR : std_logic_vector(31 downto 0) := x"c0001014";
    constant C_git_hash_2_ADDR : std_logic_vector(31 downto 0) := x"c0001018";
    constant C_global_rst_ADDR : std_logic_vector(31 downto 0) := x"c000101c";
    constant C_PHASH_ADDR : std_logic_vector(31 downto 0) := x"c0001020";

end package;
