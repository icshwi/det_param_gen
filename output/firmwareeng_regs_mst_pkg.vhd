-- Register package generated at: 24/03/2020 15:25:18
-- using: /epics/iocs/cmds/pkt-mux-cmd/dgro_master/det_param_gen/src/param_parse.py
-- Register definition file: ../../param_def/
-- Project: Detector Group Readout Master
-- Register space: Packet Engine Configuration Register Register Space (Master)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package eng_regs_mst_pkg is

    type T_ENG_REGS_MST_ARR24x32 is array (0 to 24-1) of std_logic_vector(32-1 downto 0);

    -- todo: fix alignment
    type t_eng_regs_mst_ro is record
        PHASH : std_logic_vector(32-1 downto 0);
    end record t_eng_regs_mst_ro;

    type t_eng_regs_mst_rw is record
        LPBK : std_logic_vector(32-1 downto 0);
        eth_src_mac_0xx : T_ENG_REGS_MST_ARR24x32;
        eth_src_mac_1xx : T_ENG_REGS_MST_ARR24x32;
        eth_dst_mac_0xx : T_ENG_REGS_MST_ARR24x32;
        eth_dst_mac_1xx : T_ENG_REGS_MST_ARR24x32;
        ip_src_addr_0xx : T_ENG_REGS_MST_ARR24x32;
        ip_src_addr_1xx : T_ENG_REGS_MST_ARR24x32;
        ip_dst_addr_0xx : T_ENG_REGS_MST_ARR24x32;
        ip_dst_addr_1xx : T_ENG_REGS_MST_ARR24x32;
        udp_src_portxx : T_ENG_REGS_MST_ARR24x32;
        udp_dst_portxx : T_ENG_REGS_MST_ARR24x32;
        ro_typexx : T_ENG_REGS_MST_ARR24x32;
        timeoutxx : T_ENG_REGS_MST_ARR24x32;
        eng_enable : std_logic_vector(32-1 downto 0);
        reformat : std_logic_vector(32-1 downto 0);
        pkt_gen_enable : std_logic_vector(32-1 downto 0);
        pkt_gen_idlesxx : T_ENG_REGS_MST_ARR24x32;
        pkt_gen_lengthxx : T_ENG_REGS_MST_ARR24x32;
    end record t_eng_regs_mst_rw;

    -- Define initialisation constants
    constant C_LPBK_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_PHASH_INIT : std_logic_vector(32-1 downto 0) := x"821134BD";
    constant C_eth_src_mac_000_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_001_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_002_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_003_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_004_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_005_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_006_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_007_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_008_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_009_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_010_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_011_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_012_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_013_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_014_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_015_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_016_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_017_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_018_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_019_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_020_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_021_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_022_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_023_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_100_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_101_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_102_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_103_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_104_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_105_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_106_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_107_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_108_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_109_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_110_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_111_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_112_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_113_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_114_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_115_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_116_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_117_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_118_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_119_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_120_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_121_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_122_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_src_mac_123_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_000_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_001_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_002_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_003_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_004_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_005_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_006_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_007_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_008_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_009_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_010_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_011_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_012_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_013_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_014_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_015_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_016_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_017_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_018_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_019_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_020_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_021_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_022_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_023_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_100_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_101_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_102_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_103_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_104_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_105_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_106_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_107_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_108_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_109_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_110_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_111_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_112_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_113_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_114_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_115_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_116_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_117_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_118_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_119_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_120_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_121_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_122_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eth_dst_mac_123_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_000_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_001_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_002_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_003_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_004_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_005_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_006_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_007_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_008_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_009_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_010_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_011_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_012_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_013_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_014_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_015_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_016_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_017_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_018_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_019_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_020_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_021_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_022_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_023_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_100_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_101_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_102_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_103_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_104_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_105_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_106_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_107_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_108_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_109_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_110_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_111_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_112_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_113_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_114_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_115_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_116_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_117_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_118_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_119_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_120_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_121_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_122_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_src_addr_123_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_000_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_001_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_002_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_003_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_004_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_005_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_006_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_007_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_008_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_009_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_010_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_011_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_012_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_013_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_014_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_015_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_016_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_017_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_018_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_019_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_020_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_021_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_022_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_023_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_100_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_101_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_102_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_103_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_104_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_105_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_106_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_107_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_108_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_109_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_110_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_111_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_112_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_113_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_114_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_115_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_116_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_117_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_118_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_119_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_120_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_121_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_122_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ip_dst_addr_123_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port03_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port04_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port05_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port06_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port07_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port08_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port09_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port10_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port11_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port12_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port13_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port14_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port15_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port16_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port17_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port18_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port19_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port20_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port21_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port22_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_src_port23_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port03_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port04_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port05_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port06_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port07_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port08_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port09_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port10_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port11_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port12_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port13_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port14_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port15_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port16_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port17_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port18_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port19_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port20_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port21_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port22_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_udp_dst_port23_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type03_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type04_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type05_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type06_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type07_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type08_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type09_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type10_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type11_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type12_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type13_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type14_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type15_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type16_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type17_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type18_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type19_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type20_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type21_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type22_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_ro_type23_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout00_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout01_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout02_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout03_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout04_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout05_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout06_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout07_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout08_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout09_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout10_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout11_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout12_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout13_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout14_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout15_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout16_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout17_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout18_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout19_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout20_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout21_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout22_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_timeout23_INIT : std_logic_vector(32-1 downto 0) := x"00000000";
    constant C_eng_enable_INIT : std_logic_vector(32-1 downto 0) := x"ffffffff";
    constant C_reformat_INIT : std_logic_vector(32-1 downto 0) := x"00000001";
    constant C_pkt_gen_enable_INIT : std_logic_vector(32-1 downto 0) := x"ffffffff";
    constant C_pkt_gen_idles00_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles01_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles02_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles03_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles04_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles05_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles06_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles07_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles08_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles09_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles10_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles11_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles12_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles13_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles14_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles15_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles16_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles17_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles18_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles19_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles20_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles21_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles22_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_idles23_INIT : std_logic_vector(32-1 downto 0) := x"00000005";
    constant C_pkt_gen_length00_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length01_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length02_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length03_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length04_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length05_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length06_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length07_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length08_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length09_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length10_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length11_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length12_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length13_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length14_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length15_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length16_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length17_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length18_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length19_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length20_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length21_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length22_INIT : std_logic_vector(32-1 downto 0) := x"00000010";
    constant C_pkt_gen_length23_INIT : std_logic_vector(32-1 downto 0) := x"00000010";

    -- Assign initialisation constants
    constant C_ENG_REGS_MST_RO : t_eng_regs_mst_ro := (
        PHASH => C_PHASH_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants
    constant C_ENG_REGS_MST_RW : t_eng_regs_mst_rw := (
        LPBK => C_LPBK_INIT(32-1 downto 0),
        eth_src_mac_0xx => (
            C_eth_src_mac_000_INIT(32-1 downto 0),
            C_eth_src_mac_001_INIT(32-1 downto 0),
            C_eth_src_mac_002_INIT(32-1 downto 0),
            C_eth_src_mac_003_INIT(32-1 downto 0),
            C_eth_src_mac_004_INIT(32-1 downto 0),
            C_eth_src_mac_005_INIT(32-1 downto 0),
            C_eth_src_mac_006_INIT(32-1 downto 0),
            C_eth_src_mac_007_INIT(32-1 downto 0),
            C_eth_src_mac_008_INIT(32-1 downto 0),
            C_eth_src_mac_009_INIT(32-1 downto 0),
            C_eth_src_mac_010_INIT(32-1 downto 0),
            C_eth_src_mac_011_INIT(32-1 downto 0),
            C_eth_src_mac_012_INIT(32-1 downto 0),
            C_eth_src_mac_013_INIT(32-1 downto 0),
            C_eth_src_mac_014_INIT(32-1 downto 0),
            C_eth_src_mac_015_INIT(32-1 downto 0),
            C_eth_src_mac_016_INIT(32-1 downto 0),
            C_eth_src_mac_017_INIT(32-1 downto 0),
            C_eth_src_mac_018_INIT(32-1 downto 0),
            C_eth_src_mac_019_INIT(32-1 downto 0),
            C_eth_src_mac_020_INIT(32-1 downto 0),
            C_eth_src_mac_021_INIT(32-1 downto 0),
            C_eth_src_mac_022_INIT(32-1 downto 0),
            C_eth_src_mac_023_INIT(32-1 downto 0)
        ),
        eth_src_mac_1xx => (
            C_eth_src_mac_100_INIT(32-1 downto 0),
            C_eth_src_mac_101_INIT(32-1 downto 0),
            C_eth_src_mac_102_INIT(32-1 downto 0),
            C_eth_src_mac_103_INIT(32-1 downto 0),
            C_eth_src_mac_104_INIT(32-1 downto 0),
            C_eth_src_mac_105_INIT(32-1 downto 0),
            C_eth_src_mac_106_INIT(32-1 downto 0),
            C_eth_src_mac_107_INIT(32-1 downto 0),
            C_eth_src_mac_108_INIT(32-1 downto 0),
            C_eth_src_mac_109_INIT(32-1 downto 0),
            C_eth_src_mac_110_INIT(32-1 downto 0),
            C_eth_src_mac_111_INIT(32-1 downto 0),
            C_eth_src_mac_112_INIT(32-1 downto 0),
            C_eth_src_mac_113_INIT(32-1 downto 0),
            C_eth_src_mac_114_INIT(32-1 downto 0),
            C_eth_src_mac_115_INIT(32-1 downto 0),
            C_eth_src_mac_116_INIT(32-1 downto 0),
            C_eth_src_mac_117_INIT(32-1 downto 0),
            C_eth_src_mac_118_INIT(32-1 downto 0),
            C_eth_src_mac_119_INIT(32-1 downto 0),
            C_eth_src_mac_120_INIT(32-1 downto 0),
            C_eth_src_mac_121_INIT(32-1 downto 0),
            C_eth_src_mac_122_INIT(32-1 downto 0),
            C_eth_src_mac_123_INIT(32-1 downto 0)
        ),
        eth_dst_mac_0xx => (
            C_eth_dst_mac_000_INIT(32-1 downto 0),
            C_eth_dst_mac_001_INIT(32-1 downto 0),
            C_eth_dst_mac_002_INIT(32-1 downto 0),
            C_eth_dst_mac_003_INIT(32-1 downto 0),
            C_eth_dst_mac_004_INIT(32-1 downto 0),
            C_eth_dst_mac_005_INIT(32-1 downto 0),
            C_eth_dst_mac_006_INIT(32-1 downto 0),
            C_eth_dst_mac_007_INIT(32-1 downto 0),
            C_eth_dst_mac_008_INIT(32-1 downto 0),
            C_eth_dst_mac_009_INIT(32-1 downto 0),
            C_eth_dst_mac_010_INIT(32-1 downto 0),
            C_eth_dst_mac_011_INIT(32-1 downto 0),
            C_eth_dst_mac_012_INIT(32-1 downto 0),
            C_eth_dst_mac_013_INIT(32-1 downto 0),
            C_eth_dst_mac_014_INIT(32-1 downto 0),
            C_eth_dst_mac_015_INIT(32-1 downto 0),
            C_eth_dst_mac_016_INIT(32-1 downto 0),
            C_eth_dst_mac_017_INIT(32-1 downto 0),
            C_eth_dst_mac_018_INIT(32-1 downto 0),
            C_eth_dst_mac_019_INIT(32-1 downto 0),
            C_eth_dst_mac_020_INIT(32-1 downto 0),
            C_eth_dst_mac_021_INIT(32-1 downto 0),
            C_eth_dst_mac_022_INIT(32-1 downto 0),
            C_eth_dst_mac_023_INIT(32-1 downto 0)
        ),
        eth_dst_mac_1xx => (
            C_eth_dst_mac_100_INIT(32-1 downto 0),
            C_eth_dst_mac_101_INIT(32-1 downto 0),
            C_eth_dst_mac_102_INIT(32-1 downto 0),
            C_eth_dst_mac_103_INIT(32-1 downto 0),
            C_eth_dst_mac_104_INIT(32-1 downto 0),
            C_eth_dst_mac_105_INIT(32-1 downto 0),
            C_eth_dst_mac_106_INIT(32-1 downto 0),
            C_eth_dst_mac_107_INIT(32-1 downto 0),
            C_eth_dst_mac_108_INIT(32-1 downto 0),
            C_eth_dst_mac_109_INIT(32-1 downto 0),
            C_eth_dst_mac_110_INIT(32-1 downto 0),
            C_eth_dst_mac_111_INIT(32-1 downto 0),
            C_eth_dst_mac_112_INIT(32-1 downto 0),
            C_eth_dst_mac_113_INIT(32-1 downto 0),
            C_eth_dst_mac_114_INIT(32-1 downto 0),
            C_eth_dst_mac_115_INIT(32-1 downto 0),
            C_eth_dst_mac_116_INIT(32-1 downto 0),
            C_eth_dst_mac_117_INIT(32-1 downto 0),
            C_eth_dst_mac_118_INIT(32-1 downto 0),
            C_eth_dst_mac_119_INIT(32-1 downto 0),
            C_eth_dst_mac_120_INIT(32-1 downto 0),
            C_eth_dst_mac_121_INIT(32-1 downto 0),
            C_eth_dst_mac_122_INIT(32-1 downto 0),
            C_eth_dst_mac_123_INIT(32-1 downto 0)
        ),
        ip_src_addr_0xx => (
            C_ip_src_addr_000_INIT(32-1 downto 0),
            C_ip_src_addr_001_INIT(32-1 downto 0),
            C_ip_src_addr_002_INIT(32-1 downto 0),
            C_ip_src_addr_003_INIT(32-1 downto 0),
            C_ip_src_addr_004_INIT(32-1 downto 0),
            C_ip_src_addr_005_INIT(32-1 downto 0),
            C_ip_src_addr_006_INIT(32-1 downto 0),
            C_ip_src_addr_007_INIT(32-1 downto 0),
            C_ip_src_addr_008_INIT(32-1 downto 0),
            C_ip_src_addr_009_INIT(32-1 downto 0),
            C_ip_src_addr_010_INIT(32-1 downto 0),
            C_ip_src_addr_011_INIT(32-1 downto 0),
            C_ip_src_addr_012_INIT(32-1 downto 0),
            C_ip_src_addr_013_INIT(32-1 downto 0),
            C_ip_src_addr_014_INIT(32-1 downto 0),
            C_ip_src_addr_015_INIT(32-1 downto 0),
            C_ip_src_addr_016_INIT(32-1 downto 0),
            C_ip_src_addr_017_INIT(32-1 downto 0),
            C_ip_src_addr_018_INIT(32-1 downto 0),
            C_ip_src_addr_019_INIT(32-1 downto 0),
            C_ip_src_addr_020_INIT(32-1 downto 0),
            C_ip_src_addr_021_INIT(32-1 downto 0),
            C_ip_src_addr_022_INIT(32-1 downto 0),
            C_ip_src_addr_023_INIT(32-1 downto 0)
        ),
        ip_src_addr_1xx => (
            C_ip_src_addr_100_INIT(32-1 downto 0),
            C_ip_src_addr_101_INIT(32-1 downto 0),
            C_ip_src_addr_102_INIT(32-1 downto 0),
            C_ip_src_addr_103_INIT(32-1 downto 0),
            C_ip_src_addr_104_INIT(32-1 downto 0),
            C_ip_src_addr_105_INIT(32-1 downto 0),
            C_ip_src_addr_106_INIT(32-1 downto 0),
            C_ip_src_addr_107_INIT(32-1 downto 0),
            C_ip_src_addr_108_INIT(32-1 downto 0),
            C_ip_src_addr_109_INIT(32-1 downto 0),
            C_ip_src_addr_110_INIT(32-1 downto 0),
            C_ip_src_addr_111_INIT(32-1 downto 0),
            C_ip_src_addr_112_INIT(32-1 downto 0),
            C_ip_src_addr_113_INIT(32-1 downto 0),
            C_ip_src_addr_114_INIT(32-1 downto 0),
            C_ip_src_addr_115_INIT(32-1 downto 0),
            C_ip_src_addr_116_INIT(32-1 downto 0),
            C_ip_src_addr_117_INIT(32-1 downto 0),
            C_ip_src_addr_118_INIT(32-1 downto 0),
            C_ip_src_addr_119_INIT(32-1 downto 0),
            C_ip_src_addr_120_INIT(32-1 downto 0),
            C_ip_src_addr_121_INIT(32-1 downto 0),
            C_ip_src_addr_122_INIT(32-1 downto 0),
            C_ip_src_addr_123_INIT(32-1 downto 0)
        ),
        ip_dst_addr_0xx => (
            C_ip_dst_addr_000_INIT(32-1 downto 0),
            C_ip_dst_addr_001_INIT(32-1 downto 0),
            C_ip_dst_addr_002_INIT(32-1 downto 0),
            C_ip_dst_addr_003_INIT(32-1 downto 0),
            C_ip_dst_addr_004_INIT(32-1 downto 0),
            C_ip_dst_addr_005_INIT(32-1 downto 0),
            C_ip_dst_addr_006_INIT(32-1 downto 0),
            C_ip_dst_addr_007_INIT(32-1 downto 0),
            C_ip_dst_addr_008_INIT(32-1 downto 0),
            C_ip_dst_addr_009_INIT(32-1 downto 0),
            C_ip_dst_addr_010_INIT(32-1 downto 0),
            C_ip_dst_addr_011_INIT(32-1 downto 0),
            C_ip_dst_addr_012_INIT(32-1 downto 0),
            C_ip_dst_addr_013_INIT(32-1 downto 0),
            C_ip_dst_addr_014_INIT(32-1 downto 0),
            C_ip_dst_addr_015_INIT(32-1 downto 0),
            C_ip_dst_addr_016_INIT(32-1 downto 0),
            C_ip_dst_addr_017_INIT(32-1 downto 0),
            C_ip_dst_addr_018_INIT(32-1 downto 0),
            C_ip_dst_addr_019_INIT(32-1 downto 0),
            C_ip_dst_addr_020_INIT(32-1 downto 0),
            C_ip_dst_addr_021_INIT(32-1 downto 0),
            C_ip_dst_addr_022_INIT(32-1 downto 0),
            C_ip_dst_addr_023_INIT(32-1 downto 0)
        ),
        ip_dst_addr_1xx => (
            C_ip_dst_addr_100_INIT(32-1 downto 0),
            C_ip_dst_addr_101_INIT(32-1 downto 0),
            C_ip_dst_addr_102_INIT(32-1 downto 0),
            C_ip_dst_addr_103_INIT(32-1 downto 0),
            C_ip_dst_addr_104_INIT(32-1 downto 0),
            C_ip_dst_addr_105_INIT(32-1 downto 0),
            C_ip_dst_addr_106_INIT(32-1 downto 0),
            C_ip_dst_addr_107_INIT(32-1 downto 0),
            C_ip_dst_addr_108_INIT(32-1 downto 0),
            C_ip_dst_addr_109_INIT(32-1 downto 0),
            C_ip_dst_addr_110_INIT(32-1 downto 0),
            C_ip_dst_addr_111_INIT(32-1 downto 0),
            C_ip_dst_addr_112_INIT(32-1 downto 0),
            C_ip_dst_addr_113_INIT(32-1 downto 0),
            C_ip_dst_addr_114_INIT(32-1 downto 0),
            C_ip_dst_addr_115_INIT(32-1 downto 0),
            C_ip_dst_addr_116_INIT(32-1 downto 0),
            C_ip_dst_addr_117_INIT(32-1 downto 0),
            C_ip_dst_addr_118_INIT(32-1 downto 0),
            C_ip_dst_addr_119_INIT(32-1 downto 0),
            C_ip_dst_addr_120_INIT(32-1 downto 0),
            C_ip_dst_addr_121_INIT(32-1 downto 0),
            C_ip_dst_addr_122_INIT(32-1 downto 0),
            C_ip_dst_addr_123_INIT(32-1 downto 0)
        ),
        udp_src_portxx => (
            C_udp_src_port00_INIT(32-1 downto 0),
            C_udp_src_port01_INIT(32-1 downto 0),
            C_udp_src_port02_INIT(32-1 downto 0),
            C_udp_src_port03_INIT(32-1 downto 0),
            C_udp_src_port04_INIT(32-1 downto 0),
            C_udp_src_port05_INIT(32-1 downto 0),
            C_udp_src_port06_INIT(32-1 downto 0),
            C_udp_src_port07_INIT(32-1 downto 0),
            C_udp_src_port08_INIT(32-1 downto 0),
            C_udp_src_port09_INIT(32-1 downto 0),
            C_udp_src_port10_INIT(32-1 downto 0),
            C_udp_src_port11_INIT(32-1 downto 0),
            C_udp_src_port12_INIT(32-1 downto 0),
            C_udp_src_port13_INIT(32-1 downto 0),
            C_udp_src_port14_INIT(32-1 downto 0),
            C_udp_src_port15_INIT(32-1 downto 0),
            C_udp_src_port16_INIT(32-1 downto 0),
            C_udp_src_port17_INIT(32-1 downto 0),
            C_udp_src_port18_INIT(32-1 downto 0),
            C_udp_src_port19_INIT(32-1 downto 0),
            C_udp_src_port20_INIT(32-1 downto 0),
            C_udp_src_port21_INIT(32-1 downto 0),
            C_udp_src_port22_INIT(32-1 downto 0),
            C_udp_src_port23_INIT(32-1 downto 0)
        ),
        udp_dst_portxx => (
            C_udp_dst_port00_INIT(32-1 downto 0),
            C_udp_dst_port01_INIT(32-1 downto 0),
            C_udp_dst_port02_INIT(32-1 downto 0),
            C_udp_dst_port03_INIT(32-1 downto 0),
            C_udp_dst_port04_INIT(32-1 downto 0),
            C_udp_dst_port05_INIT(32-1 downto 0),
            C_udp_dst_port06_INIT(32-1 downto 0),
            C_udp_dst_port07_INIT(32-1 downto 0),
            C_udp_dst_port08_INIT(32-1 downto 0),
            C_udp_dst_port09_INIT(32-1 downto 0),
            C_udp_dst_port10_INIT(32-1 downto 0),
            C_udp_dst_port11_INIT(32-1 downto 0),
            C_udp_dst_port12_INIT(32-1 downto 0),
            C_udp_dst_port13_INIT(32-1 downto 0),
            C_udp_dst_port14_INIT(32-1 downto 0),
            C_udp_dst_port15_INIT(32-1 downto 0),
            C_udp_dst_port16_INIT(32-1 downto 0),
            C_udp_dst_port17_INIT(32-1 downto 0),
            C_udp_dst_port18_INIT(32-1 downto 0),
            C_udp_dst_port19_INIT(32-1 downto 0),
            C_udp_dst_port20_INIT(32-1 downto 0),
            C_udp_dst_port21_INIT(32-1 downto 0),
            C_udp_dst_port22_INIT(32-1 downto 0),
            C_udp_dst_port23_INIT(32-1 downto 0)
        ),
        ro_typexx => (
            C_ro_type00_INIT(32-1 downto 0),
            C_ro_type01_INIT(32-1 downto 0),
            C_ro_type02_INIT(32-1 downto 0),
            C_ro_type03_INIT(32-1 downto 0),
            C_ro_type04_INIT(32-1 downto 0),
            C_ro_type05_INIT(32-1 downto 0),
            C_ro_type06_INIT(32-1 downto 0),
            C_ro_type07_INIT(32-1 downto 0),
            C_ro_type08_INIT(32-1 downto 0),
            C_ro_type09_INIT(32-1 downto 0),
            C_ro_type10_INIT(32-1 downto 0),
            C_ro_type11_INIT(32-1 downto 0),
            C_ro_type12_INIT(32-1 downto 0),
            C_ro_type13_INIT(32-1 downto 0),
            C_ro_type14_INIT(32-1 downto 0),
            C_ro_type15_INIT(32-1 downto 0),
            C_ro_type16_INIT(32-1 downto 0),
            C_ro_type17_INIT(32-1 downto 0),
            C_ro_type18_INIT(32-1 downto 0),
            C_ro_type19_INIT(32-1 downto 0),
            C_ro_type20_INIT(32-1 downto 0),
            C_ro_type21_INIT(32-1 downto 0),
            C_ro_type22_INIT(32-1 downto 0),
            C_ro_type23_INIT(32-1 downto 0)
        ),
        timeoutxx => (
            C_timeout00_INIT(32-1 downto 0),
            C_timeout01_INIT(32-1 downto 0),
            C_timeout02_INIT(32-1 downto 0),
            C_timeout03_INIT(32-1 downto 0),
            C_timeout04_INIT(32-1 downto 0),
            C_timeout05_INIT(32-1 downto 0),
            C_timeout06_INIT(32-1 downto 0),
            C_timeout07_INIT(32-1 downto 0),
            C_timeout08_INIT(32-1 downto 0),
            C_timeout09_INIT(32-1 downto 0),
            C_timeout10_INIT(32-1 downto 0),
            C_timeout11_INIT(32-1 downto 0),
            C_timeout12_INIT(32-1 downto 0),
            C_timeout13_INIT(32-1 downto 0),
            C_timeout14_INIT(32-1 downto 0),
            C_timeout15_INIT(32-1 downto 0),
            C_timeout16_INIT(32-1 downto 0),
            C_timeout17_INIT(32-1 downto 0),
            C_timeout18_INIT(32-1 downto 0),
            C_timeout19_INIT(32-1 downto 0),
            C_timeout20_INIT(32-1 downto 0),
            C_timeout21_INIT(32-1 downto 0),
            C_timeout22_INIT(32-1 downto 0),
            C_timeout23_INIT(32-1 downto 0)
        ),
        eng_enable => C_eng_enable_INIT(32-1 downto 0),
        reformat => C_reformat_INIT(32-1 downto 0),
        pkt_gen_enable => C_pkt_gen_enable_INIT(32-1 downto 0),
        pkt_gen_idlesxx => (
            C_pkt_gen_idles00_INIT(32-1 downto 0),
            C_pkt_gen_idles01_INIT(32-1 downto 0),
            C_pkt_gen_idles02_INIT(32-1 downto 0),
            C_pkt_gen_idles03_INIT(32-1 downto 0),
            C_pkt_gen_idles04_INIT(32-1 downto 0),
            C_pkt_gen_idles05_INIT(32-1 downto 0),
            C_pkt_gen_idles06_INIT(32-1 downto 0),
            C_pkt_gen_idles07_INIT(32-1 downto 0),
            C_pkt_gen_idles08_INIT(32-1 downto 0),
            C_pkt_gen_idles09_INIT(32-1 downto 0),
            C_pkt_gen_idles10_INIT(32-1 downto 0),
            C_pkt_gen_idles11_INIT(32-1 downto 0),
            C_pkt_gen_idles12_INIT(32-1 downto 0),
            C_pkt_gen_idles13_INIT(32-1 downto 0),
            C_pkt_gen_idles14_INIT(32-1 downto 0),
            C_pkt_gen_idles15_INIT(32-1 downto 0),
            C_pkt_gen_idles16_INIT(32-1 downto 0),
            C_pkt_gen_idles17_INIT(32-1 downto 0),
            C_pkt_gen_idles18_INIT(32-1 downto 0),
            C_pkt_gen_idles19_INIT(32-1 downto 0),
            C_pkt_gen_idles20_INIT(32-1 downto 0),
            C_pkt_gen_idles21_INIT(32-1 downto 0),
            C_pkt_gen_idles22_INIT(32-1 downto 0),
            C_pkt_gen_idles23_INIT(32-1 downto 0)
        ),
        pkt_gen_lengthxx => (
            C_pkt_gen_length00_INIT(32-1 downto 0),
            C_pkt_gen_length01_INIT(32-1 downto 0),
            C_pkt_gen_length02_INIT(32-1 downto 0),
            C_pkt_gen_length03_INIT(32-1 downto 0),
            C_pkt_gen_length04_INIT(32-1 downto 0),
            C_pkt_gen_length05_INIT(32-1 downto 0),
            C_pkt_gen_length06_INIT(32-1 downto 0),
            C_pkt_gen_length07_INIT(32-1 downto 0),
            C_pkt_gen_length08_INIT(32-1 downto 0),
            C_pkt_gen_length09_INIT(32-1 downto 0),
            C_pkt_gen_length10_INIT(32-1 downto 0),
            C_pkt_gen_length11_INIT(32-1 downto 0),
            C_pkt_gen_length12_INIT(32-1 downto 0),
            C_pkt_gen_length13_INIT(32-1 downto 0),
            C_pkt_gen_length14_INIT(32-1 downto 0),
            C_pkt_gen_length15_INIT(32-1 downto 0),
            C_pkt_gen_length16_INIT(32-1 downto 0),
            C_pkt_gen_length17_INIT(32-1 downto 0),
            C_pkt_gen_length18_INIT(32-1 downto 0),
            C_pkt_gen_length19_INIT(32-1 downto 0),
            C_pkt_gen_length20_INIT(32-1 downto 0),
            C_pkt_gen_length21_INIT(32-1 downto 0),
            C_pkt_gen_length22_INIT(32-1 downto 0),
            C_pkt_gen_length23_INIT(32-1 downto 0)
        )
    );

    -- Assign initialisation constants in case they are needed in multiple files
    -- Addresses are 32-bits: correct sizing implemented in .vhd files
    constant C_LPBK_ADDR : std_logic_vector(31 downto 0) := x"c0002000";
    constant C_PHASH_ADDR : std_logic_vector(31 downto 0) := x"c0002004";
    constant C_eth_src_mac_000_ADDR : std_logic_vector(31 downto 0) := x"c0002008";
    constant C_eth_src_mac_001_ADDR : std_logic_vector(31 downto 0) := x"c000200c";
    constant C_eth_src_mac_002_ADDR : std_logic_vector(31 downto 0) := x"c0002010";
    constant C_eth_src_mac_003_ADDR : std_logic_vector(31 downto 0) := x"c0002014";
    constant C_eth_src_mac_004_ADDR : std_logic_vector(31 downto 0) := x"c0002018";
    constant C_eth_src_mac_005_ADDR : std_logic_vector(31 downto 0) := x"c000201c";
    constant C_eth_src_mac_006_ADDR : std_logic_vector(31 downto 0) := x"c0002020";
    constant C_eth_src_mac_007_ADDR : std_logic_vector(31 downto 0) := x"c0002024";
    constant C_eth_src_mac_008_ADDR : std_logic_vector(31 downto 0) := x"c0002028";
    constant C_eth_src_mac_009_ADDR : std_logic_vector(31 downto 0) := x"c000202c";
    constant C_eth_src_mac_010_ADDR : std_logic_vector(31 downto 0) := x"c0002030";
    constant C_eth_src_mac_011_ADDR : std_logic_vector(31 downto 0) := x"c0002034";
    constant C_eth_src_mac_012_ADDR : std_logic_vector(31 downto 0) := x"c0002038";
    constant C_eth_src_mac_013_ADDR : std_logic_vector(31 downto 0) := x"c000203c";
    constant C_eth_src_mac_014_ADDR : std_logic_vector(31 downto 0) := x"c0002040";
    constant C_eth_src_mac_015_ADDR : std_logic_vector(31 downto 0) := x"c0002044";
    constant C_eth_src_mac_016_ADDR : std_logic_vector(31 downto 0) := x"c0002048";
    constant C_eth_src_mac_017_ADDR : std_logic_vector(31 downto 0) := x"c000204c";
    constant C_eth_src_mac_018_ADDR : std_logic_vector(31 downto 0) := x"c0002050";
    constant C_eth_src_mac_019_ADDR : std_logic_vector(31 downto 0) := x"c0002054";
    constant C_eth_src_mac_020_ADDR : std_logic_vector(31 downto 0) := x"c0002058";
    constant C_eth_src_mac_021_ADDR : std_logic_vector(31 downto 0) := x"c000205c";
    constant C_eth_src_mac_022_ADDR : std_logic_vector(31 downto 0) := x"c0002060";
    constant C_eth_src_mac_023_ADDR : std_logic_vector(31 downto 0) := x"c0002064";
    constant C_eth_src_mac_100_ADDR : std_logic_vector(31 downto 0) := x"c0002068";
    constant C_eth_src_mac_101_ADDR : std_logic_vector(31 downto 0) := x"c000206c";
    constant C_eth_src_mac_102_ADDR : std_logic_vector(31 downto 0) := x"c0002070";
    constant C_eth_src_mac_103_ADDR : std_logic_vector(31 downto 0) := x"c0002074";
    constant C_eth_src_mac_104_ADDR : std_logic_vector(31 downto 0) := x"c0002078";
    constant C_eth_src_mac_105_ADDR : std_logic_vector(31 downto 0) := x"c000207c";
    constant C_eth_src_mac_106_ADDR : std_logic_vector(31 downto 0) := x"c0002080";
    constant C_eth_src_mac_107_ADDR : std_logic_vector(31 downto 0) := x"c0002084";
    constant C_eth_src_mac_108_ADDR : std_logic_vector(31 downto 0) := x"c0002088";
    constant C_eth_src_mac_109_ADDR : std_logic_vector(31 downto 0) := x"c000208c";
    constant C_eth_src_mac_110_ADDR : std_logic_vector(31 downto 0) := x"c0002090";
    constant C_eth_src_mac_111_ADDR : std_logic_vector(31 downto 0) := x"c0002094";
    constant C_eth_src_mac_112_ADDR : std_logic_vector(31 downto 0) := x"c0002098";
    constant C_eth_src_mac_113_ADDR : std_logic_vector(31 downto 0) := x"c000209c";
    constant C_eth_src_mac_114_ADDR : std_logic_vector(31 downto 0) := x"c00020a0";
    constant C_eth_src_mac_115_ADDR : std_logic_vector(31 downto 0) := x"c00020a4";
    constant C_eth_src_mac_116_ADDR : std_logic_vector(31 downto 0) := x"c00020a8";
    constant C_eth_src_mac_117_ADDR : std_logic_vector(31 downto 0) := x"c00020ac";
    constant C_eth_src_mac_118_ADDR : std_logic_vector(31 downto 0) := x"c00020b0";
    constant C_eth_src_mac_119_ADDR : std_logic_vector(31 downto 0) := x"c00020b4";
    constant C_eth_src_mac_120_ADDR : std_logic_vector(31 downto 0) := x"c00020b8";
    constant C_eth_src_mac_121_ADDR : std_logic_vector(31 downto 0) := x"c00020bc";
    constant C_eth_src_mac_122_ADDR : std_logic_vector(31 downto 0) := x"c00020c0";
    constant C_eth_src_mac_123_ADDR : std_logic_vector(31 downto 0) := x"c00020c4";
    constant C_eth_dst_mac_000_ADDR : std_logic_vector(31 downto 0) := x"c00020c8";
    constant C_eth_dst_mac_001_ADDR : std_logic_vector(31 downto 0) := x"c00020cc";
    constant C_eth_dst_mac_002_ADDR : std_logic_vector(31 downto 0) := x"c00020d0";
    constant C_eth_dst_mac_003_ADDR : std_logic_vector(31 downto 0) := x"c00020d4";
    constant C_eth_dst_mac_004_ADDR : std_logic_vector(31 downto 0) := x"c00020d8";
    constant C_eth_dst_mac_005_ADDR : std_logic_vector(31 downto 0) := x"c00020dc";
    constant C_eth_dst_mac_006_ADDR : std_logic_vector(31 downto 0) := x"c00020e0";
    constant C_eth_dst_mac_007_ADDR : std_logic_vector(31 downto 0) := x"c00020e4";
    constant C_eth_dst_mac_008_ADDR : std_logic_vector(31 downto 0) := x"c00020e8";
    constant C_eth_dst_mac_009_ADDR : std_logic_vector(31 downto 0) := x"c00020ec";
    constant C_eth_dst_mac_010_ADDR : std_logic_vector(31 downto 0) := x"c00020f0";
    constant C_eth_dst_mac_011_ADDR : std_logic_vector(31 downto 0) := x"c00020f4";
    constant C_eth_dst_mac_012_ADDR : std_logic_vector(31 downto 0) := x"c00020f8";
    constant C_eth_dst_mac_013_ADDR : std_logic_vector(31 downto 0) := x"c00020fc";
    constant C_eth_dst_mac_014_ADDR : std_logic_vector(31 downto 0) := x"c0002100";
    constant C_eth_dst_mac_015_ADDR : std_logic_vector(31 downto 0) := x"c0002104";
    constant C_eth_dst_mac_016_ADDR : std_logic_vector(31 downto 0) := x"c0002108";
    constant C_eth_dst_mac_017_ADDR : std_logic_vector(31 downto 0) := x"c000210c";
    constant C_eth_dst_mac_018_ADDR : std_logic_vector(31 downto 0) := x"c0002110";
    constant C_eth_dst_mac_019_ADDR : std_logic_vector(31 downto 0) := x"c0002114";
    constant C_eth_dst_mac_020_ADDR : std_logic_vector(31 downto 0) := x"c0002118";
    constant C_eth_dst_mac_021_ADDR : std_logic_vector(31 downto 0) := x"c000211c";
    constant C_eth_dst_mac_022_ADDR : std_logic_vector(31 downto 0) := x"c0002120";
    constant C_eth_dst_mac_023_ADDR : std_logic_vector(31 downto 0) := x"c0002124";
    constant C_eth_dst_mac_100_ADDR : std_logic_vector(31 downto 0) := x"c0002128";
    constant C_eth_dst_mac_101_ADDR : std_logic_vector(31 downto 0) := x"c000212c";
    constant C_eth_dst_mac_102_ADDR : std_logic_vector(31 downto 0) := x"c0002130";
    constant C_eth_dst_mac_103_ADDR : std_logic_vector(31 downto 0) := x"c0002134";
    constant C_eth_dst_mac_104_ADDR : std_logic_vector(31 downto 0) := x"c0002138";
    constant C_eth_dst_mac_105_ADDR : std_logic_vector(31 downto 0) := x"c000213c";
    constant C_eth_dst_mac_106_ADDR : std_logic_vector(31 downto 0) := x"c0002140";
    constant C_eth_dst_mac_107_ADDR : std_logic_vector(31 downto 0) := x"c0002144";
    constant C_eth_dst_mac_108_ADDR : std_logic_vector(31 downto 0) := x"c0002148";
    constant C_eth_dst_mac_109_ADDR : std_logic_vector(31 downto 0) := x"c000214c";
    constant C_eth_dst_mac_110_ADDR : std_logic_vector(31 downto 0) := x"c0002150";
    constant C_eth_dst_mac_111_ADDR : std_logic_vector(31 downto 0) := x"c0002154";
    constant C_eth_dst_mac_112_ADDR : std_logic_vector(31 downto 0) := x"c0002158";
    constant C_eth_dst_mac_113_ADDR : std_logic_vector(31 downto 0) := x"c000215c";
    constant C_eth_dst_mac_114_ADDR : std_logic_vector(31 downto 0) := x"c0002160";
    constant C_eth_dst_mac_115_ADDR : std_logic_vector(31 downto 0) := x"c0002164";
    constant C_eth_dst_mac_116_ADDR : std_logic_vector(31 downto 0) := x"c0002168";
    constant C_eth_dst_mac_117_ADDR : std_logic_vector(31 downto 0) := x"c000216c";
    constant C_eth_dst_mac_118_ADDR : std_logic_vector(31 downto 0) := x"c0002170";
    constant C_eth_dst_mac_119_ADDR : std_logic_vector(31 downto 0) := x"c0002174";
    constant C_eth_dst_mac_120_ADDR : std_logic_vector(31 downto 0) := x"c0002178";
    constant C_eth_dst_mac_121_ADDR : std_logic_vector(31 downto 0) := x"c000217c";
    constant C_eth_dst_mac_122_ADDR : std_logic_vector(31 downto 0) := x"c0002180";
    constant C_eth_dst_mac_123_ADDR : std_logic_vector(31 downto 0) := x"c0002184";
    constant C_ip_src_addr_000_ADDR : std_logic_vector(31 downto 0) := x"c0002188";
    constant C_ip_src_addr_001_ADDR : std_logic_vector(31 downto 0) := x"c000218c";
    constant C_ip_src_addr_002_ADDR : std_logic_vector(31 downto 0) := x"c0002190";
    constant C_ip_src_addr_003_ADDR : std_logic_vector(31 downto 0) := x"c0002194";
    constant C_ip_src_addr_004_ADDR : std_logic_vector(31 downto 0) := x"c0002198";
    constant C_ip_src_addr_005_ADDR : std_logic_vector(31 downto 0) := x"c000219c";
    constant C_ip_src_addr_006_ADDR : std_logic_vector(31 downto 0) := x"c00021a0";
    constant C_ip_src_addr_007_ADDR : std_logic_vector(31 downto 0) := x"c00021a4";
    constant C_ip_src_addr_008_ADDR : std_logic_vector(31 downto 0) := x"c00021a8";
    constant C_ip_src_addr_009_ADDR : std_logic_vector(31 downto 0) := x"c00021ac";
    constant C_ip_src_addr_010_ADDR : std_logic_vector(31 downto 0) := x"c00021b0";
    constant C_ip_src_addr_011_ADDR : std_logic_vector(31 downto 0) := x"c00021b4";
    constant C_ip_src_addr_012_ADDR : std_logic_vector(31 downto 0) := x"c00021b8";
    constant C_ip_src_addr_013_ADDR : std_logic_vector(31 downto 0) := x"c00021bc";
    constant C_ip_src_addr_014_ADDR : std_logic_vector(31 downto 0) := x"c00021c0";
    constant C_ip_src_addr_015_ADDR : std_logic_vector(31 downto 0) := x"c00021c4";
    constant C_ip_src_addr_016_ADDR : std_logic_vector(31 downto 0) := x"c00021c8";
    constant C_ip_src_addr_017_ADDR : std_logic_vector(31 downto 0) := x"c00021cc";
    constant C_ip_src_addr_018_ADDR : std_logic_vector(31 downto 0) := x"c00021d0";
    constant C_ip_src_addr_019_ADDR : std_logic_vector(31 downto 0) := x"c00021d4";
    constant C_ip_src_addr_020_ADDR : std_logic_vector(31 downto 0) := x"c00021d8";
    constant C_ip_src_addr_021_ADDR : std_logic_vector(31 downto 0) := x"c00021dc";
    constant C_ip_src_addr_022_ADDR : std_logic_vector(31 downto 0) := x"c00021e0";
    constant C_ip_src_addr_023_ADDR : std_logic_vector(31 downto 0) := x"c00021e4";
    constant C_ip_src_addr_100_ADDR : std_logic_vector(31 downto 0) := x"c00021e8";
    constant C_ip_src_addr_101_ADDR : std_logic_vector(31 downto 0) := x"c00021ec";
    constant C_ip_src_addr_102_ADDR : std_logic_vector(31 downto 0) := x"c00021f0";
    constant C_ip_src_addr_103_ADDR : std_logic_vector(31 downto 0) := x"c00021f4";
    constant C_ip_src_addr_104_ADDR : std_logic_vector(31 downto 0) := x"c00021f8";
    constant C_ip_src_addr_105_ADDR : std_logic_vector(31 downto 0) := x"c00021fc";
    constant C_ip_src_addr_106_ADDR : std_logic_vector(31 downto 0) := x"c0002200";
    constant C_ip_src_addr_107_ADDR : std_logic_vector(31 downto 0) := x"c0002204";
    constant C_ip_src_addr_108_ADDR : std_logic_vector(31 downto 0) := x"c0002208";
    constant C_ip_src_addr_109_ADDR : std_logic_vector(31 downto 0) := x"c000220c";
    constant C_ip_src_addr_110_ADDR : std_logic_vector(31 downto 0) := x"c0002210";
    constant C_ip_src_addr_111_ADDR : std_logic_vector(31 downto 0) := x"c0002214";
    constant C_ip_src_addr_112_ADDR : std_logic_vector(31 downto 0) := x"c0002218";
    constant C_ip_src_addr_113_ADDR : std_logic_vector(31 downto 0) := x"c000221c";
    constant C_ip_src_addr_114_ADDR : std_logic_vector(31 downto 0) := x"c0002220";
    constant C_ip_src_addr_115_ADDR : std_logic_vector(31 downto 0) := x"c0002224";
    constant C_ip_src_addr_116_ADDR : std_logic_vector(31 downto 0) := x"c0002228";
    constant C_ip_src_addr_117_ADDR : std_logic_vector(31 downto 0) := x"c000222c";
    constant C_ip_src_addr_118_ADDR : std_logic_vector(31 downto 0) := x"c0002230";
    constant C_ip_src_addr_119_ADDR : std_logic_vector(31 downto 0) := x"c0002234";
    constant C_ip_src_addr_120_ADDR : std_logic_vector(31 downto 0) := x"c0002238";
    constant C_ip_src_addr_121_ADDR : std_logic_vector(31 downto 0) := x"c000223c";
    constant C_ip_src_addr_122_ADDR : std_logic_vector(31 downto 0) := x"c0002240";
    constant C_ip_src_addr_123_ADDR : std_logic_vector(31 downto 0) := x"c0002244";
    constant C_ip_dst_addr_000_ADDR : std_logic_vector(31 downto 0) := x"c0002248";
    constant C_ip_dst_addr_001_ADDR : std_logic_vector(31 downto 0) := x"c000224c";
    constant C_ip_dst_addr_002_ADDR : std_logic_vector(31 downto 0) := x"c0002250";
    constant C_ip_dst_addr_003_ADDR : std_logic_vector(31 downto 0) := x"c0002254";
    constant C_ip_dst_addr_004_ADDR : std_logic_vector(31 downto 0) := x"c0002258";
    constant C_ip_dst_addr_005_ADDR : std_logic_vector(31 downto 0) := x"c000225c";
    constant C_ip_dst_addr_006_ADDR : std_logic_vector(31 downto 0) := x"c0002260";
    constant C_ip_dst_addr_007_ADDR : std_logic_vector(31 downto 0) := x"c0002264";
    constant C_ip_dst_addr_008_ADDR : std_logic_vector(31 downto 0) := x"c0002268";
    constant C_ip_dst_addr_009_ADDR : std_logic_vector(31 downto 0) := x"c000226c";
    constant C_ip_dst_addr_010_ADDR : std_logic_vector(31 downto 0) := x"c0002270";
    constant C_ip_dst_addr_011_ADDR : std_logic_vector(31 downto 0) := x"c0002274";
    constant C_ip_dst_addr_012_ADDR : std_logic_vector(31 downto 0) := x"c0002278";
    constant C_ip_dst_addr_013_ADDR : std_logic_vector(31 downto 0) := x"c000227c";
    constant C_ip_dst_addr_014_ADDR : std_logic_vector(31 downto 0) := x"c0002280";
    constant C_ip_dst_addr_015_ADDR : std_logic_vector(31 downto 0) := x"c0002284";
    constant C_ip_dst_addr_016_ADDR : std_logic_vector(31 downto 0) := x"c0002288";
    constant C_ip_dst_addr_017_ADDR : std_logic_vector(31 downto 0) := x"c000228c";
    constant C_ip_dst_addr_018_ADDR : std_logic_vector(31 downto 0) := x"c0002290";
    constant C_ip_dst_addr_019_ADDR : std_logic_vector(31 downto 0) := x"c0002294";
    constant C_ip_dst_addr_020_ADDR : std_logic_vector(31 downto 0) := x"c0002298";
    constant C_ip_dst_addr_021_ADDR : std_logic_vector(31 downto 0) := x"c000229c";
    constant C_ip_dst_addr_022_ADDR : std_logic_vector(31 downto 0) := x"c00022a0";
    constant C_ip_dst_addr_023_ADDR : std_logic_vector(31 downto 0) := x"c00022a4";
    constant C_ip_dst_addr_100_ADDR : std_logic_vector(31 downto 0) := x"c00022a8";
    constant C_ip_dst_addr_101_ADDR : std_logic_vector(31 downto 0) := x"c00022ac";
    constant C_ip_dst_addr_102_ADDR : std_logic_vector(31 downto 0) := x"c00022b0";
    constant C_ip_dst_addr_103_ADDR : std_logic_vector(31 downto 0) := x"c00022b4";
    constant C_ip_dst_addr_104_ADDR : std_logic_vector(31 downto 0) := x"c00022b8";
    constant C_ip_dst_addr_105_ADDR : std_logic_vector(31 downto 0) := x"c00022bc";
    constant C_ip_dst_addr_106_ADDR : std_logic_vector(31 downto 0) := x"c00022c0";
    constant C_ip_dst_addr_107_ADDR : std_logic_vector(31 downto 0) := x"c00022c4";
    constant C_ip_dst_addr_108_ADDR : std_logic_vector(31 downto 0) := x"c00022c8";
    constant C_ip_dst_addr_109_ADDR : std_logic_vector(31 downto 0) := x"c00022cc";
    constant C_ip_dst_addr_110_ADDR : std_logic_vector(31 downto 0) := x"c00022d0";
    constant C_ip_dst_addr_111_ADDR : std_logic_vector(31 downto 0) := x"c00022d4";
    constant C_ip_dst_addr_112_ADDR : std_logic_vector(31 downto 0) := x"c00022d8";
    constant C_ip_dst_addr_113_ADDR : std_logic_vector(31 downto 0) := x"c00022dc";
    constant C_ip_dst_addr_114_ADDR : std_logic_vector(31 downto 0) := x"c00022e0";
    constant C_ip_dst_addr_115_ADDR : std_logic_vector(31 downto 0) := x"c00022e4";
    constant C_ip_dst_addr_116_ADDR : std_logic_vector(31 downto 0) := x"c00022e8";
    constant C_ip_dst_addr_117_ADDR : std_logic_vector(31 downto 0) := x"c00022ec";
    constant C_ip_dst_addr_118_ADDR : std_logic_vector(31 downto 0) := x"c00022f0";
    constant C_ip_dst_addr_119_ADDR : std_logic_vector(31 downto 0) := x"c00022f4";
    constant C_ip_dst_addr_120_ADDR : std_logic_vector(31 downto 0) := x"c00022f8";
    constant C_ip_dst_addr_121_ADDR : std_logic_vector(31 downto 0) := x"c00022fc";
    constant C_ip_dst_addr_122_ADDR : std_logic_vector(31 downto 0) := x"c0002300";
    constant C_ip_dst_addr_123_ADDR : std_logic_vector(31 downto 0) := x"c0002304";
    constant C_udp_src_port00_ADDR : std_logic_vector(31 downto 0) := x"c0002308";
    constant C_udp_src_port01_ADDR : std_logic_vector(31 downto 0) := x"c000230c";
    constant C_udp_src_port02_ADDR : std_logic_vector(31 downto 0) := x"c0002310";
    constant C_udp_src_port03_ADDR : std_logic_vector(31 downto 0) := x"c0002314";
    constant C_udp_src_port04_ADDR : std_logic_vector(31 downto 0) := x"c0002318";
    constant C_udp_src_port05_ADDR : std_logic_vector(31 downto 0) := x"c000231c";
    constant C_udp_src_port06_ADDR : std_logic_vector(31 downto 0) := x"c0002320";
    constant C_udp_src_port07_ADDR : std_logic_vector(31 downto 0) := x"c0002324";
    constant C_udp_src_port08_ADDR : std_logic_vector(31 downto 0) := x"c0002328";
    constant C_udp_src_port09_ADDR : std_logic_vector(31 downto 0) := x"c000232c";
    constant C_udp_src_port10_ADDR : std_logic_vector(31 downto 0) := x"c0002330";
    constant C_udp_src_port11_ADDR : std_logic_vector(31 downto 0) := x"c0002334";
    constant C_udp_src_port12_ADDR : std_logic_vector(31 downto 0) := x"c0002338";
    constant C_udp_src_port13_ADDR : std_logic_vector(31 downto 0) := x"c000233c";
    constant C_udp_src_port14_ADDR : std_logic_vector(31 downto 0) := x"c0002340";
    constant C_udp_src_port15_ADDR : std_logic_vector(31 downto 0) := x"c0002344";
    constant C_udp_src_port16_ADDR : std_logic_vector(31 downto 0) := x"c0002348";
    constant C_udp_src_port17_ADDR : std_logic_vector(31 downto 0) := x"c000234c";
    constant C_udp_src_port18_ADDR : std_logic_vector(31 downto 0) := x"c0002350";
    constant C_udp_src_port19_ADDR : std_logic_vector(31 downto 0) := x"c0002354";
    constant C_udp_src_port20_ADDR : std_logic_vector(31 downto 0) := x"c0002358";
    constant C_udp_src_port21_ADDR : std_logic_vector(31 downto 0) := x"c000235c";
    constant C_udp_src_port22_ADDR : std_logic_vector(31 downto 0) := x"c0002360";
    constant C_udp_src_port23_ADDR : std_logic_vector(31 downto 0) := x"c0002364";
    constant C_udp_dst_port00_ADDR : std_logic_vector(31 downto 0) := x"c0002368";
    constant C_udp_dst_port01_ADDR : std_logic_vector(31 downto 0) := x"c000236c";
    constant C_udp_dst_port02_ADDR : std_logic_vector(31 downto 0) := x"c0002370";
    constant C_udp_dst_port03_ADDR : std_logic_vector(31 downto 0) := x"c0002374";
    constant C_udp_dst_port04_ADDR : std_logic_vector(31 downto 0) := x"c0002378";
    constant C_udp_dst_port05_ADDR : std_logic_vector(31 downto 0) := x"c000237c";
    constant C_udp_dst_port06_ADDR : std_logic_vector(31 downto 0) := x"c0002380";
    constant C_udp_dst_port07_ADDR : std_logic_vector(31 downto 0) := x"c0002384";
    constant C_udp_dst_port08_ADDR : std_logic_vector(31 downto 0) := x"c0002388";
    constant C_udp_dst_port09_ADDR : std_logic_vector(31 downto 0) := x"c000238c";
    constant C_udp_dst_port10_ADDR : std_logic_vector(31 downto 0) := x"c0002390";
    constant C_udp_dst_port11_ADDR : std_logic_vector(31 downto 0) := x"c0002394";
    constant C_udp_dst_port12_ADDR : std_logic_vector(31 downto 0) := x"c0002398";
    constant C_udp_dst_port13_ADDR : std_logic_vector(31 downto 0) := x"c000239c";
    constant C_udp_dst_port14_ADDR : std_logic_vector(31 downto 0) := x"c00023a0";
    constant C_udp_dst_port15_ADDR : std_logic_vector(31 downto 0) := x"c00023a4";
    constant C_udp_dst_port16_ADDR : std_logic_vector(31 downto 0) := x"c00023a8";
    constant C_udp_dst_port17_ADDR : std_logic_vector(31 downto 0) := x"c00023ac";
    constant C_udp_dst_port18_ADDR : std_logic_vector(31 downto 0) := x"c00023b0";
    constant C_udp_dst_port19_ADDR : std_logic_vector(31 downto 0) := x"c00023b4";
    constant C_udp_dst_port20_ADDR : std_logic_vector(31 downto 0) := x"c00023b8";
    constant C_udp_dst_port21_ADDR : std_logic_vector(31 downto 0) := x"c00023bc";
    constant C_udp_dst_port22_ADDR : std_logic_vector(31 downto 0) := x"c00023c0";
    constant C_udp_dst_port23_ADDR : std_logic_vector(31 downto 0) := x"c00023c4";
    constant C_ro_type00_ADDR : std_logic_vector(31 downto 0) := x"c00023c8";
    constant C_ro_type01_ADDR : std_logic_vector(31 downto 0) := x"c00023cc";
    constant C_ro_type02_ADDR : std_logic_vector(31 downto 0) := x"c00023d0";
    constant C_ro_type03_ADDR : std_logic_vector(31 downto 0) := x"c00023d4";
    constant C_ro_type04_ADDR : std_logic_vector(31 downto 0) := x"c00023d8";
    constant C_ro_type05_ADDR : std_logic_vector(31 downto 0) := x"c00023dc";
    constant C_ro_type06_ADDR : std_logic_vector(31 downto 0) := x"c00023e0";
    constant C_ro_type07_ADDR : std_logic_vector(31 downto 0) := x"c00023e4";
    constant C_ro_type08_ADDR : std_logic_vector(31 downto 0) := x"c00023e8";
    constant C_ro_type09_ADDR : std_logic_vector(31 downto 0) := x"c00023ec";
    constant C_ro_type10_ADDR : std_logic_vector(31 downto 0) := x"c00023f0";
    constant C_ro_type11_ADDR : std_logic_vector(31 downto 0) := x"c00023f4";
    constant C_ro_type12_ADDR : std_logic_vector(31 downto 0) := x"c00023f8";
    constant C_ro_type13_ADDR : std_logic_vector(31 downto 0) := x"c00023fc";
    constant C_ro_type14_ADDR : std_logic_vector(31 downto 0) := x"c0002400";
    constant C_ro_type15_ADDR : std_logic_vector(31 downto 0) := x"c0002404";
    constant C_ro_type16_ADDR : std_logic_vector(31 downto 0) := x"c0002408";
    constant C_ro_type17_ADDR : std_logic_vector(31 downto 0) := x"c000240c";
    constant C_ro_type18_ADDR : std_logic_vector(31 downto 0) := x"c0002410";
    constant C_ro_type19_ADDR : std_logic_vector(31 downto 0) := x"c0002414";
    constant C_ro_type20_ADDR : std_logic_vector(31 downto 0) := x"c0002418";
    constant C_ro_type21_ADDR : std_logic_vector(31 downto 0) := x"c000241c";
    constant C_ro_type22_ADDR : std_logic_vector(31 downto 0) := x"c0002420";
    constant C_ro_type23_ADDR : std_logic_vector(31 downto 0) := x"c0002424";
    constant C_timeout00_ADDR : std_logic_vector(31 downto 0) := x"c0002428";
    constant C_timeout01_ADDR : std_logic_vector(31 downto 0) := x"c000242c";
    constant C_timeout02_ADDR : std_logic_vector(31 downto 0) := x"c0002430";
    constant C_timeout03_ADDR : std_logic_vector(31 downto 0) := x"c0002434";
    constant C_timeout04_ADDR : std_logic_vector(31 downto 0) := x"c0002438";
    constant C_timeout05_ADDR : std_logic_vector(31 downto 0) := x"c000243c";
    constant C_timeout06_ADDR : std_logic_vector(31 downto 0) := x"c0002440";
    constant C_timeout07_ADDR : std_logic_vector(31 downto 0) := x"c0002444";
    constant C_timeout08_ADDR : std_logic_vector(31 downto 0) := x"c0002448";
    constant C_timeout09_ADDR : std_logic_vector(31 downto 0) := x"c000244c";
    constant C_timeout10_ADDR : std_logic_vector(31 downto 0) := x"c0002450";
    constant C_timeout11_ADDR : std_logic_vector(31 downto 0) := x"c0002454";
    constant C_timeout12_ADDR : std_logic_vector(31 downto 0) := x"c0002458";
    constant C_timeout13_ADDR : std_logic_vector(31 downto 0) := x"c000245c";
    constant C_timeout14_ADDR : std_logic_vector(31 downto 0) := x"c0002460";
    constant C_timeout15_ADDR : std_logic_vector(31 downto 0) := x"c0002464";
    constant C_timeout16_ADDR : std_logic_vector(31 downto 0) := x"c0002468";
    constant C_timeout17_ADDR : std_logic_vector(31 downto 0) := x"c000246c";
    constant C_timeout18_ADDR : std_logic_vector(31 downto 0) := x"c0002470";
    constant C_timeout19_ADDR : std_logic_vector(31 downto 0) := x"c0002474";
    constant C_timeout20_ADDR : std_logic_vector(31 downto 0) := x"c0002478";
    constant C_timeout21_ADDR : std_logic_vector(31 downto 0) := x"c000247c";
    constant C_timeout22_ADDR : std_logic_vector(31 downto 0) := x"c0002480";
    constant C_timeout23_ADDR : std_logic_vector(31 downto 0) := x"c0002484";
    constant C_eng_enable_ADDR : std_logic_vector(31 downto 0) := x"c0002488";
    constant C_reformat_ADDR : std_logic_vector(31 downto 0) := x"c000248c";
    constant C_pkt_gen_enable_ADDR : std_logic_vector(31 downto 0) := x"c0002490";
    constant C_pkt_gen_idles00_ADDR : std_logic_vector(31 downto 0) := x"c0002494";
    constant C_pkt_gen_idles01_ADDR : std_logic_vector(31 downto 0) := x"c0002498";
    constant C_pkt_gen_idles02_ADDR : std_logic_vector(31 downto 0) := x"c000249c";
    constant C_pkt_gen_idles03_ADDR : std_logic_vector(31 downto 0) := x"c00024a0";
    constant C_pkt_gen_idles04_ADDR : std_logic_vector(31 downto 0) := x"c00024a4";
    constant C_pkt_gen_idles05_ADDR : std_logic_vector(31 downto 0) := x"c00024a8";
    constant C_pkt_gen_idles06_ADDR : std_logic_vector(31 downto 0) := x"c00024ac";
    constant C_pkt_gen_idles07_ADDR : std_logic_vector(31 downto 0) := x"c00024b0";
    constant C_pkt_gen_idles08_ADDR : std_logic_vector(31 downto 0) := x"c00024b4";
    constant C_pkt_gen_idles09_ADDR : std_logic_vector(31 downto 0) := x"c00024b8";
    constant C_pkt_gen_idles10_ADDR : std_logic_vector(31 downto 0) := x"c00024bc";
    constant C_pkt_gen_idles11_ADDR : std_logic_vector(31 downto 0) := x"c00024c0";
    constant C_pkt_gen_idles12_ADDR : std_logic_vector(31 downto 0) := x"c00024c4";
    constant C_pkt_gen_idles13_ADDR : std_logic_vector(31 downto 0) := x"c00024c8";
    constant C_pkt_gen_idles14_ADDR : std_logic_vector(31 downto 0) := x"c00024cc";
    constant C_pkt_gen_idles15_ADDR : std_logic_vector(31 downto 0) := x"c00024d0";
    constant C_pkt_gen_idles16_ADDR : std_logic_vector(31 downto 0) := x"c00024d4";
    constant C_pkt_gen_idles17_ADDR : std_logic_vector(31 downto 0) := x"c00024d8";
    constant C_pkt_gen_idles18_ADDR : std_logic_vector(31 downto 0) := x"c00024dc";
    constant C_pkt_gen_idles19_ADDR : std_logic_vector(31 downto 0) := x"c00024e0";
    constant C_pkt_gen_idles20_ADDR : std_logic_vector(31 downto 0) := x"c00024e4";
    constant C_pkt_gen_idles21_ADDR : std_logic_vector(31 downto 0) := x"c00024e8";
    constant C_pkt_gen_idles22_ADDR : std_logic_vector(31 downto 0) := x"c00024ec";
    constant C_pkt_gen_idles23_ADDR : std_logic_vector(31 downto 0) := x"c00024f0";
    constant C_pkt_gen_length00_ADDR : std_logic_vector(31 downto 0) := x"c00024f4";
    constant C_pkt_gen_length01_ADDR : std_logic_vector(31 downto 0) := x"c00024f8";
    constant C_pkt_gen_length02_ADDR : std_logic_vector(31 downto 0) := x"c00024fc";
    constant C_pkt_gen_length03_ADDR : std_logic_vector(31 downto 0) := x"c0002500";
    constant C_pkt_gen_length04_ADDR : std_logic_vector(31 downto 0) := x"c0002504";
    constant C_pkt_gen_length05_ADDR : std_logic_vector(31 downto 0) := x"c0002508";
    constant C_pkt_gen_length06_ADDR : std_logic_vector(31 downto 0) := x"c000250c";
    constant C_pkt_gen_length07_ADDR : std_logic_vector(31 downto 0) := x"c0002510";
    constant C_pkt_gen_length08_ADDR : std_logic_vector(31 downto 0) := x"c0002514";
    constant C_pkt_gen_length09_ADDR : std_logic_vector(31 downto 0) := x"c0002518";
    constant C_pkt_gen_length10_ADDR : std_logic_vector(31 downto 0) := x"c000251c";
    constant C_pkt_gen_length11_ADDR : std_logic_vector(31 downto 0) := x"c0002520";
    constant C_pkt_gen_length12_ADDR : std_logic_vector(31 downto 0) := x"c0002524";
    constant C_pkt_gen_length13_ADDR : std_logic_vector(31 downto 0) := x"c0002528";
    constant C_pkt_gen_length14_ADDR : std_logic_vector(31 downto 0) := x"c000252c";
    constant C_pkt_gen_length15_ADDR : std_logic_vector(31 downto 0) := x"c0002530";
    constant C_pkt_gen_length16_ADDR : std_logic_vector(31 downto 0) := x"c0002534";
    constant C_pkt_gen_length17_ADDR : std_logic_vector(31 downto 0) := x"c0002538";
    constant C_pkt_gen_length18_ADDR : std_logic_vector(31 downto 0) := x"c000253c";
    constant C_pkt_gen_length19_ADDR : std_logic_vector(31 downto 0) := x"c0002540";
    constant C_pkt_gen_length20_ADDR : std_logic_vector(31 downto 0) := x"c0002544";
    constant C_pkt_gen_length21_ADDR : std_logic_vector(31 downto 0) := x"c0002548";
    constant C_pkt_gen_length22_ADDR : std_logic_vector(31 downto 0) := x"c000254c";
    constant C_pkt_gen_length23_ADDR : std_logic_vector(31 downto 0) := x"c0002550";

end package;
