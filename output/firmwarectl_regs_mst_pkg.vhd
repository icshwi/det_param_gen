-- Register package generated at: 24/03/2020 15:25:18
-- using: /epics/iocs/cmds/pkt-mux-cmd/dgro_master/det_param_gen/src/param_parse.py
-- Register definition file: ../../param_def/
-- Project: Detector Group Readout Master
-- Register space: Packet Engine Configuration Register Register Space (Master)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package ctl_regs_mst_pkg is


    -- todo: fix alignment
    type t_ctl_regs_mst_ro is record
        PHASH : std_logic_vector(32-1 downto 0);
        device_dna_0 : std_logic_vector(32-1 downto 0);
        device_dna_1 : std_logic_vector(32-1 downto 0);
        device_dna_2 : std_logic_vector(32-1 downto 0);
        build_time : std_logic_vector(32-1 downto 0);
        git_hash_0 : std_logic_vector(32-1 downto 0);
        git_hash_1 : std_logic_vector(32-1 downto 0);
        git_hash_2 : std_logic_vector(32-1 downto 0);
    end record t_ctl_regs_mst_ro;

    type t_ctl_regs_mst_rw is record
        LPBK : std_logic_vector(32-1 downto 0);
        global_rst : std_logic_vector(32-1 downto 0);
    end record t_ctl_regs_mst_rw;

    -- Define initialisation constants
    constant C_LPBK_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_PHASH_INIT : std_logic_vector(32-1 downto 0) := x"821134BD";
    constant C_device_dna_0_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_device_dna_1_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_device_dna_2_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_build_time_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_git_hash_0_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_git_hash_1_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_git_hash_2_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_global_rst_INIT : std_logic_vector(32-1 downto 0) := x"00000000";

    -- Assign initialisation constants
    constant C_CTL_REGS_MST_RO : t_ctl_regs_mst_ro := (
        PHASH => C_PHASH_INIT(32-1 downto 0),
        device_dna_0 => C_device_dna_0_INIT(32-1 downto 0),
        device_dna_1 => C_device_dna_1_INIT(32-1 downto 0),
        device_dna_2 => C_device_dna_2_INIT(32-1 downto 0),
        build_time => C_build_time_INIT(32-1 downto 0),
        git_hash_0 => C_git_hash_0_INIT(32-1 downto 0),
        git_hash_1 => C_git_hash_1_INIT(32-1 downto 0),
        git_hash_2 => C_git_hash_2_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants
    constant C_CTL_REGS_MST_RW : t_ctl_regs_mst_rw := (
        LPBK => C_LPBK_INIT(32-1 downto 0),
        global_rst => C_global_rst_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants in case they are needed in multiple files
    -- Addresses are 32-bits: correct sizing implemented in .vhd files
    constant C_LPBK_ADDR : std_logic_vector(31 downto 0) := x"c0001000";
    constant C_PHASH_ADDR : std_logic_vector(31 downto 0) := x"c0001004";
    constant C_device_dna_0_ADDR : std_logic_vector(31 downto 0) := x"c0001008";
    constant C_device_dna_1_ADDR : std_logic_vector(31 downto 0) := x"c000100c";
    constant C_device_dna_2_ADDR : std_logic_vector(31 downto 0) := x"c0001010";
    constant C_build_time_ADDR : std_logic_vector(31 downto 0) := x"c0001014";
    constant C_git_hash_0_ADDR : std_logic_vector(31 downto 0) := x"c0001018";
    constant C_git_hash_1_ADDR : std_logic_vector(31 downto 0) := x"c000101c";
    constant C_git_hash_2_ADDR : std_logic_vector(31 downto 0) := x"c0001020";
    constant C_global_rst_ADDR : std_logic_vector(31 downto 0) := x"c0001024";

end package;
