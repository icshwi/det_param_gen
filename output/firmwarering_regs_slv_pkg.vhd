-- Register package generated at: 24/03/2020 15:25:18
-- using: /epics/iocs/cmds/pkt-mux-cmd/dgro_master/det_param_gen/src/param_parse.py
-- Register definition file: ../../param_def/
-- Project: Detector Group Readout Master
-- Register space: Ring Configuration Register Register Space(Slave)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package ring_regs_slv_pkg is


    -- todo: fix alignment
    type t_ring_regs_slv_ro is record
        PHASH : std_logic_vector(32-1 downto 0);
        VERS_SLV : std_logic_vector(32-1 downto 0);
        GIT_HASH_SLV_0 : std_logic_vector(32-1 downto 0);
        GIT_HASH_SLV_1 : std_logic_vector(32-1 downto 0);
        GIT_HASH_SLV_2 : std_logic_vector(32-1 downto 0);
        CW_L_SLV : std_logic_vector(32-1 downto 0);
        CCWL_SLV : std_logic_vector(32-1 downto 0);
        CSEL_SLV : std_logic_vector(32-1 downto 0);
        TMSP_SLV : std_logic_vector(32-1 downto 0);
    end record t_ring_regs_slv_ro;

    type t_ring_regs_slv_rw is record
        LPBK : std_logic_vector(32-1 downto 0);
        RVSR_SLV : std_logic_vector(32-1 downto 0);
        BRDY_SLV : std_logic_vector(32-1 downto 0);
        STME_SLV : std_logic_vector(32-1 downto 0);
        STBT_SLV : std_logic_vector(32-1 downto 0);
        STBD_SLV : std_logic_vector(32-1 downto 0);
        NDID_SLV : std_logic_vector(32-1 downto 0);
        SJA_TEST : std_logic_vector(32-1 downto 0);
    end record t_ring_regs_slv_rw;

    -- Define initialisation constants
    constant C_LPBK_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_PHASH_INIT : std_logic_vector(32-1 downto 0) := x"821134BD";
    constant C_VERS_SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000001";
    constant C_GIT_HASH_SLV_0_INIT : std_logic_vector(32-1 downto 0) := x"DEADBEEF";
    constant C_GIT_HASH_SLV_1_INIT : std_logic_vector(32-1 downto 0) := x"DEADBEEF";
    constant C_GIT_HASH_SLV_2_INIT : std_logic_vector(32-1 downto 0) := x"DEADBEEF";
    constant C_RVSR_SLV_INIT : std_logic_vector(32-1 downto 0) := x"FFFFFFFF";
    constant C_BRDY_SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_CW_L_SLV_INIT : std_logic_vector(32-1 downto 0) := x"DEADBAAD";
    constant C_CCWL_SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_STME_SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_STBT_SLV_INIT : std_logic_vector(32-1 downto 0) := x"FFFFFFFF";
    constant C_STBD_SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_CSEL_SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_NDID_SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TMSP_SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_SJA_TEST_INIT : std_logic_vector(32-1 downto 0) := x"00000000";

    -- Assign initialisation constants
    constant C_RING_REGS_SLV_RO : t_ring_regs_slv_ro := (
        PHASH => C_PHASH_INIT(32-1 downto 0),
        VERS_SLV => C_VERS_SLV_INIT(32-1 downto 0),
        GIT_HASH_SLV_0 => C_GIT_HASH_SLV_0_INIT(32-1 downto 0),
        GIT_HASH_SLV_1 => C_GIT_HASH_SLV_1_INIT(32-1 downto 0),
        GIT_HASH_SLV_2 => C_GIT_HASH_SLV_2_INIT(32-1 downto 0),
        CW_L_SLV => C_CW_L_SLV_INIT(32-1 downto 0),
        CCWL_SLV => C_CCWL_SLV_INIT(32-1 downto 0),
        CSEL_SLV => C_CSEL_SLV_INIT(32-1 downto 0),
        TMSP_SLV => C_TMSP_SLV_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants
    constant C_RING_REGS_SLV_RW : t_ring_regs_slv_rw := (
        LPBK => C_LPBK_INIT(32-1 downto 0),
        RVSR_SLV => C_RVSR_SLV_INIT(32-1 downto 0),
        BRDY_SLV => C_BRDY_SLV_INIT(32-1 downto 0),
        STME_SLV => C_STME_SLV_INIT(32-1 downto 0),
        STBT_SLV => C_STBT_SLV_INIT(32-1 downto 0),
        STBD_SLV => C_STBD_SLV_INIT(32-1 downto 0),
        NDID_SLV => C_NDID_SLV_INIT(32-1 downto 0),
        SJA_TEST => C_SJA_TEST_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants in case they are needed in multiple files
    -- Addresses are 32-bits: correct sizing implemented in .vhd files
    constant C_LPBK_ADDR : std_logic_vector(31 downto 0) := x"00000000";
    constant C_PHASH_ADDR : std_logic_vector(31 downto 0) := x"00000004";
    constant C_VERS_SLV_ADDR : std_logic_vector(31 downto 0) := x"00000008";
    constant C_GIT_HASH_SLV_0_ADDR : std_logic_vector(31 downto 0) := x"0000000c";
    constant C_GIT_HASH_SLV_1_ADDR : std_logic_vector(31 downto 0) := x"00000010";
    constant C_GIT_HASH_SLV_2_ADDR : std_logic_vector(31 downto 0) := x"00000014";
    constant C_RVSR_SLV_ADDR : std_logic_vector(31 downto 0) := x"00000018";
    constant C_BRDY_SLV_ADDR : std_logic_vector(31 downto 0) := x"0000001c";
    constant C_CW_L_SLV_ADDR : std_logic_vector(31 downto 0) := x"00000020";
    constant C_CCWL_SLV_ADDR : std_logic_vector(31 downto 0) := x"00000024";
    constant C_STME_SLV_ADDR : std_logic_vector(31 downto 0) := x"00000028";
    constant C_STBT_SLV_ADDR : std_logic_vector(31 downto 0) := x"0000002c";
    constant C_STBD_SLV_ADDR : std_logic_vector(31 downto 0) := x"00000030";
    constant C_CSEL_SLV_ADDR : std_logic_vector(31 downto 0) := x"00000034";
    constant C_NDID_SLV_ADDR : std_logic_vector(31 downto 0) := x"00000038";
    constant C_TMSP_SLV_ADDR : std_logic_vector(31 downto 0) := x"0000003c";
    constant C_SJA_TEST_ADDR : std_logic_vector(31 downto 0) := x"00000040";

end package;
