-- Register map generated at: 05/03/2020 11:55:28
-- using: /home/jgc87821/ess/harmonized/src/reg_parse.py
-- Register definition file: ../param_map/param_map_eng.json
-- Project: Detector Group Readout Master
-- Register space: Packet Engine Configuration Register Register Space (Master)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.eng_regs_mst_pkg.all;
use work.axi4lite_pkg.all;

entity eng_regs_mst is
generic (
    C_AXI_ADDR_WIDTH : integer := 32;
    C_AXI_DATA_WIDTH : integer := 32
);
port (
    S_AXI_ACLK     : in  std_logic;
    S_AXI_ARESETN  : in  std_logic;
    S_AXI_SIGS_IN  : in  t_axi4lite_mosi;
    S_AXI_SIGS_OUT : out t_axi4lite_miso;
    RO_REGS_IN     : in  t_eng_regs_mst_ro;
    RW_REGS_OUT    : out t_eng_regs_mst_rw
);
end eng_regs_mst;

architecture behavioral of eng_regs_mst is

    constant C_EMPTY_STATUS : std_logic_vector(32-1 downto 0) := x"ba_ad_ba_ad";
    -- formula used by Python script is C_AXI_DATA_WIDTH/2 + 1
    -- not done directly in VHDL becuase generics can't be used in case statements
    constant C_ADDR_LSB : integer := 2;
    constant C_OPT_ADDR_BITS : integer := 9;
    constant C_ADDR_MSB : integer := C_OPT_ADDR_BITS + C_ADDR_LSB;

    -- internal AXI4LITE signals
    signal axi_awaddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_awready  : std_logic;
    signal axi_wready   : std_logic;
    signal axi_bresp    : std_logic_vector(1 downto 0);
    signal axi_bvalid   : std_logic;
    signal axi_araddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_arready  : std_logic;
    signal axi_rdata    : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
    signal axi_rdata_r  : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
    signal axi_rresp    : std_logic_vector(1 downto 0);
    signal axi_rvalid   : std_logic;

    -- internal register signals
    signal ro_regs      : t_eng_regs_mst_ro;
    signal rw_regs      : t_eng_regs_mst_rw;
    signal reg_rden     : std_logic;
    signal reg_wren     : std_logic;
    signal reg_dout     : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
    signal reg_byte_ind : integer;
    signal reg_aw_en    : std_logic;

begin

    S_AXI_SIGS_OUT.awready <= axi_awready;
    S_AXI_SIGS_OUT.wready  <= axi_wready;
    S_AXI_SIGS_OUT.bresp   <= axi_bresp;
    S_AXI_SIGS_OUT.bvalid  <= axi_bvalid;
    S_AXI_SIGS_OUT.arready <= axi_arready;
    S_AXI_SIGS_OUT.rdata   <= axi_rdata_r;
    S_AXI_SIGS_OUT.rresp   <= axi_rresp;
    S_AXI_SIGS_OUT.rvalid  <= axi_rvalid;

    -- AXI Write infrastructure

    RW_REGS_OUT <= rw_regs;

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_awready <= '0';
                reg_aw_en   <= '1';
            else
                if axi_awready = '0' and S_AXI_SIGS_IN.awvalid = '1' and S_AXI_SIGS_IN.wvalid = '1' and reg_aw_en = '1' then
                    axi_awready <= '1';
                elsif S_AXI_SIGS_IN.bready = '1' and axi_bvalid = '1' then
                    reg_aw_en   <= '1';
                    axi_awready <= '0';
                else
                    axi_awready <= '0';
                end if;
            end if;
        end if;
    end process;

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_awaddr <= (others => '0');
            else
                if axi_awready = '0' and S_AXI_SIGS_IN.awvalid = '1' and S_AXI_SIGS_IN.wvalid = '1' and reg_aw_en = '1' then
                    axi_awaddr <= S_AXI_SIGS_IN.awaddr;
                end if;
            end if;
        end if;
    end process;

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_wready <= '0';
            else
                if axi_wready = '0' and S_AXI_SIGS_IN.wvalid = '1' and S_AXI_SIGS_IN.awvalid = '1' and reg_aw_en = '1' then
                    axi_wready <= '1';
                else
                    axi_wready <= '0';
                end if;
            end if;
        end if;
    end process;

    reg_wren <= axi_wready and S_AXI_SIGS_IN.wvalid and axi_awready and S_AXI_SIGS_IN.awvalid;

    -- AXI Register Write Process

    process(S_AXI_ACLK)
        variable loc_addr : std_logic_vector(C_OPT_ADDR_BITS downto 0);
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                ro_regs <= RO_REGS_IN;
                rw_regs <= C_ENG_REGS_MST_RW;
            else
                -- Register the external (engine etc.) values into the ro registers every cycle
                ro_regs <= RO_REGS_IN;
                loc_addr := axi_awaddr(C_ADDR_MSB downto C_ADDR_LSB);
                if reg_wren = '1' then
                    -- read-only registers not included here
                    case loc_addr is
                        -- x"c0002000", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_000_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002004", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_001_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002008", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_002_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000200c", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_003_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002010", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_004_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002014", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_005_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002018", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_006_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000201c", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_007_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002020", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_008_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002024", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_009_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002028", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_010_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000202c", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_011_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002030", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_012_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002034", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_013_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002038", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_014_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000203c", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_015_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002040", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_016_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002044", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_017_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002048", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_018_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000204c", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_019_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002050", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_020_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002054", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_021_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002058", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_022_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000205c", Lower 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_023_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_0xx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002060", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_100_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002064", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_101_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002068", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_102_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000206c", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_103_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002070", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_104_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002074", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_105_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002078", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_106_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000207c", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_107_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002080", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_108_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002084", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_109_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002088", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_110_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000208c", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_111_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002090", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_112_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002094", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_113_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002098", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_114_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000209c", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_115_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020a0", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_116_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020a4", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_117_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020a8", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_118_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020ac", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_119_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020b0", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_120_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020b4", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_121_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020b8", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_122_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020bc", Upper 32 bits of Bulk data Ethernet source MAC address
                        when C_eth_src_mac_123_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_src_mac_1xx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020c0", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_000_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020c4", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_001_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020c8", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_002_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020cc", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_003_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020d0", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_004_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020d4", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_005_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020d8", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_006_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020dc", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_007_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020e0", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_008_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020e4", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_009_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020e8", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_010_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020ec", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_011_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020f0", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_012_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020f4", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_013_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020f8", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_014_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00020fc", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_015_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002100", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_016_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002104", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_017_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002108", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_018_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000210c", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_019_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002110", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_020_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002114", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_021_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002118", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_022_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000211c", Lower 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_023_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_0xx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002120", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_100_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002124", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_101_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002128", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_102_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000212c", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_103_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002130", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_104_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002134", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_105_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002138", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_106_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000213c", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_107_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002140", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_108_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002144", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_109_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002148", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_110_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000214c", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_111_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002150", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_112_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002154", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_113_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002158", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_114_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000215c", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_115_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002160", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_116_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002164", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_117_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002168", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_118_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000216c", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_119_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002170", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_120_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002174", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_121_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002178", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_122_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000217c", Upper 32 bits of Bulk data Ethernet destination MAC address
                        when C_eth_dst_mac_123_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eth_dst_mac_1xx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002180", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_000_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002184", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_001_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002188", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_002_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000218c", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_003_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002190", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_004_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002194", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_005_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002198", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_006_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000219c", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_007_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021a0", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_008_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021a4", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_009_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021a8", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_010_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021ac", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_011_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021b0", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_012_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021b4", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_013_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021b8", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_014_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021bc", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_015_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021c0", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_016_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021c4", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_017_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021c8", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_018_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021cc", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_019_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021d0", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_020_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021d4", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_021_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021d8", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_022_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021dc", Lower 32 bits of Bulk data IP source address
                        when C_ip_src_addr_023_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_0xx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021e0", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_100_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021e4", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_101_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021e8", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_102_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021ec", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_103_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021f0", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_104_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021f4", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_105_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021f8", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_106_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00021fc", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_107_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002200", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_108_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002204", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_109_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002208", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_110_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000220c", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_111_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002210", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_112_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002214", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_113_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002218", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_114_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000221c", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_115_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002220", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_116_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002224", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_117_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002228", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_118_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000222c", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_119_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002230", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_120_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002234", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_121_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002238", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_122_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000223c", Upper 32 bits of Bulk data IP source address
                        when C_ip_src_addr_123_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_src_addr_1xx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002240", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_000_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002244", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_001_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002248", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_002_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000224c", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_003_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002250", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_004_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002254", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_005_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002258", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_006_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000225c", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_007_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002260", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_008_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002264", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_009_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002268", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_010_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000226c", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_011_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002270", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_012_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002274", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_013_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002278", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_014_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000227c", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_015_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002280", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_016_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002284", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_017_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002288", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_018_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000228c", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_019_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002290", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_020_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002294", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_021_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002298", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_022_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000229c", Lower 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_023_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_0xx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022a0", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_100_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022a4", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_101_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022a8", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_102_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022ac", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_103_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022b0", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_104_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022b4", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_105_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022b8", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_106_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022bc", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_107_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022c0", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_108_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022c4", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_109_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022c8", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_110_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022cc", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_111_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022d0", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_112_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022d4", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_113_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022d8", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_114_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022dc", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_115_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022e0", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_116_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022e4", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_117_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022e8", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_118_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022ec", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_119_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022f0", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_120_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022f4", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_121_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022f8", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_122_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00022fc", Upper 32 bits of Bulk data IP destination address
                        when C_ip_dst_addr_123_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ip_dst_addr_1xx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002300", Bulk data UDP source port
                        when C_udp_src_port00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002304", Bulk data UDP source port
                        when C_udp_src_port01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002308", Bulk data UDP source port
                        when C_udp_src_port02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000230c", Bulk data UDP source port
                        when C_udp_src_port03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002310", Bulk data UDP source port
                        when C_udp_src_port04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002314", Bulk data UDP source port
                        when C_udp_src_port05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002318", Bulk data UDP source port
                        when C_udp_src_port06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000231c", Bulk data UDP source port
                        when C_udp_src_port07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002320", Bulk data UDP source port
                        when C_udp_src_port08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002324", Bulk data UDP source port
                        when C_udp_src_port09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002328", Bulk data UDP source port
                        when C_udp_src_port10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000232c", Bulk data UDP source port
                        when C_udp_src_port11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002330", Bulk data UDP source port
                        when C_udp_src_port12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002334", Bulk data UDP source port
                        when C_udp_src_port13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002338", Bulk data UDP source port
                        when C_udp_src_port14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000233c", Bulk data UDP source port
                        when C_udp_src_port15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002340", Bulk data UDP source port
                        when C_udp_src_port16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002344", Bulk data UDP source port
                        when C_udp_src_port17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002348", Bulk data UDP source port
                        when C_udp_src_port18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000234c", Bulk data UDP source port
                        when C_udp_src_port19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002350", Bulk data UDP source port
                        when C_udp_src_port20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002354", Bulk data UDP source port
                        when C_udp_src_port21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002358", Bulk data UDP source port
                        when C_udp_src_port22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000235c", Bulk data UDP source port
                        when C_udp_src_port23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_src_portxx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002360", Bulk data UDP destination port
                        when C_udp_dst_port00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002364", Bulk data UDP destination port
                        when C_udp_dst_port01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002368", Bulk data UDP destination port
                        when C_udp_dst_port02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000236c", Bulk data UDP destination port
                        when C_udp_dst_port03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002370", Bulk data UDP destination port
                        when C_udp_dst_port04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002374", Bulk data UDP destination port
                        when C_udp_dst_port05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002378", Bulk data UDP destination port
                        when C_udp_dst_port06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000237c", Bulk data UDP destination port
                        when C_udp_dst_port07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002380", Bulk data UDP destination port
                        when C_udp_dst_port08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002384", Bulk data UDP destination port
                        when C_udp_dst_port09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002388", Bulk data UDP destination port
                        when C_udp_dst_port10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000238c", Bulk data UDP destination port
                        when C_udp_dst_port11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002390", Bulk data UDP destination port
                        when C_udp_dst_port12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002394", Bulk data UDP destination port
                        when C_udp_dst_port13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002398", Bulk data UDP destination port
                        when C_udp_dst_port14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000239c", Bulk data UDP destination port
                        when C_udp_dst_port15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023a0", Bulk data UDP destination port
                        when C_udp_dst_port16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023a4", Bulk data UDP destination port
                        when C_udp_dst_port17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023a8", Bulk data UDP destination port
                        when C_udp_dst_port18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023ac", Bulk data UDP destination port
                        when C_udp_dst_port19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023b0", Bulk data UDP destination port
                        when C_udp_dst_port20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023b4", Bulk data UDP destination port
                        when C_udp_dst_port21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023b8", Bulk data UDP destination port
                        when C_udp_dst_port22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023bc", Bulk data UDP destination port
                        when C_udp_dst_port23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.udp_dst_portxx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023c0", Bulk data packet readout packet type
                        when C_ro_type00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023c4", Bulk data packet readout packet type
                        when C_ro_type01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023c8", Bulk data packet readout packet type
                        when C_ro_type02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023cc", Bulk data packet readout packet type
                        when C_ro_type03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023d0", Bulk data packet readout packet type
                        when C_ro_type04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023d4", Bulk data packet readout packet type
                        when C_ro_type05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023d8", Bulk data packet readout packet type
                        when C_ro_type06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023dc", Bulk data packet readout packet type
                        when C_ro_type07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023e0", Bulk data packet readout packet type
                        when C_ro_type08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023e4", Bulk data packet readout packet type
                        when C_ro_type09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023e8", Bulk data packet readout packet type
                        when C_ro_type10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023ec", Bulk data packet readout packet type
                        when C_ro_type11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023f0", Bulk data packet readout packet type
                        when C_ro_type12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023f4", Bulk data packet readout packet type
                        when C_ro_type13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023f8", Bulk data packet readout packet type
                        when C_ro_type14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00023fc", Bulk data packet readout packet type
                        when C_ro_type15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002400", Bulk data packet readout packet type
                        when C_ro_type16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002404", Bulk data packet readout packet type
                        when C_ro_type17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002408", Bulk data packet readout packet type
                        when C_ro_type18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000240c", Bulk data packet readout packet type
                        when C_ro_type19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002410", Bulk data packet readout packet type
                        when C_ro_type20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002414", Bulk data packet readout packet type
                        when C_ro_type21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002418", Bulk data packet readout packet type
                        when C_ro_type22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000241c", Bulk data packet readout packet type
                        when C_ro_type23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.ro_typexx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002420", Bulk data timeout (deprecated)
                        when C_timeout00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002424", Bulk data timeout (deprecated)
                        when C_timeout01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002428", Bulk data timeout (deprecated)
                        when C_timeout02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000242c", Bulk data timeout (deprecated)
                        when C_timeout03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002430", Bulk data timeout (deprecated)
                        when C_timeout04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002434", Bulk data timeout (deprecated)
                        when C_timeout05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002438", Bulk data timeout (deprecated)
                        when C_timeout06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000243c", Bulk data timeout (deprecated)
                        when C_timeout07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002440", Bulk data timeout (deprecated)
                        when C_timeout08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002444", Bulk data timeout (deprecated)
                        when C_timeout09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002448", Bulk data timeout (deprecated)
                        when C_timeout10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000244c", Bulk data timeout (deprecated)
                        when C_timeout11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002450", Bulk data timeout (deprecated)
                        when C_timeout12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002454", Bulk data timeout (deprecated)
                        when C_timeout13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002458", Bulk data timeout (deprecated)
                        when C_timeout14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000245c", Bulk data timeout (deprecated)
                        when C_timeout15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002460", Bulk data timeout (deprecated)
                        when C_timeout16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002464", Bulk data timeout (deprecated)
                        when C_timeout17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002468", Bulk data timeout (deprecated)
                        when C_timeout18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000246c", Bulk data timeout (deprecated)
                        when C_timeout19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002470", Bulk data timeout (deprecated)
                        when C_timeout20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002474", Bulk data timeout (deprecated)
                        when C_timeout21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002478", Bulk data timeout (deprecated)
                        when C_timeout22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000247c", Bulk data timeout (deprecated)
                        when C_timeout23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.timeoutxx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002480", Packet engine enable bitmask
                        when C_eng_enable_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.eng_enable(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002484", Reformat FEA header to DMSC format
                        when C_reformat_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.reformat(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002488", Test data enable bitmask
                        when C_pkt_gen_enable_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_enable(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000248c", Test data inter-packet idles
                        when C_pkt_gen_idles00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002490", Test data inter-packet idles
                        when C_pkt_gen_idles01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002494", Test data inter-packet idles
                        when C_pkt_gen_idles02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002498", Test data inter-packet idles
                        when C_pkt_gen_idles03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000249c", Test data inter-packet idles
                        when C_pkt_gen_idles04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024a0", Test data inter-packet idles
                        when C_pkt_gen_idles05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024a4", Test data inter-packet idles
                        when C_pkt_gen_idles06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024a8", Test data inter-packet idles
                        when C_pkt_gen_idles07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024ac", Test data inter-packet idles
                        when C_pkt_gen_idles08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024b0", Test data inter-packet idles
                        when C_pkt_gen_idles09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024b4", Test data inter-packet idles
                        when C_pkt_gen_idles10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024b8", Test data inter-packet idles
                        when C_pkt_gen_idles11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024bc", Test data inter-packet idles
                        when C_pkt_gen_idles12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024c0", Test data inter-packet idles
                        when C_pkt_gen_idles13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024c4", Test data inter-packet idles
                        when C_pkt_gen_idles14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024c8", Test data inter-packet idles
                        when C_pkt_gen_idles15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024cc", Test data inter-packet idles
                        when C_pkt_gen_idles16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024d0", Test data inter-packet idles
                        when C_pkt_gen_idles17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024d4", Test data inter-packet idles
                        when C_pkt_gen_idles18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024d8", Test data inter-packet idles
                        when C_pkt_gen_idles19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024dc", Test data inter-packet idles
                        when C_pkt_gen_idles20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024e0", Test data inter-packet idles
                        when C_pkt_gen_idles21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024e4", Test data inter-packet idles
                        when C_pkt_gen_idles22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024e8", Test data inter-packet idles
                        when C_pkt_gen_idles23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_idlesxx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024ec", Test data packet length
                        when C_pkt_gen_length00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024f0", Test data packet length
                        when C_pkt_gen_length01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024f4", Test data packet length
                        when C_pkt_gen_length02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024f8", Test data packet length
                        when C_pkt_gen_length03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00024fc", Test data packet length
                        when C_pkt_gen_length04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002500", Test data packet length
                        when C_pkt_gen_length05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002504", Test data packet length
                        when C_pkt_gen_length06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002508", Test data packet length
                        when C_pkt_gen_length07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000250c", Test data packet length
                        when C_pkt_gen_length08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002510", Test data packet length
                        when C_pkt_gen_length09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002514", Test data packet length
                        when C_pkt_gen_length10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002518", Test data packet length
                        when C_pkt_gen_length11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000251c", Test data packet length
                        when C_pkt_gen_length12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002520", Test data packet length
                        when C_pkt_gen_length13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002524", Test data packet length
                        when C_pkt_gen_length14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002528", Test data packet length
                        when C_pkt_gen_length15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000252c", Test data packet length
                        when C_pkt_gen_length16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002530", Test data packet length
                        when C_pkt_gen_length17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002534", Test data packet length
                        when C_pkt_gen_length18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002538", Test data packet length
                        when C_pkt_gen_length19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000253c", Test data packet length
                        when C_pkt_gen_length20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002540", Test data packet length
                        when C_pkt_gen_length21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002544", Test data packet length
                        when C_pkt_gen_length22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0002548", Test data packet length
                        when C_pkt_gen_length23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.pkt_gen_lengthxx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        when others => 
                            -- null
                    end case;
                end if;
            end if;
        end if;
    end process;

    -- AXI Read infrastructure

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_bvalid <= '0';
                axi_bresp  <= "00"; --need to work more on the responses
            else
                if axi_awready = '1' and S_AXI_SIGS_IN.awvalid = '1' and axi_wready = '1' and S_AXI_SIGS_IN.wvalid = '1' and axi_bvalid = '0' then
                    axi_bvalid <= '1';
                    axi_bresp  <= "00";
                elsif S_AXI_SIGS_IN.bready = '1' and axi_bvalid = '1' then -- check if bready is asserted while bvalid is high
                    axi_bvalid <= '0';                             -- (there is a possibility that bready is always asserted high)
                end if;
            end if;
        end if;
    end process;

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_arready <= '0';
                axi_araddr  <= (others => '1');
            else
                if axi_arready = '0' and S_AXI_SIGS_IN.arvalid = '1' then
                    axi_arready <= '1';
                    axi_araddr  <= S_AXI_SIGS_IN.araddr;
                else
                    axi_arready <= '0';
                end if;
            end if;
        end if;
    end process;

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_rvalid <= '0';
                axi_rresp  <= "00";
            else
                if axi_arready = '1' and S_AXI_SIGS_IN.arvalid = '1' and axi_rvalid = '0' then
                    axi_rvalid <= '1';
                    axi_rresp  <= "00"; -- 'OKAY' response
                elsif axi_rvalid = '1' and S_AXI_SIGS_IN.rready = '1' then
                    axi_rvalid <= '0';
                end if;
            end if;
        end if;
    end process;

    reg_rden <= axi_arready and S_AXI_SIGS_IN.arvalid and (not axi_rvalid);

    process(S_AXI_ACLK) is
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_rdata_r <= (others => '0');
            else
                if reg_rden = '1' then
                    axi_rdata_r <= axi_rdata;
                end if;
            end if;
        end if;
    end process;

    -- AXI Register Read Process

    process(ro_regs, rw_regs, axi_araddr, S_AXI_ARESETN, reg_rden) is
        variable loc_addr :std_logic_vector(C_OPT_ADDR_BITS downto 0);
    begin
        -- Address decoding for reading registers
        loc_addr := axi_araddr(C_ADDR_MSB downto C_ADDR_LSB);
        case loc_addr is
            -- x"c0002000", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_000_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(00);
            -- x"c0002004", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_001_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(01);
            -- x"c0002008", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_002_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(02);
            -- x"c000200c", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_003_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(03);
            -- x"c0002010", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_004_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(04);
            -- x"c0002014", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_005_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(05);
            -- x"c0002018", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_006_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(06);
            -- x"c000201c", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_007_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(07);
            -- x"c0002020", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_008_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(08);
            -- x"c0002024", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_009_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(09);
            -- x"c0002028", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_010_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(10);
            -- x"c000202c", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_011_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(11);
            -- x"c0002030", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_012_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(12);
            -- x"c0002034", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_013_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(13);
            -- x"c0002038", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_014_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(14);
            -- x"c000203c", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_015_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(15);
            -- x"c0002040", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_016_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(16);
            -- x"c0002044", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_017_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(17);
            -- x"c0002048", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_018_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(18);
            -- x"c000204c", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_019_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(19);
            -- x"c0002050", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_020_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(20);
            -- x"c0002054", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_021_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(21);
            -- x"c0002058", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_022_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(22);
            -- x"c000205c", Lower 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_023_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_0xx(23);
            -- x"c0002060", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_100_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(00);
            -- x"c0002064", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_101_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(01);
            -- x"c0002068", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_102_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(02);
            -- x"c000206c", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_103_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(03);
            -- x"c0002070", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_104_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(04);
            -- x"c0002074", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_105_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(05);
            -- x"c0002078", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_106_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(06);
            -- x"c000207c", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_107_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(07);
            -- x"c0002080", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_108_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(08);
            -- x"c0002084", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_109_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(09);
            -- x"c0002088", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_110_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(10);
            -- x"c000208c", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_111_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(11);
            -- x"c0002090", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_112_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(12);
            -- x"c0002094", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_113_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(13);
            -- x"c0002098", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_114_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(14);
            -- x"c000209c", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_115_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(15);
            -- x"c00020a0", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_116_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(16);
            -- x"c00020a4", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_117_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(17);
            -- x"c00020a8", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_118_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(18);
            -- x"c00020ac", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_119_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(19);
            -- x"c00020b0", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_120_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(20);
            -- x"c00020b4", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_121_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(21);
            -- x"c00020b8", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_122_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(22);
            -- x"c00020bc", Upper 32 bits of Bulk data Ethernet source MAC address
            when C_eth_src_mac_123_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_src_mac_1xx(23);
            -- x"c00020c0", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_000_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(00);
            -- x"c00020c4", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_001_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(01);
            -- x"c00020c8", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_002_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(02);
            -- x"c00020cc", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_003_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(03);
            -- x"c00020d0", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_004_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(04);
            -- x"c00020d4", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_005_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(05);
            -- x"c00020d8", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_006_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(06);
            -- x"c00020dc", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_007_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(07);
            -- x"c00020e0", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_008_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(08);
            -- x"c00020e4", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_009_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(09);
            -- x"c00020e8", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_010_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(10);
            -- x"c00020ec", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_011_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(11);
            -- x"c00020f0", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_012_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(12);
            -- x"c00020f4", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_013_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(13);
            -- x"c00020f8", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_014_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(14);
            -- x"c00020fc", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_015_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(15);
            -- x"c0002100", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_016_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(16);
            -- x"c0002104", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_017_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(17);
            -- x"c0002108", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_018_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(18);
            -- x"c000210c", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_019_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(19);
            -- x"c0002110", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_020_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(20);
            -- x"c0002114", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_021_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(21);
            -- x"c0002118", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_022_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(22);
            -- x"c000211c", Lower 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_023_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_0xx(23);
            -- x"c0002120", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_100_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(00);
            -- x"c0002124", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_101_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(01);
            -- x"c0002128", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_102_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(02);
            -- x"c000212c", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_103_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(03);
            -- x"c0002130", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_104_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(04);
            -- x"c0002134", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_105_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(05);
            -- x"c0002138", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_106_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(06);
            -- x"c000213c", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_107_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(07);
            -- x"c0002140", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_108_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(08);
            -- x"c0002144", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_109_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(09);
            -- x"c0002148", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_110_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(10);
            -- x"c000214c", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_111_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(11);
            -- x"c0002150", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_112_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(12);
            -- x"c0002154", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_113_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(13);
            -- x"c0002158", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_114_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(14);
            -- x"c000215c", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_115_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(15);
            -- x"c0002160", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_116_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(16);
            -- x"c0002164", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_117_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(17);
            -- x"c0002168", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_118_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(18);
            -- x"c000216c", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_119_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(19);
            -- x"c0002170", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_120_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(20);
            -- x"c0002174", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_121_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(21);
            -- x"c0002178", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_122_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(22);
            -- x"c000217c", Upper 32 bits of Bulk data Ethernet destination MAC address
            when C_eth_dst_mac_123_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eth_dst_mac_1xx(23);
            -- x"c0002180", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_000_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(00);
            -- x"c0002184", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_001_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(01);
            -- x"c0002188", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_002_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(02);
            -- x"c000218c", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_003_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(03);
            -- x"c0002190", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_004_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(04);
            -- x"c0002194", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_005_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(05);
            -- x"c0002198", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_006_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(06);
            -- x"c000219c", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_007_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(07);
            -- x"c00021a0", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_008_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(08);
            -- x"c00021a4", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_009_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(09);
            -- x"c00021a8", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_010_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(10);
            -- x"c00021ac", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_011_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(11);
            -- x"c00021b0", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_012_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(12);
            -- x"c00021b4", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_013_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(13);
            -- x"c00021b8", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_014_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(14);
            -- x"c00021bc", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_015_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(15);
            -- x"c00021c0", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_016_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(16);
            -- x"c00021c4", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_017_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(17);
            -- x"c00021c8", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_018_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(18);
            -- x"c00021cc", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_019_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(19);
            -- x"c00021d0", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_020_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(20);
            -- x"c00021d4", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_021_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(21);
            -- x"c00021d8", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_022_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(22);
            -- x"c00021dc", Lower 32 bits of Bulk data IP source address
            when C_ip_src_addr_023_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_0xx(23);
            -- x"c00021e0", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_100_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(00);
            -- x"c00021e4", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_101_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(01);
            -- x"c00021e8", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_102_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(02);
            -- x"c00021ec", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_103_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(03);
            -- x"c00021f0", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_104_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(04);
            -- x"c00021f4", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_105_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(05);
            -- x"c00021f8", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_106_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(06);
            -- x"c00021fc", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_107_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(07);
            -- x"c0002200", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_108_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(08);
            -- x"c0002204", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_109_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(09);
            -- x"c0002208", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_110_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(10);
            -- x"c000220c", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_111_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(11);
            -- x"c0002210", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_112_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(12);
            -- x"c0002214", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_113_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(13);
            -- x"c0002218", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_114_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(14);
            -- x"c000221c", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_115_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(15);
            -- x"c0002220", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_116_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(16);
            -- x"c0002224", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_117_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(17);
            -- x"c0002228", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_118_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(18);
            -- x"c000222c", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_119_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(19);
            -- x"c0002230", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_120_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(20);
            -- x"c0002234", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_121_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(21);
            -- x"c0002238", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_122_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(22);
            -- x"c000223c", Upper 32 bits of Bulk data IP source address
            when C_ip_src_addr_123_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_src_addr_1xx(23);
            -- x"c0002240", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_000_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(00);
            -- x"c0002244", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_001_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(01);
            -- x"c0002248", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_002_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(02);
            -- x"c000224c", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_003_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(03);
            -- x"c0002250", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_004_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(04);
            -- x"c0002254", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_005_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(05);
            -- x"c0002258", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_006_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(06);
            -- x"c000225c", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_007_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(07);
            -- x"c0002260", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_008_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(08);
            -- x"c0002264", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_009_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(09);
            -- x"c0002268", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_010_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(10);
            -- x"c000226c", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_011_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(11);
            -- x"c0002270", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_012_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(12);
            -- x"c0002274", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_013_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(13);
            -- x"c0002278", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_014_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(14);
            -- x"c000227c", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_015_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(15);
            -- x"c0002280", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_016_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(16);
            -- x"c0002284", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_017_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(17);
            -- x"c0002288", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_018_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(18);
            -- x"c000228c", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_019_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(19);
            -- x"c0002290", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_020_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(20);
            -- x"c0002294", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_021_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(21);
            -- x"c0002298", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_022_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(22);
            -- x"c000229c", Lower 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_023_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_0xx(23);
            -- x"c00022a0", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_100_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(00);
            -- x"c00022a4", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_101_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(01);
            -- x"c00022a8", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_102_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(02);
            -- x"c00022ac", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_103_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(03);
            -- x"c00022b0", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_104_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(04);
            -- x"c00022b4", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_105_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(05);
            -- x"c00022b8", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_106_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(06);
            -- x"c00022bc", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_107_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(07);
            -- x"c00022c0", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_108_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(08);
            -- x"c00022c4", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_109_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(09);
            -- x"c00022c8", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_110_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(10);
            -- x"c00022cc", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_111_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(11);
            -- x"c00022d0", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_112_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(12);
            -- x"c00022d4", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_113_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(13);
            -- x"c00022d8", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_114_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(14);
            -- x"c00022dc", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_115_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(15);
            -- x"c00022e0", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_116_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(16);
            -- x"c00022e4", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_117_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(17);
            -- x"c00022e8", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_118_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(18);
            -- x"c00022ec", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_119_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(19);
            -- x"c00022f0", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_120_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(20);
            -- x"c00022f4", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_121_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(21);
            -- x"c00022f8", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_122_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(22);
            -- x"c00022fc", Upper 32 bits of Bulk data IP destination address
            when C_ip_dst_addr_123_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ip_dst_addr_1xx(23);
            -- x"c0002300", Bulk data UDP source port
            when C_udp_src_port00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(00);
            -- x"c0002304", Bulk data UDP source port
            when C_udp_src_port01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(01);
            -- x"c0002308", Bulk data UDP source port
            when C_udp_src_port02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(02);
            -- x"c000230c", Bulk data UDP source port
            when C_udp_src_port03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(03);
            -- x"c0002310", Bulk data UDP source port
            when C_udp_src_port04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(04);
            -- x"c0002314", Bulk data UDP source port
            when C_udp_src_port05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(05);
            -- x"c0002318", Bulk data UDP source port
            when C_udp_src_port06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(06);
            -- x"c000231c", Bulk data UDP source port
            when C_udp_src_port07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(07);
            -- x"c0002320", Bulk data UDP source port
            when C_udp_src_port08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(08);
            -- x"c0002324", Bulk data UDP source port
            when C_udp_src_port09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(09);
            -- x"c0002328", Bulk data UDP source port
            when C_udp_src_port10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(10);
            -- x"c000232c", Bulk data UDP source port
            when C_udp_src_port11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(11);
            -- x"c0002330", Bulk data UDP source port
            when C_udp_src_port12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(12);
            -- x"c0002334", Bulk data UDP source port
            when C_udp_src_port13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(13);
            -- x"c0002338", Bulk data UDP source port
            when C_udp_src_port14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(14);
            -- x"c000233c", Bulk data UDP source port
            when C_udp_src_port15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(15);
            -- x"c0002340", Bulk data UDP source port
            when C_udp_src_port16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(16);
            -- x"c0002344", Bulk data UDP source port
            when C_udp_src_port17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(17);
            -- x"c0002348", Bulk data UDP source port
            when C_udp_src_port18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(18);
            -- x"c000234c", Bulk data UDP source port
            when C_udp_src_port19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(19);
            -- x"c0002350", Bulk data UDP source port
            when C_udp_src_port20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(20);
            -- x"c0002354", Bulk data UDP source port
            when C_udp_src_port21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(21);
            -- x"c0002358", Bulk data UDP source port
            when C_udp_src_port22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(22);
            -- x"c000235c", Bulk data UDP source port
            when C_udp_src_port23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_src_portxx(23);
            -- x"c0002360", Bulk data UDP destination port
            when C_udp_dst_port00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(00);
            -- x"c0002364", Bulk data UDP destination port
            when C_udp_dst_port01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(01);
            -- x"c0002368", Bulk data UDP destination port
            when C_udp_dst_port02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(02);
            -- x"c000236c", Bulk data UDP destination port
            when C_udp_dst_port03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(03);
            -- x"c0002370", Bulk data UDP destination port
            when C_udp_dst_port04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(04);
            -- x"c0002374", Bulk data UDP destination port
            when C_udp_dst_port05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(05);
            -- x"c0002378", Bulk data UDP destination port
            when C_udp_dst_port06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(06);
            -- x"c000237c", Bulk data UDP destination port
            when C_udp_dst_port07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(07);
            -- x"c0002380", Bulk data UDP destination port
            when C_udp_dst_port08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(08);
            -- x"c0002384", Bulk data UDP destination port
            when C_udp_dst_port09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(09);
            -- x"c0002388", Bulk data UDP destination port
            when C_udp_dst_port10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(10);
            -- x"c000238c", Bulk data UDP destination port
            when C_udp_dst_port11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(11);
            -- x"c0002390", Bulk data UDP destination port
            when C_udp_dst_port12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(12);
            -- x"c0002394", Bulk data UDP destination port
            when C_udp_dst_port13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(13);
            -- x"c0002398", Bulk data UDP destination port
            when C_udp_dst_port14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(14);
            -- x"c000239c", Bulk data UDP destination port
            when C_udp_dst_port15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(15);
            -- x"c00023a0", Bulk data UDP destination port
            when C_udp_dst_port16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(16);
            -- x"c00023a4", Bulk data UDP destination port
            when C_udp_dst_port17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(17);
            -- x"c00023a8", Bulk data UDP destination port
            when C_udp_dst_port18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(18);
            -- x"c00023ac", Bulk data UDP destination port
            when C_udp_dst_port19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(19);
            -- x"c00023b0", Bulk data UDP destination port
            when C_udp_dst_port20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(20);
            -- x"c00023b4", Bulk data UDP destination port
            when C_udp_dst_port21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(21);
            -- x"c00023b8", Bulk data UDP destination port
            when C_udp_dst_port22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(22);
            -- x"c00023bc", Bulk data UDP destination port
            when C_udp_dst_port23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.udp_dst_portxx(23);
            -- x"c00023c0", Bulk data packet readout packet type
            when C_ro_type00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(00);
            -- x"c00023c4", Bulk data packet readout packet type
            when C_ro_type01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(01);
            -- x"c00023c8", Bulk data packet readout packet type
            when C_ro_type02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(02);
            -- x"c00023cc", Bulk data packet readout packet type
            when C_ro_type03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(03);
            -- x"c00023d0", Bulk data packet readout packet type
            when C_ro_type04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(04);
            -- x"c00023d4", Bulk data packet readout packet type
            when C_ro_type05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(05);
            -- x"c00023d8", Bulk data packet readout packet type
            when C_ro_type06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(06);
            -- x"c00023dc", Bulk data packet readout packet type
            when C_ro_type07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(07);
            -- x"c00023e0", Bulk data packet readout packet type
            when C_ro_type08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(08);
            -- x"c00023e4", Bulk data packet readout packet type
            when C_ro_type09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(09);
            -- x"c00023e8", Bulk data packet readout packet type
            when C_ro_type10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(10);
            -- x"c00023ec", Bulk data packet readout packet type
            when C_ro_type11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(11);
            -- x"c00023f0", Bulk data packet readout packet type
            when C_ro_type12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(12);
            -- x"c00023f4", Bulk data packet readout packet type
            when C_ro_type13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(13);
            -- x"c00023f8", Bulk data packet readout packet type
            when C_ro_type14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(14);
            -- x"c00023fc", Bulk data packet readout packet type
            when C_ro_type15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(15);
            -- x"c0002400", Bulk data packet readout packet type
            when C_ro_type16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(16);
            -- x"c0002404", Bulk data packet readout packet type
            when C_ro_type17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(17);
            -- x"c0002408", Bulk data packet readout packet type
            when C_ro_type18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(18);
            -- x"c000240c", Bulk data packet readout packet type
            when C_ro_type19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(19);
            -- x"c0002410", Bulk data packet readout packet type
            when C_ro_type20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(20);
            -- x"c0002414", Bulk data packet readout packet type
            when C_ro_type21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(21);
            -- x"c0002418", Bulk data packet readout packet type
            when C_ro_type22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(22);
            -- x"c000241c", Bulk data packet readout packet type
            when C_ro_type23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.ro_typexx(23);
            -- x"c0002420", Bulk data timeout (deprecated)
            when C_timeout00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(00);
            -- x"c0002424", Bulk data timeout (deprecated)
            when C_timeout01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(01);
            -- x"c0002428", Bulk data timeout (deprecated)
            when C_timeout02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(02);
            -- x"c000242c", Bulk data timeout (deprecated)
            when C_timeout03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(03);
            -- x"c0002430", Bulk data timeout (deprecated)
            when C_timeout04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(04);
            -- x"c0002434", Bulk data timeout (deprecated)
            when C_timeout05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(05);
            -- x"c0002438", Bulk data timeout (deprecated)
            when C_timeout06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(06);
            -- x"c000243c", Bulk data timeout (deprecated)
            when C_timeout07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(07);
            -- x"c0002440", Bulk data timeout (deprecated)
            when C_timeout08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(08);
            -- x"c0002444", Bulk data timeout (deprecated)
            when C_timeout09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(09);
            -- x"c0002448", Bulk data timeout (deprecated)
            when C_timeout10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(10);
            -- x"c000244c", Bulk data timeout (deprecated)
            when C_timeout11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(11);
            -- x"c0002450", Bulk data timeout (deprecated)
            when C_timeout12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(12);
            -- x"c0002454", Bulk data timeout (deprecated)
            when C_timeout13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(13);
            -- x"c0002458", Bulk data timeout (deprecated)
            when C_timeout14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(14);
            -- x"c000245c", Bulk data timeout (deprecated)
            when C_timeout15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(15);
            -- x"c0002460", Bulk data timeout (deprecated)
            when C_timeout16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(16);
            -- x"c0002464", Bulk data timeout (deprecated)
            when C_timeout17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(17);
            -- x"c0002468", Bulk data timeout (deprecated)
            when C_timeout18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(18);
            -- x"c000246c", Bulk data timeout (deprecated)
            when C_timeout19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(19);
            -- x"c0002470", Bulk data timeout (deprecated)
            when C_timeout20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(20);
            -- x"c0002474", Bulk data timeout (deprecated)
            when C_timeout21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(21);
            -- x"c0002478", Bulk data timeout (deprecated)
            when C_timeout22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(22);
            -- x"c000247c", Bulk data timeout (deprecated)
            when C_timeout23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.timeoutxx(23);
            -- x"c0002480", Packet engine enable bitmask
            when C_eng_enable_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.eng_enable;
            -- x"c0002484", Reformat FEA header to DMSC format
            when C_reformat_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.reformat;
            -- x"c0002488", Test data enable bitmask
            when C_pkt_gen_enable_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_enable;
            -- x"c000248c", Test data inter-packet idles
            when C_pkt_gen_idles00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(00);
            -- x"c0002490", Test data inter-packet idles
            when C_pkt_gen_idles01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(01);
            -- x"c0002494", Test data inter-packet idles
            when C_pkt_gen_idles02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(02);
            -- x"c0002498", Test data inter-packet idles
            when C_pkt_gen_idles03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(03);
            -- x"c000249c", Test data inter-packet idles
            when C_pkt_gen_idles04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(04);
            -- x"c00024a0", Test data inter-packet idles
            when C_pkt_gen_idles05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(05);
            -- x"c00024a4", Test data inter-packet idles
            when C_pkt_gen_idles06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(06);
            -- x"c00024a8", Test data inter-packet idles
            when C_pkt_gen_idles07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(07);
            -- x"c00024ac", Test data inter-packet idles
            when C_pkt_gen_idles08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(08);
            -- x"c00024b0", Test data inter-packet idles
            when C_pkt_gen_idles09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(09);
            -- x"c00024b4", Test data inter-packet idles
            when C_pkt_gen_idles10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(10);
            -- x"c00024b8", Test data inter-packet idles
            when C_pkt_gen_idles11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(11);
            -- x"c00024bc", Test data inter-packet idles
            when C_pkt_gen_idles12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(12);
            -- x"c00024c0", Test data inter-packet idles
            when C_pkt_gen_idles13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(13);
            -- x"c00024c4", Test data inter-packet idles
            when C_pkt_gen_idles14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(14);
            -- x"c00024c8", Test data inter-packet idles
            when C_pkt_gen_idles15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(15);
            -- x"c00024cc", Test data inter-packet idles
            when C_pkt_gen_idles16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(16);
            -- x"c00024d0", Test data inter-packet idles
            when C_pkt_gen_idles17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(17);
            -- x"c00024d4", Test data inter-packet idles
            when C_pkt_gen_idles18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(18);
            -- x"c00024d8", Test data inter-packet idles
            when C_pkt_gen_idles19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(19);
            -- x"c00024dc", Test data inter-packet idles
            when C_pkt_gen_idles20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(20);
            -- x"c00024e0", Test data inter-packet idles
            when C_pkt_gen_idles21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(21);
            -- x"c00024e4", Test data inter-packet idles
            when C_pkt_gen_idles22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(22);
            -- x"c00024e8", Test data inter-packet idles
            when C_pkt_gen_idles23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_idlesxx(23);
            -- x"c00024ec", Test data packet length
            when C_pkt_gen_length00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(00);
            -- x"c00024f0", Test data packet length
            when C_pkt_gen_length01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(01);
            -- x"c00024f4", Test data packet length
            when C_pkt_gen_length02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(02);
            -- x"c00024f8", Test data packet length
            when C_pkt_gen_length03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(03);
            -- x"c00024fc", Test data packet length
            when C_pkt_gen_length04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(04);
            -- x"c0002500", Test data packet length
            when C_pkt_gen_length05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(05);
            -- x"c0002504", Test data packet length
            when C_pkt_gen_length06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(06);
            -- x"c0002508", Test data packet length
            when C_pkt_gen_length07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(07);
            -- x"c000250c", Test data packet length
            when C_pkt_gen_length08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(08);
            -- x"c0002510", Test data packet length
            when C_pkt_gen_length09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(09);
            -- x"c0002514", Test data packet length
            when C_pkt_gen_length10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(10);
            -- x"c0002518", Test data packet length
            when C_pkt_gen_length11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(11);
            -- x"c000251c", Test data packet length
            when C_pkt_gen_length12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(12);
            -- x"c0002520", Test data packet length
            when C_pkt_gen_length13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(13);
            -- x"c0002524", Test data packet length
            when C_pkt_gen_length14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(14);
            -- x"c0002528", Test data packet length
            when C_pkt_gen_length15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(15);
            -- x"c000252c", Test data packet length
            when C_pkt_gen_length16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(16);
            -- x"c0002530", Test data packet length
            when C_pkt_gen_length17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(17);
            -- x"c0002534", Test data packet length
            when C_pkt_gen_length18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(18);
            -- x"c0002538", Test data packet length
            when C_pkt_gen_length19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(19);
            -- x"c000253c", Test data packet length
            when C_pkt_gen_length20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(20);
            -- x"c0002540", Test data packet length
            when C_pkt_gen_length21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(21);
            -- x"c0002544", Test data packet length
            when C_pkt_gen_length22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(22);
            -- x"c0002548", Test data packet length
            when C_pkt_gen_length23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.pkt_gen_lengthxx(23);
            -- x"c000254c", eng mst Param Desc Git #
            when C_PHASH_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.PHASH;
            when others => 
                axi_rdata <= C_EMPTY_STATUS;
        end case;
    end process;

end;
