-- Register package generated at: 25/02/2020 15:23:07
-- using: /home/jgc87821/ess/hamonized/dgro_regs/src/reg_parse.py
-- Register definition file: ../../param_map/param_map_slv.json
-- Project: Detector Group Readout Master
-- Register space: Ring Configuration Register Register Space(Slave)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package ring_regs_slv_pkg is


    -- todo: fix alignment
    type t_ring_regs_slv_ro is record
        VERS-SLV : std_logic_vector(32-1 downto 0);
        GIT-HASH-SLV_0 : std_logic_vector(32-1 downto 0);
        GIT-HASH-SLV_1 : std_logic_vector(32-1 downto 0);
        GIT-HASH-SLV_2 : std_logic_vector(32-1 downto 0);
        CW-L-SLV : std_logic_vector(32-1 downto 0);
        CCWL-SLV : std_logic_vector(32-1 downto 0);
        CSEL-SLV : std_logic_vector(32-1 downto 0);
        TMSP-SLV : std_logic_vector(32-1 downto 0);
    end record t_ring_regs_slv_ro;

    type t_ring_regs_slv_rw is record
        RVSR-SLV : std_logic_vector(32-1 downto 0);
        BRDY-SLV : std_logic_vector(32-1 downto 0);
        STME-SLV : std_logic_vector(32-1 downto 0);
        STBT-SLV : std_logic_vector(32-1 downto 0);
        STBD-SLV : std_logic_vector(32-1 downto 0);
        NDID-SLV : std_logic_vector(32-1 downto 0);
        SJA-TEST : std_logic_vector(32-1 downto 0);
    end record t_ring_regs_slv_rw;

    -- Define initialisation constants
    constant C_VERS-SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000001";
    constant C_GIT-HASH-SLV_0_INIT : std_logic_vector(32-1 downto 0) := x"DEADBEEF";
    constant C_GIT-HASH-SLV_1_INIT : std_logic_vector(32-1 downto 0) := x"DEADBEEF";
    constant C_GIT-HASH-SLV_2_INIT : std_logic_vector(32-1 downto 0) := x"DEADBEEF";
    constant C_RVSR-SLV_INIT : std_logic_vector(32-1 downto 0) := x"FFFFFFFF";
    constant C_BRDY-SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_CW-L-SLV_INIT : std_logic_vector(32-1 downto 0) := x"DEADBAAD";
    constant C_CCWL-SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_STME-SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_STBT-SLV_INIT : std_logic_vector(32-1 downto 0) := x"FFFFFFFF";
    constant C_STBD-SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_CSEL-SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_NDID-SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TMSP-SLV_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_SJA-TEST_INIT : std_logic_vector(32-1 downto 0) := x"00000000";

    -- Assign initialisation constants
    constant C_RING_REGS_SLV_RO : t_ring_regs_slv_ro := (
        VERS-SLV => C_VERS-SLV_INIT(32-1 downto 0),
        GIT-HASH-SLV_0 => C_GIT-HASH-SLV_0_INIT(32-1 downto 0),
        GIT-HASH-SLV_1 => C_GIT-HASH-SLV_1_INIT(32-1 downto 0),
        GIT-HASH-SLV_2 => C_GIT-HASH-SLV_2_INIT(32-1 downto 0),
        CW-L-SLV => C_CW-L-SLV_INIT(32-1 downto 0),
        CCWL-SLV => C_CCWL-SLV_INIT(32-1 downto 0),
        CSEL-SLV => C_CSEL-SLV_INIT(32-1 downto 0),
        TMSP-SLV => C_TMSP-SLV_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants
    constant C_RING_REGS_SLV_RW : t_ring_regs_slv_rw := (
        RVSR-SLV => C_RVSR-SLV_INIT(32-1 downto 0),
        BRDY-SLV => C_BRDY-SLV_INIT(32-1 downto 0),
        STME-SLV => C_STME-SLV_INIT(32-1 downto 0),
        STBT-SLV => C_STBT-SLV_INIT(32-1 downto 0),
        STBD-SLV => C_STBD-SLV_INIT(32-1 downto 0),
        NDID-SLV => C_NDID-SLV_INIT(32-1 downto 0),
        SJA-TEST => C_SJA-TEST_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants in case they are needed in multiple files
    -- Addresses are 32-bits: correct sizing implemented in .vhd files
    constant C_VERS-SLV_ADDR : std_logic_vector(31 downto 0) := x"00000000";
    constant C_GIT-HASH-SLV_0_ADDR : std_logic_vector(31 downto 0) := x"00000004";
    constant C_GIT-HASH-SLV_1_ADDR : std_logic_vector(31 downto 0) := x"00000008";
    constant C_GIT-HASH-SLV_2_ADDR : std_logic_vector(31 downto 0) := x"0000000c";
    constant C_RVSR-SLV_ADDR : std_logic_vector(31 downto 0) := x"00000010";
    constant C_BRDY-SLV_ADDR : std_logic_vector(31 downto 0) := x"00000014";
    constant C_CW-L-SLV_ADDR : std_logic_vector(31 downto 0) := x"00000018";
    constant C_CCWL-SLV_ADDR : std_logic_vector(31 downto 0) := x"0000001c";
    constant C_STME-SLV_ADDR : std_logic_vector(31 downto 0) := x"00000020";
    constant C_STBT-SLV_ADDR : std_logic_vector(31 downto 0) := x"00000024";
    constant C_STBD-SLV_ADDR : std_logic_vector(31 downto 0) := x"00000028";
    constant C_CSEL-SLV_ADDR : std_logic_vector(31 downto 0) := x"0000002c";
    constant C_NDID-SLV_ADDR : std_logic_vector(31 downto 0) := x"00000030";
    constant C_TMSP-SLV_ADDR : std_logic_vector(31 downto 0) := x"00000034";
    constant C_SJA-TEST_ADDR : std_logic_vector(31 downto 0) := x"00000038";

end package;
