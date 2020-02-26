-- Register package generated at: 25/02/2020 13:22:40
-- using: /home/jgc87821/ess/hamonized/dgro_regs/src/reg_parse.py
-- Register definition file: ../../param_map/param_map_mst.json
-- Project: Detector Group Readout Master
-- Register space: Ring Configuration Register Space (Master)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package ring_regs_mst_pkg is

    type t_arr24x32 is array (0 to 24-1) of std_logic_vector(32-1 downto 0);
    type t_arr3x32 is array (0 to  3-1) of std_logic_vector(32-1 downto 0);

    -- todo: fix alignment
    type t_ring_regs_mst_ro is record
        GTPG : std_logic_vector(32-1 downto 0);
        RTXD : std_logic_vector(32-1 downto 0);
        RRXD : std_logic_vector(32-1 downto 0);
        RBAL : std_logic_vector(32-1 downto 0);
        RSxx : t_arr24x32;
        TSxx : t_arr24x32;
        TCSxx : t_arr3x32;
        RCSxx : t_arr3x32;
        RBWD : std_logic_vector(32-1 downto 0);
        MSxx : t_arr24x32;
        TMxx : t_arr24x32;
        RMxx : t_arr24x32;
    end record t_ring_regs_mst_ro;

    type t_ring_regs_mst_rw is record
        RGTY : std_logic_vector(32-1 downto 0);
        TNSxx : t_arr3x32;
        RNSxx : t_arr3x32;
        PDPL : std_logic_vector(32-1 downto 0);
        SRST : std_logic_vector(32-1 downto 0);
        RVSR : std_logic_vector(32-1 downto 0);
        TDIR : std_logic_vector(32-1 downto 0);
        RDIR : std_logic_vector(32-1 downto 0);
        TYM_0 : std_logic_vector(32-1 downto 0);
        TYM_1 : std_logic_vector(32-1 downto 0);
        LDST : std_logic_vector(32-1 downto 0);
        TMOF : std_logic_vector(32-1 downto 0);
        TPLS : std_logic_vector(32-1 downto 0);
        TDUR : std_logic_vector(32-1 downto 0);
        MNxx : t_arr24x32;
        PLEN : std_logic_vector(32-1 downto 0);
        RSRX : std_logic_vector(32-1 downto 0);
    end record t_ring_regs_mst_rw;

    -- Define initialisation constants
    constant C_GTPG_INIT : std_logic_vector(32-1 downto 0) := x"00FFFFFF";
    constant C_RGTY_INIT : std_logic_vector(32-1 downto 0) := x"00FFFFFF";
    constant C_RTXD_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RRXD_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RBAL_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS03_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS04_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS05_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS06_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS07_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS08_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS09_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS10_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS11_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS12_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS13_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS14_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS15_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS16_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS17_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS18_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS19_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS20_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS21_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS22_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RS23_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS03_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS04_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS05_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS06_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS07_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS08_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS09_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS10_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS11_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS12_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS13_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS14_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS15_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS16_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS17_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS18_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS19_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS20_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS21_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS22_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TS23_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TNS00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TNS01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TNS02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RNS00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RNS01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RNS02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TCS00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TCS01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TCS02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_PDPL_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RCS00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RCS01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RCS02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RBWD_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_SRST_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RVSR_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TDIR_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RDIR_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TYM_0_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TYM_1_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_LDST_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS03_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS04_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS05_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS06_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS07_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS08_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS09_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS10_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS11_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS12_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS13_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS14_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS15_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS16_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS17_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS18_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS19_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS20_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS21_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS22_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MS23_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM03_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM04_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM05_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM06_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM07_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM08_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM09_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM10_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM11_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM12_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM13_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM14_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM15_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM16_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM17_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM18_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM19_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM20_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM21_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM22_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TM23_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM03_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM04_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM05_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM06_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM07_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM08_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM09_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM10_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM11_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM12_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM13_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM14_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM15_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM16_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM17_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM18_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM19_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM20_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM21_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM22_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_RM23_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TMOF_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TPLS_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_TDUR_INIT : std_logic_vector(32-1 downto 0) := x"0000FFFF";
    constant C_MN00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN03_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN04_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN05_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN06_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN07_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN08_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN09_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN10_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN11_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN12_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN13_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN14_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN15_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN16_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN17_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN18_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN19_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN20_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN21_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN22_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_MN23_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_PLEN_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_RSRX_INIT : std_logic_vector(32-1 downto 0) := x"00000000";

    -- Assign initialisation constants
    constant C_RING_REGS_MST_RO : t_ring_regs_mst_ro := (
        GTPG => C_GTPG_INIT(32-1 downto 0),
        RTXD => C_RTXD_INIT(32-1 downto 0),
        RRXD => C_RRXD_INIT(32-1 downto 0),
        RBAL => C_RBAL_INIT(32-1 downto 0),
        RSxx => (
            C_RS00_INIT(32-1 downto 0),
            C_RS01_INIT(32-1 downto 0),
            C_RS02_INIT(32-1 downto 0),
            C_RS03_INIT(32-1 downto 0),
            C_RS04_INIT(32-1 downto 0),
            C_RS05_INIT(32-1 downto 0),
            C_RS06_INIT(32-1 downto 0),
            C_RS07_INIT(32-1 downto 0),
            C_RS08_INIT(32-1 downto 0),
            C_RS09_INIT(32-1 downto 0),
            C_RS10_INIT(32-1 downto 0),
            C_RS11_INIT(32-1 downto 0),
            C_RS12_INIT(32-1 downto 0),
            C_RS13_INIT(32-1 downto 0),
            C_RS14_INIT(32-1 downto 0),
            C_RS15_INIT(32-1 downto 0),
            C_RS16_INIT(32-1 downto 0),
            C_RS17_INIT(32-1 downto 0),
            C_RS18_INIT(32-1 downto 0),
            C_RS19_INIT(32-1 downto 0),
            C_RS20_INIT(32-1 downto 0),
            C_RS21_INIT(32-1 downto 0),
            C_RS22_INIT(32-1 downto 0),
            C_RS23_INIT(32-1 downto 0)
        ),
        TSxx => (
            C_TS00_INIT(32-1 downto 0),
            C_TS01_INIT(32-1 downto 0),
            C_TS02_INIT(32-1 downto 0),
            C_TS03_INIT(32-1 downto 0),
            C_TS04_INIT(32-1 downto 0),
            C_TS05_INIT(32-1 downto 0),
            C_TS06_INIT(32-1 downto 0),
            C_TS07_INIT(32-1 downto 0),
            C_TS08_INIT(32-1 downto 0),
            C_TS09_INIT(32-1 downto 0),
            C_TS10_INIT(32-1 downto 0),
            C_TS11_INIT(32-1 downto 0),
            C_TS12_INIT(32-1 downto 0),
            C_TS13_INIT(32-1 downto 0),
            C_TS14_INIT(32-1 downto 0),
            C_TS15_INIT(32-1 downto 0),
            C_TS16_INIT(32-1 downto 0),
            C_TS17_INIT(32-1 downto 0),
            C_TS18_INIT(32-1 downto 0),
            C_TS19_INIT(32-1 downto 0),
            C_TS20_INIT(32-1 downto 0),
            C_TS21_INIT(32-1 downto 0),
            C_TS22_INIT(32-1 downto 0),
            C_TS23_INIT(32-1 downto 0)
        ),
        TCSxx => (
            C_TCS00_INIT(32-1 downto 0),
            C_TCS01_INIT(32-1 downto 0),
            C_TCS02_INIT(32-1 downto 0)
        ),
        RCSxx => (
            C_RCS00_INIT(32-1 downto 0),
            C_RCS01_INIT(32-1 downto 0),
            C_RCS02_INIT(32-1 downto 0)
        ),
        RBWD => C_RBWD_INIT(32-1 downto 0),
        MSxx => (
            C_MS00_INIT(32-1 downto 0),
            C_MS01_INIT(32-1 downto 0),
            C_MS02_INIT(32-1 downto 0),
            C_MS03_INIT(32-1 downto 0),
            C_MS04_INIT(32-1 downto 0),
            C_MS05_INIT(32-1 downto 0),
            C_MS06_INIT(32-1 downto 0),
            C_MS07_INIT(32-1 downto 0),
            C_MS08_INIT(32-1 downto 0),
            C_MS09_INIT(32-1 downto 0),
            C_MS10_INIT(32-1 downto 0),
            C_MS11_INIT(32-1 downto 0),
            C_MS12_INIT(32-1 downto 0),
            C_MS13_INIT(32-1 downto 0),
            C_MS14_INIT(32-1 downto 0),
            C_MS15_INIT(32-1 downto 0),
            C_MS16_INIT(32-1 downto 0),
            C_MS17_INIT(32-1 downto 0),
            C_MS18_INIT(32-1 downto 0),
            C_MS19_INIT(32-1 downto 0),
            C_MS20_INIT(32-1 downto 0),
            C_MS21_INIT(32-1 downto 0),
            C_MS22_INIT(32-1 downto 0),
            C_MS23_INIT(32-1 downto 0)
        ),
        TMxx => (
            C_TM00_INIT(32-1 downto 0),
            C_TM01_INIT(32-1 downto 0),
            C_TM02_INIT(32-1 downto 0),
            C_TM03_INIT(32-1 downto 0),
            C_TM04_INIT(32-1 downto 0),
            C_TM05_INIT(32-1 downto 0),
            C_TM06_INIT(32-1 downto 0),
            C_TM07_INIT(32-1 downto 0),
            C_TM08_INIT(32-1 downto 0),
            C_TM09_INIT(32-1 downto 0),
            C_TM10_INIT(32-1 downto 0),
            C_TM11_INIT(32-1 downto 0),
            C_TM12_INIT(32-1 downto 0),
            C_TM13_INIT(32-1 downto 0),
            C_TM14_INIT(32-1 downto 0),
            C_TM15_INIT(32-1 downto 0),
            C_TM16_INIT(32-1 downto 0),
            C_TM17_INIT(32-1 downto 0),
            C_TM18_INIT(32-1 downto 0),
            C_TM19_INIT(32-1 downto 0),
            C_TM20_INIT(32-1 downto 0),
            C_TM21_INIT(32-1 downto 0),
            C_TM22_INIT(32-1 downto 0),
            C_TM23_INIT(32-1 downto 0)
        ),
        RMxx => (
            C_RM00_INIT(32-1 downto 0),
            C_RM01_INIT(32-1 downto 0),
            C_RM02_INIT(32-1 downto 0),
            C_RM03_INIT(32-1 downto 0),
            C_RM04_INIT(32-1 downto 0),
            C_RM05_INIT(32-1 downto 0),
            C_RM06_INIT(32-1 downto 0),
            C_RM07_INIT(32-1 downto 0),
            C_RM08_INIT(32-1 downto 0),
            C_RM09_INIT(32-1 downto 0),
            C_RM10_INIT(32-1 downto 0),
            C_RM11_INIT(32-1 downto 0),
            C_RM12_INIT(32-1 downto 0),
            C_RM13_INIT(32-1 downto 0),
            C_RM14_INIT(32-1 downto 0),
            C_RM15_INIT(32-1 downto 0),
            C_RM16_INIT(32-1 downto 0),
            C_RM17_INIT(32-1 downto 0),
            C_RM18_INIT(32-1 downto 0),
            C_RM19_INIT(32-1 downto 0),
            C_RM20_INIT(32-1 downto 0),
            C_RM21_INIT(32-1 downto 0),
            C_RM22_INIT(32-1 downto 0),
            C_RM23_INIT(32-1 downto 0)
        )
    );

    -- Assign initialisation constants
    constant C_RING_REGS_MST_RW : t_ring_regs_mst_rw := (
        RGTY => C_RGTY_INIT(32-1 downto 0),
        TNSxx => (
            C_TNS00_INIT(32-1 downto 0),
            C_TNS01_INIT(32-1 downto 0),
            C_TNS02_INIT(32-1 downto 0)
        ),
        RNSxx => (
            C_RNS00_INIT(32-1 downto 0),
            C_RNS01_INIT(32-1 downto 0),
            C_RNS02_INIT(32-1 downto 0)
        ),
        PDPL => C_PDPL_INIT(32-1 downto 0),
        SRST => C_SRST_INIT(32-1 downto 0),
        RVSR => C_RVSR_INIT(32-1 downto 0),
        TDIR => C_TDIR_INIT(32-1 downto 0),
        RDIR => C_RDIR_INIT(32-1 downto 0),
        TYM_0 => C_TYM_0_INIT(32-1 downto 0),
        TYM_1 => C_TYM_1_INIT(32-1 downto 0),
        LDST => C_LDST_INIT(32-1 downto 0),
        TMOF => C_TMOF_INIT(32-1 downto 0),
        TPLS => C_TPLS_INIT(32-1 downto 0),
        TDUR => C_TDUR_INIT(32-1 downto 0),
        MNxx => (
            C_MN00_INIT(32-1 downto 0),
            C_MN01_INIT(32-1 downto 0),
            C_MN02_INIT(32-1 downto 0),
            C_MN03_INIT(32-1 downto 0),
            C_MN04_INIT(32-1 downto 0),
            C_MN05_INIT(32-1 downto 0),
            C_MN06_INIT(32-1 downto 0),
            C_MN07_INIT(32-1 downto 0),
            C_MN08_INIT(32-1 downto 0),
            C_MN09_INIT(32-1 downto 0),
            C_MN10_INIT(32-1 downto 0),
            C_MN11_INIT(32-1 downto 0),
            C_MN12_INIT(32-1 downto 0),
            C_MN13_INIT(32-1 downto 0),
            C_MN14_INIT(32-1 downto 0),
            C_MN15_INIT(32-1 downto 0),
            C_MN16_INIT(32-1 downto 0),
            C_MN17_INIT(32-1 downto 0),
            C_MN18_INIT(32-1 downto 0),
            C_MN19_INIT(32-1 downto 0),
            C_MN20_INIT(32-1 downto 0),
            C_MN21_INIT(32-1 downto 0),
            C_MN22_INIT(32-1 downto 0),
            C_MN23_INIT(32-1 downto 0)
        ),
        PLEN => C_PLEN_INIT(32-1 downto 0),
        RSRX => C_RSRX_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants in case they are needed in multiple files
    -- Addresses are 32-bits: correct sizing implemented in .vhd files
    constant C_GTPG_ADDR : std_logic_vector(31 downto 0) := x"c0000000";
    constant C_RGTY_ADDR : std_logic_vector(31 downto 0) := x"c0000004";
    constant C_RTXD_ADDR : std_logic_vector(31 downto 0) := x"c0000008";
    constant C_RRXD_ADDR : std_logic_vector(31 downto 0) := x"c000000c";
    constant C_RBAL_ADDR : std_logic_vector(31 downto 0) := x"c0000010";
    constant C_RS00_ADDR : std_logic_vector(31 downto 0) := x"c0000014";
    constant C_RS01_ADDR : std_logic_vector(31 downto 0) := x"c0000018";
    constant C_RS02_ADDR : std_logic_vector(31 downto 0) := x"c000001c";
    constant C_RS03_ADDR : std_logic_vector(31 downto 0) := x"c0000020";
    constant C_RS04_ADDR : std_logic_vector(31 downto 0) := x"c0000024";
    constant C_RS05_ADDR : std_logic_vector(31 downto 0) := x"c0000028";
    constant C_RS06_ADDR : std_logic_vector(31 downto 0) := x"c000002c";
    constant C_RS07_ADDR : std_logic_vector(31 downto 0) := x"c0000030";
    constant C_RS08_ADDR : std_logic_vector(31 downto 0) := x"c0000034";
    constant C_RS09_ADDR : std_logic_vector(31 downto 0) := x"c0000038";
    constant C_RS10_ADDR : std_logic_vector(31 downto 0) := x"c000003c";
    constant C_RS11_ADDR : std_logic_vector(31 downto 0) := x"c0000040";
    constant C_RS12_ADDR : std_logic_vector(31 downto 0) := x"c0000044";
    constant C_RS13_ADDR : std_logic_vector(31 downto 0) := x"c0000048";
    constant C_RS14_ADDR : std_logic_vector(31 downto 0) := x"c000004c";
    constant C_RS15_ADDR : std_logic_vector(31 downto 0) := x"c0000050";
    constant C_RS16_ADDR : std_logic_vector(31 downto 0) := x"c0000054";
    constant C_RS17_ADDR : std_logic_vector(31 downto 0) := x"c0000058";
    constant C_RS18_ADDR : std_logic_vector(31 downto 0) := x"c000005c";
    constant C_RS19_ADDR : std_logic_vector(31 downto 0) := x"c0000060";
    constant C_RS20_ADDR : std_logic_vector(31 downto 0) := x"c0000064";
    constant C_RS21_ADDR : std_logic_vector(31 downto 0) := x"c0000068";
    constant C_RS22_ADDR : std_logic_vector(31 downto 0) := x"c000006c";
    constant C_RS23_ADDR : std_logic_vector(31 downto 0) := x"c0000070";
    constant C_TS00_ADDR : std_logic_vector(31 downto 0) := x"c0000074";
    constant C_TS01_ADDR : std_logic_vector(31 downto 0) := x"c0000078";
    constant C_TS02_ADDR : std_logic_vector(31 downto 0) := x"c000007c";
    constant C_TS03_ADDR : std_logic_vector(31 downto 0) := x"c0000080";
    constant C_TS04_ADDR : std_logic_vector(31 downto 0) := x"c0000084";
    constant C_TS05_ADDR : std_logic_vector(31 downto 0) := x"c0000088";
    constant C_TS06_ADDR : std_logic_vector(31 downto 0) := x"c000008c";
    constant C_TS07_ADDR : std_logic_vector(31 downto 0) := x"c0000090";
    constant C_TS08_ADDR : std_logic_vector(31 downto 0) := x"c0000094";
    constant C_TS09_ADDR : std_logic_vector(31 downto 0) := x"c0000098";
    constant C_TS10_ADDR : std_logic_vector(31 downto 0) := x"c000009c";
    constant C_TS11_ADDR : std_logic_vector(31 downto 0) := x"c00000a0";
    constant C_TS12_ADDR : std_logic_vector(31 downto 0) := x"c00000a4";
    constant C_TS13_ADDR : std_logic_vector(31 downto 0) := x"c00000a8";
    constant C_TS14_ADDR : std_logic_vector(31 downto 0) := x"c00000ac";
    constant C_TS15_ADDR : std_logic_vector(31 downto 0) := x"c00000b0";
    constant C_TS16_ADDR : std_logic_vector(31 downto 0) := x"c00000b4";
    constant C_TS17_ADDR : std_logic_vector(31 downto 0) := x"c00000b8";
    constant C_TS18_ADDR : std_logic_vector(31 downto 0) := x"c00000bc";
    constant C_TS19_ADDR : std_logic_vector(31 downto 0) := x"c00000c0";
    constant C_TS20_ADDR : std_logic_vector(31 downto 0) := x"c00000c4";
    constant C_TS21_ADDR : std_logic_vector(31 downto 0) := x"c00000c8";
    constant C_TS22_ADDR : std_logic_vector(31 downto 0) := x"c00000cc";
    constant C_TS23_ADDR : std_logic_vector(31 downto 0) := x"c00000d0";
    constant C_TNS00_ADDR : std_logic_vector(31 downto 0) := x"c00000d4";
    constant C_TNS01_ADDR : std_logic_vector(31 downto 0) := x"c00000d8";
    constant C_TNS02_ADDR : std_logic_vector(31 downto 0) := x"c00000dc";
    constant C_RNS00_ADDR : std_logic_vector(31 downto 0) := x"c00000e0";
    constant C_RNS01_ADDR : std_logic_vector(31 downto 0) := x"c00000e4";
    constant C_RNS02_ADDR : std_logic_vector(31 downto 0) := x"c00000e8";
    constant C_TCS00_ADDR : std_logic_vector(31 downto 0) := x"c00000ec";
    constant C_TCS01_ADDR : std_logic_vector(31 downto 0) := x"c00000f0";
    constant C_TCS02_ADDR : std_logic_vector(31 downto 0) := x"c00000f4";
    constant C_PDPL_ADDR : std_logic_vector(31 downto 0) := x"c00000f8";
    constant C_RCS00_ADDR : std_logic_vector(31 downto 0) := x"c00000fc";
    constant C_RCS01_ADDR : std_logic_vector(31 downto 0) := x"c0000100";
    constant C_RCS02_ADDR : std_logic_vector(31 downto 0) := x"c0000104";
    constant C_RBWD_ADDR : std_logic_vector(31 downto 0) := x"c0000108";
    constant C_SRST_ADDR : std_logic_vector(31 downto 0) := x"c000010c";
    constant C_RVSR_ADDR : std_logic_vector(31 downto 0) := x"c0000110";
    constant C_TDIR_ADDR : std_logic_vector(31 downto 0) := x"c0000114";
    constant C_RDIR_ADDR : std_logic_vector(31 downto 0) := x"c0000118";
    constant C_TYM_0_ADDR : std_logic_vector(31 downto 0) := x"c000011c";
    constant C_TYM_1_ADDR : std_logic_vector(31 downto 0) := x"c0000120";
    constant C_LDST_ADDR : std_logic_vector(31 downto 0) := x"c0000124";
    constant C_MS00_ADDR : std_logic_vector(31 downto 0) := x"c0000128";
    constant C_MS01_ADDR : std_logic_vector(31 downto 0) := x"c000012c";
    constant C_MS02_ADDR : std_logic_vector(31 downto 0) := x"c0000130";
    constant C_MS03_ADDR : std_logic_vector(31 downto 0) := x"c0000134";
    constant C_MS04_ADDR : std_logic_vector(31 downto 0) := x"c0000138";
    constant C_MS05_ADDR : std_logic_vector(31 downto 0) := x"c000013c";
    constant C_MS06_ADDR : std_logic_vector(31 downto 0) := x"c0000140";
    constant C_MS07_ADDR : std_logic_vector(31 downto 0) := x"c0000144";
    constant C_MS08_ADDR : std_logic_vector(31 downto 0) := x"c0000148";
    constant C_MS09_ADDR : std_logic_vector(31 downto 0) := x"c000014c";
    constant C_MS10_ADDR : std_logic_vector(31 downto 0) := x"c0000150";
    constant C_MS11_ADDR : std_logic_vector(31 downto 0) := x"c0000154";
    constant C_MS12_ADDR : std_logic_vector(31 downto 0) := x"c0000158";
    constant C_MS13_ADDR : std_logic_vector(31 downto 0) := x"c000015c";
    constant C_MS14_ADDR : std_logic_vector(31 downto 0) := x"c0000160";
    constant C_MS15_ADDR : std_logic_vector(31 downto 0) := x"c0000164";
    constant C_MS16_ADDR : std_logic_vector(31 downto 0) := x"c0000168";
    constant C_MS17_ADDR : std_logic_vector(31 downto 0) := x"c000016c";
    constant C_MS18_ADDR : std_logic_vector(31 downto 0) := x"c0000170";
    constant C_MS19_ADDR : std_logic_vector(31 downto 0) := x"c0000174";
    constant C_MS20_ADDR : std_logic_vector(31 downto 0) := x"c0000178";
    constant C_MS21_ADDR : std_logic_vector(31 downto 0) := x"c000017c";
    constant C_MS22_ADDR : std_logic_vector(31 downto 0) := x"c0000180";
    constant C_MS23_ADDR : std_logic_vector(31 downto 0) := x"c0000184";
    constant C_TM00_ADDR : std_logic_vector(31 downto 0) := x"c0000188";
    constant C_TM01_ADDR : std_logic_vector(31 downto 0) := x"c000018c";
    constant C_TM02_ADDR : std_logic_vector(31 downto 0) := x"c0000190";
    constant C_TM03_ADDR : std_logic_vector(31 downto 0) := x"c0000194";
    constant C_TM04_ADDR : std_logic_vector(31 downto 0) := x"c0000198";
    constant C_TM05_ADDR : std_logic_vector(31 downto 0) := x"c000019c";
    constant C_TM06_ADDR : std_logic_vector(31 downto 0) := x"c00001a0";
    constant C_TM07_ADDR : std_logic_vector(31 downto 0) := x"c00001a4";
    constant C_TM08_ADDR : std_logic_vector(31 downto 0) := x"c00001a8";
    constant C_TM09_ADDR : std_logic_vector(31 downto 0) := x"c00001ac";
    constant C_TM10_ADDR : std_logic_vector(31 downto 0) := x"c00001b0";
    constant C_TM11_ADDR : std_logic_vector(31 downto 0) := x"c00001b4";
    constant C_TM12_ADDR : std_logic_vector(31 downto 0) := x"c00001b8";
    constant C_TM13_ADDR : std_logic_vector(31 downto 0) := x"c00001bc";
    constant C_TM14_ADDR : std_logic_vector(31 downto 0) := x"c00001c0";
    constant C_TM15_ADDR : std_logic_vector(31 downto 0) := x"c00001c4";
    constant C_TM16_ADDR : std_logic_vector(31 downto 0) := x"c00001c8";
    constant C_TM17_ADDR : std_logic_vector(31 downto 0) := x"c00001cc";
    constant C_TM18_ADDR : std_logic_vector(31 downto 0) := x"c00001d0";
    constant C_TM19_ADDR : std_logic_vector(31 downto 0) := x"c00001d4";
    constant C_TM20_ADDR : std_logic_vector(31 downto 0) := x"c00001d8";
    constant C_TM21_ADDR : std_logic_vector(31 downto 0) := x"c00001dc";
    constant C_TM22_ADDR : std_logic_vector(31 downto 0) := x"c00001e0";
    constant C_TM23_ADDR : std_logic_vector(31 downto 0) := x"c00001e4";
    constant C_RM00_ADDR : std_logic_vector(31 downto 0) := x"c00001e8";
    constant C_RM01_ADDR : std_logic_vector(31 downto 0) := x"c00001ec";
    constant C_RM02_ADDR : std_logic_vector(31 downto 0) := x"c00001f0";
    constant C_RM03_ADDR : std_logic_vector(31 downto 0) := x"c00001f4";
    constant C_RM04_ADDR : std_logic_vector(31 downto 0) := x"c00001f8";
    constant C_RM05_ADDR : std_logic_vector(31 downto 0) := x"c00001fc";
    constant C_RM06_ADDR : std_logic_vector(31 downto 0) := x"c0000200";
    constant C_RM07_ADDR : std_logic_vector(31 downto 0) := x"c0000204";
    constant C_RM08_ADDR : std_logic_vector(31 downto 0) := x"c0000208";
    constant C_RM09_ADDR : std_logic_vector(31 downto 0) := x"c000020c";
    constant C_RM10_ADDR : std_logic_vector(31 downto 0) := x"c0000210";
    constant C_RM11_ADDR : std_logic_vector(31 downto 0) := x"c0000214";
    constant C_RM12_ADDR : std_logic_vector(31 downto 0) := x"c0000218";
    constant C_RM13_ADDR : std_logic_vector(31 downto 0) := x"c000021c";
    constant C_RM14_ADDR : std_logic_vector(31 downto 0) := x"c0000220";
    constant C_RM15_ADDR : std_logic_vector(31 downto 0) := x"c0000224";
    constant C_RM16_ADDR : std_logic_vector(31 downto 0) := x"c0000228";
    constant C_RM17_ADDR : std_logic_vector(31 downto 0) := x"c000022c";
    constant C_RM18_ADDR : std_logic_vector(31 downto 0) := x"c0000230";
    constant C_RM19_ADDR : std_logic_vector(31 downto 0) := x"c0000234";
    constant C_RM20_ADDR : std_logic_vector(31 downto 0) := x"c0000238";
    constant C_RM21_ADDR : std_logic_vector(31 downto 0) := x"c000023c";
    constant C_RM22_ADDR : std_logic_vector(31 downto 0) := x"c0000240";
    constant C_RM23_ADDR : std_logic_vector(31 downto 0) := x"c0000244";
    constant C_TMOF_ADDR : std_logic_vector(31 downto 0) := x"c0000248";
    constant C_TPLS_ADDR : std_logic_vector(31 downto 0) := x"c000024c";
    constant C_TDUR_ADDR : std_logic_vector(31 downto 0) := x"c0000250";
    constant C_MN00_ADDR : std_logic_vector(31 downto 0) := x"c0000254";
    constant C_MN01_ADDR : std_logic_vector(31 downto 0) := x"c0000258";
    constant C_MN02_ADDR : std_logic_vector(31 downto 0) := x"c000025c";
    constant C_MN03_ADDR : std_logic_vector(31 downto 0) := x"c0000260";
    constant C_MN04_ADDR : std_logic_vector(31 downto 0) := x"c0000264";
    constant C_MN05_ADDR : std_logic_vector(31 downto 0) := x"c0000268";
    constant C_MN06_ADDR : std_logic_vector(31 downto 0) := x"c000026c";
    constant C_MN07_ADDR : std_logic_vector(31 downto 0) := x"c0000270";
    constant C_MN08_ADDR : std_logic_vector(31 downto 0) := x"c0000274";
    constant C_MN09_ADDR : std_logic_vector(31 downto 0) := x"c0000278";
    constant C_MN10_ADDR : std_logic_vector(31 downto 0) := x"c000027c";
    constant C_MN11_ADDR : std_logic_vector(31 downto 0) := x"c0000280";
    constant C_MN12_ADDR : std_logic_vector(31 downto 0) := x"c0000284";
    constant C_MN13_ADDR : std_logic_vector(31 downto 0) := x"c0000288";
    constant C_MN14_ADDR : std_logic_vector(31 downto 0) := x"c000028c";
    constant C_MN15_ADDR : std_logic_vector(31 downto 0) := x"c0000290";
    constant C_MN16_ADDR : std_logic_vector(31 downto 0) := x"c0000294";
    constant C_MN17_ADDR : std_logic_vector(31 downto 0) := x"c0000298";
    constant C_MN18_ADDR : std_logic_vector(31 downto 0) := x"c000029c";
    constant C_MN19_ADDR : std_logic_vector(31 downto 0) := x"c00002a0";
    constant C_MN20_ADDR : std_logic_vector(31 downto 0) := x"c00002a4";
    constant C_MN21_ADDR : std_logic_vector(31 downto 0) := x"c00002a8";
    constant C_MN22_ADDR : std_logic_vector(31 downto 0) := x"c00002ac";
    constant C_MN23_ADDR : std_logic_vector(31 downto 0) := x"c00002b0";
    constant C_PLEN_ADDR : std_logic_vector(31 downto 0) := x"c00002b4";
    constant C_RSRX_ADDR : std_logic_vector(31 downto 0) := x"c00002b8";

end package;
