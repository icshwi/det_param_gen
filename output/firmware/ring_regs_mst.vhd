-- Register map generated at: 05/03/2020 11:29:08
-- using: /home/jgc87821/ess/harmonized/src/reg_parse.py
-- Register definition file: ../param_map/param_map_mst.json
-- Project: Detector Group Readout Master
-- Register space: Ring Configuration Register Space (Master)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ring_regs_mst_pkg.all;
use work.axi4lite_pkg.all;

entity ring_regs_mst is
generic (
    C_AXI_ADDR_WIDTH : integer := 32;
    C_AXI_DATA_WIDTH : integer := 32
);
port (
    S_AXI_ACLK     : in  std_logic;
    S_AXI_ARESETN  : in  std_logic;
    S_AXI_SIGS_IN  : in  t_axi4lite_mosi;
    S_AXI_SIGS_OUT : out t_axi4lite_miso;
    RO_REGS_IN     : in  t_ring_regs_mst_ro;
    RW_REGS_OUT    : out t_ring_regs_mst_rw
);
end ring_regs_mst;

architecture behavioral of ring_regs_mst is

    constant C_EMPTY_STATUS : std_logic_vector(32-1 downto 0) := x"ba_ad_ba_ad";
    -- formula used by Python script is C_AXI_DATA_WIDTH/2 + 1
    -- not done directly in VHDL becuase generics can't be used in case statements
    constant C_ADDR_LSB : integer := 2;
    constant C_OPT_ADDR_BITS : integer := 8;
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
    signal ro_regs      : t_ring_regs_mst_ro;
    signal rw_regs      : t_ring_regs_mst_rw;
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
                rw_regs <= C_RING_REGS_MST_RW;
            else
                -- Register the external (engine etc.) values into the ro registers every cycle
                ro_regs <= RO_REGS_IN;
                loc_addr := axi_awaddr(C_ADDR_MSB downto C_ADDR_LSB);
                if reg_wren = '1' then
                    -- read-only registers not included here
                    case loc_addr is
                        -- x"c0000004", Function not documented
                        when C_RGTY_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.RGTY(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00000d4", Next state of TX engine. TNS0 = 8 x 4bit fields corresponding to states of engine 0..7. Similarly TNS1 engines 15..9. Etc.
                        when C_TNS00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.TNSxx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00000d8", Next state of TX engine. TNS0 = 8 x 4bit fields corresponding to states of engine 0..7. Similarly TNS1 engines 15..9. Etc.
                        when C_TNS01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.TNSxx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00000dc", Next state of TX engine. TNS0 = 8 x 4bit fields corresponding to states of engine 0..7. Similarly TNS1 engines 15..9. Etc.
                        when C_TNS02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.TNSxx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00000e0", Next state of RX engine state machine 0:8
                        when C_RNS00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.RNSxx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00000e4", Next state of RX engine state machine 0:8
                        when C_RNS01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.RNSxx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00000e8", Next state of RX engine state machine 0:8
                        when C_RNS02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.RNSxx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00000f8", power down pll
                        when C_PDPL_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.PDPL(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000010c", software resetn     -- TODO this probably needs moving out of FEMstr regs to a global reg.bank
                        when C_SRST_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.SRST(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000110", used as control input to direction controller
                        when C_RVSR_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.RVSR(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000114", used to select direction (cw or ccw) on which slwo control goes out
                        when C_TDIR_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.TDIR(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000118", used to select rx engine (cw or ccw) on which slow control are received
                        when C_RDIR_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.RDIR(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000011c", Lower 32 bits of 64-bit time to be loaded upon a strobe (see also LDST)
                        when C_TYM_0_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.TYM_0(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000120", Upper 32 bits of 64-bit time to be loaded upon a strobe (see also LDST)
                        when C_TYM_1_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.TYM_1(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000124", bit 0 = artificial strobe, causes local time registers to begin counting; bit 1 = load signal, tells local time regs to stop counting and re-latch TYME and wait for a strobe
                        when C_LDST_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.LDST(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000248", time-of-flight offset that gets added to current time when sending tiome to slaves
                        when C_TMOF_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.TMOF(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000024c", time at which to emit a pulse (e.g. for viewing pulse per sec on 'scope)
                        when C_TPLS_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.TPLS(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000250", duration of TPLS
                        when C_TDUR_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.TDUR(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000254", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(00)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000258", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(01)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000025c", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(02)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000260", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(03)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000264", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(04)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000268", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(05)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000026c", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(06)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000270", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(07)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000274", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(08)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000278", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(09)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000027c", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(10)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000280", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(11)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000284", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(12)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000288", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(13)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000028c", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(14)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000290", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(15)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000294", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(16)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c0000298", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(17)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c000029c", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(18)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00002a0", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(19)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00002a4", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(20)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00002a8", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(21)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00002ac", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(22)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00002b0", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
                        when C_MN23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.MNxx(23)(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00002b4", length of bulk data packets launched around the ring
                        when C_PLEN_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.PLEN(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"c00002b8", gtwiz_reset_rx_pll_and_datapath_in port of gty reset module
                        when C_RSRX_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.RSRX(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
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
            -- x"c0000000", GTY power good
            when C_GTPG_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.GTPG;
            -- x"c0000004", Function not documented
            when C_RGTY_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.RGTY;
            -- x"c0000008", GTY Tx Reset Done
            when C_RTXD_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RTXD;
            -- x"c000000c", GTY Rx Reset Done
            when C_RRXD_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RRXD;
            -- x"c0000010", GTY byte is aligned
            when C_RBAL_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RBAL;
            -- x"c0000014", RX engine snapshot
            when C_RS00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(00);
            -- x"c0000018", RX engine snapshot
            when C_RS01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(01);
            -- x"c000001c", RX engine snapshot
            when C_RS02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(02);
            -- x"c0000020", RX engine snapshot
            when C_RS03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(03);
            -- x"c0000024", RX engine snapshot
            when C_RS04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(04);
            -- x"c0000028", RX engine snapshot
            when C_RS05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(05);
            -- x"c000002c", RX engine snapshot
            when C_RS06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(06);
            -- x"c0000030", RX engine snapshot
            when C_RS07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(07);
            -- x"c0000034", RX engine snapshot
            when C_RS08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(08);
            -- x"c0000038", RX engine snapshot
            when C_RS09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(09);
            -- x"c000003c", RX engine snapshot
            when C_RS10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(10);
            -- x"c0000040", RX engine snapshot
            when C_RS11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(11);
            -- x"c0000044", RX engine snapshot
            when C_RS12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(12);
            -- x"c0000048", RX engine snapshot
            when C_RS13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(13);
            -- x"c000004c", RX engine snapshot
            when C_RS14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(14);
            -- x"c0000050", RX engine snapshot
            when C_RS15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(15);
            -- x"c0000054", RX engine snapshot
            when C_RS16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(16);
            -- x"c0000058", RX engine snapshot
            when C_RS17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(17);
            -- x"c000005c", RX engine snapshot
            when C_RS18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(18);
            -- x"c0000060", RX engine snapshot
            when C_RS19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(19);
            -- x"c0000064", RX engine snapshot
            when C_RS20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(20);
            -- x"c0000068", RX engine snapshot
            when C_RS21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(21);
            -- x"c000006c", RX engine snapshot
            when C_RS22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(22);
            -- x"c0000070", RX engine snapshot
            when C_RS23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RSxx(23);
            -- x"c0000074", TX engine snapshot
            when C_TS00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(00);
            -- x"c0000078", TX engine snapshot
            when C_TS01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(01);
            -- x"c000007c", TX engine snapshot
            when C_TS02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(02);
            -- x"c0000080", TX engine snapshot
            when C_TS03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(03);
            -- x"c0000084", TX engine snapshot
            when C_TS04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(04);
            -- x"c0000088", TX engine snapshot
            when C_TS05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(05);
            -- x"c000008c", TX engine snapshot
            when C_TS06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(06);
            -- x"c0000090", TX engine snapshot
            when C_TS07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(07);
            -- x"c0000094", TX engine snapshot
            when C_TS08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(08);
            -- x"c0000098", TX engine snapshot
            when C_TS09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(09);
            -- x"c000009c", TX engine snapshot
            when C_TS10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(10);
            -- x"c00000a0", TX engine snapshot
            when C_TS11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(11);
            -- x"c00000a4", TX engine snapshot
            when C_TS12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(12);
            -- x"c00000a8", TX engine snapshot
            when C_TS13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(13);
            -- x"c00000ac", TX engine snapshot
            when C_TS14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(14);
            -- x"c00000b0", TX engine snapshot
            when C_TS15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(15);
            -- x"c00000b4", TX engine snapshot
            when C_TS16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(16);
            -- x"c00000b8", TX engine snapshot
            when C_TS17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(17);
            -- x"c00000bc", TX engine snapshot
            when C_TS18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(18);
            -- x"c00000c0", TX engine snapshot
            when C_TS19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(19);
            -- x"c00000c4", TX engine snapshot
            when C_TS20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(20);
            -- x"c00000c8", TX engine snapshot
            when C_TS21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(21);
            -- x"c00000cc", TX engine snapshot
            when C_TS22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(22);
            -- x"c00000d0", TX engine snapshot
            when C_TS23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TSxx(23);
            -- x"c00000d4", Next state of TX engine. TNS0 = 8 x 4bit fields corresponding to states of engine 0..7. Similarly TNS1 engines 15..9. Etc.
            when C_TNS00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.TNSxx(00);
            -- x"c00000d8", Next state of TX engine. TNS0 = 8 x 4bit fields corresponding to states of engine 0..7. Similarly TNS1 engines 15..9. Etc.
            when C_TNS01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.TNSxx(01);
            -- x"c00000dc", Next state of TX engine. TNS0 = 8 x 4bit fields corresponding to states of engine 0..7. Similarly TNS1 engines 15..9. Etc.
            when C_TNS02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.TNSxx(02);
            -- x"c00000e0", Next state of RX engine state machine 0:8
            when C_RNS00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.RNSxx(00);
            -- x"c00000e4", Next state of RX engine state machine 0:8
            when C_RNS01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.RNSxx(01);
            -- x"c00000e8", Next state of RX engine state machine 0:8
            when C_RNS02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.RNSxx(02);
            -- x"c00000ec", current state to TX engine
            when C_TCS00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TCSxx(00);
            -- x"c00000f0", current state to TX engine
            when C_TCS01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TCSxx(01);
            -- x"c00000f4", current state to TX engine
            when C_TCS02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TCSxx(02);
            -- x"c00000f8", power down pll
            when C_PDPL_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.PDPL;
            -- x"c00000fc", current state to RX engine
            when C_RCS00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RCSxx(00);
            -- x"c0000100", current state to RX engine
            when C_RCS01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RCSxx(01);
            -- x"c0000104", current state to RX engine
            when C_RCS02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RCSxx(02);
            -- x"c0000108", RX engine received 'bad' i.e.non-0x959595BC word
            when C_RBWD_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RBWD;
            -- x"c000010c", software resetn     -- TODO this probably needs moving out of FEMstr regs to a global reg.bank
            when C_SRST_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.SRST;
            -- x"c0000110", used as control input to direction controller
            when C_RVSR_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.RVSR;
            -- x"c0000114", used to select direction (cw or ccw) on which slwo control goes out
            when C_TDIR_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.TDIR;
            -- x"c0000118", used to select rx engine (cw or ccw) on which slow control are received
            when C_RDIR_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.RDIR;
            -- x"c000011c", Lower 32 bits of 64-bit time to be loaded upon a strobe (see also LDST)
            when C_TYM_0_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.TYM_0;
            -- x"c0000120", Upper 32 bits of 64-bit time to be loaded upon a strobe (see also LDST)
            when C_TYM_1_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.TYM_1;
            -- x"c0000124", bit 0 = artificial strobe, causes local time registers to begin counting; bit 1 = load signal, tells local time regs to stop counting and re-latch TYME and wait for a strobe
            when C_LDST_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.LDST;
            -- x"c0000128", snapshots of the local time according to tx engines
            when C_MS00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(00);
            -- x"c000012c", snapshots of the local time according to tx engines
            when C_MS01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(01);
            -- x"c0000130", snapshots of the local time according to tx engines
            when C_MS02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(02);
            -- x"c0000134", snapshots of the local time according to tx engines
            when C_MS03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(03);
            -- x"c0000138", snapshots of the local time according to tx engines
            when C_MS04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(04);
            -- x"c000013c", snapshots of the local time according to tx engines
            when C_MS05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(05);
            -- x"c0000140", snapshots of the local time according to tx engines
            when C_MS06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(06);
            -- x"c0000144", snapshots of the local time according to tx engines
            when C_MS07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(07);
            -- x"c0000148", snapshots of the local time according to tx engines
            when C_MS08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(08);
            -- x"c000014c", snapshots of the local time according to tx engines
            when C_MS09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(09);
            -- x"c0000150", snapshots of the local time according to tx engines
            when C_MS10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(10);
            -- x"c0000154", snapshots of the local time according to tx engines
            when C_MS11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(11);
            -- x"c0000158", snapshots of the local time according to tx engines
            when C_MS12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(12);
            -- x"c000015c", snapshots of the local time according to tx engines
            when C_MS13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(13);
            -- x"c0000160", snapshots of the local time according to tx engines
            when C_MS14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(14);
            -- x"c0000164", snapshots of the local time according to tx engines
            when C_MS15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(15);
            -- x"c0000168", snapshots of the local time according to tx engines
            when C_MS16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(16);
            -- x"c000016c", snapshots of the local time according to tx engines
            when C_MS17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(17);
            -- x"c0000170", snapshots of the local time according to tx engines
            when C_MS18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(18);
            -- x"c0000174", snapshots of the local time according to tx engines
            when C_MS19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(19);
            -- x"c0000178", snapshots of the local time according to tx engines
            when C_MS20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(20);
            -- x"c000017c", snapshots of the local time according to tx engines
            when C_MS21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(21);
            -- x"c0000180", snapshots of the local time according to tx engines
            when C_MS22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(22);
            -- x"c0000184", snapshots of the local time according to tx engines
            when C_MS23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.MSxx(23);
            -- x"c0000188", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(00);
            -- x"c000018c", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(01);
            -- x"c0000190", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(02);
            -- x"c0000194", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(03);
            -- x"c0000198", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(04);
            -- x"c000019c", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(05);
            -- x"c00001a0", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(06);
            -- x"c00001a4", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(07);
            -- x"c00001a8", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(08);
            -- x"c00001ac", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(09);
            -- x"c00001b0", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(10);
            -- x"c00001b4", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(11);
            -- x"c00001b8", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(12);
            -- x"c00001bc", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(13);
            -- x"c00001c0", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(14);
            -- x"c00001c4", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(15);
            -- x"c00001c8", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(16);
            -- x"c00001cc", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(17);
            -- x"c00001d0", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(18);
            -- x"c00001d4", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(19);
            -- x"c00001d8", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(20);
            -- x"c00001dc", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(21);
            -- x"c00001e0", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(22);
            -- x"c00001e4", time when a 'set time' slow-control was sent to ring (used in t-o-f measurements)
            when C_TM23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.TMxx(23);
            -- x"c00001e8", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(00);
            -- x"c00001ec", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(01);
            -- x"c00001f0", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(02);
            -- x"c00001f4", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(03);
            -- x"c00001f8", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(04);
            -- x"c00001fc", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(05);
            -- x"c0000200", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(06);
            -- x"c0000204", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(07);
            -- x"c0000208", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(08);
            -- x"c000020c", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(09);
            -- x"c0000210", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(10);
            -- x"c0000214", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(11);
            -- x"c0000218", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(12);
            -- x"c000021c", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(13);
            -- x"c0000220", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(14);
            -- x"c0000224", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(15);
            -- x"c0000228", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(16);
            -- x"c000022c", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(17);
            -- x"c0000230", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(18);
            -- x"c0000234", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(19);
            -- x"c0000238", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(20);
            -- x"c000023c", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(21);
            -- x"c0000240", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(22);
            -- x"c0000244", time the most recent slow-control reply was received (used in t-o-f measurements)
            when C_RM23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.RMxx(23);
            -- x"c0000248", time-of-flight offset that gets added to current time when sending tiome to slaves
            when C_TMOF_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.TMOF;
            -- x"c000024c", time at which to emit a pulse (e.g. for viewing pulse per sec on 'scope)
            when C_TPLS_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.TPLS;
            -- x"c0000250", duration of TPLS
            when C_TDUR_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.TDUR;
            -- x"c0000254", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN00_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(00);
            -- x"c0000258", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN01_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(01);
            -- x"c000025c", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN02_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(02);
            -- x"c0000260", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN03_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(03);
            -- x"c0000264", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN04_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(04);
            -- x"c0000268", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN05_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(05);
            -- x"c000026c", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN06_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(06);
            -- x"c0000270", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN07_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(07);
            -- x"c0000274", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN08_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(08);
            -- x"c0000278", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN09_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(09);
            -- x"c000027c", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN10_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(10);
            -- x"c0000280", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN11_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(11);
            -- x"c0000284", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN12_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(12);
            -- x"c0000288", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN13_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(13);
            -- x"c000028c", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN14_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(14);
            -- x"c0000290", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN15_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(15);
            -- x"c0000294", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN16_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(16);
            -- x"c0000298", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN17_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(17);
            -- x"c000029c", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN18_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(18);
            -- x"c00002a0", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN19_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(19);
            -- x"c00002a4", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN20_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(20);
            -- x"c00002a8", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN21_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(21);
            -- x"c00002ac", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN22_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(22);
            -- x"c00002b0", bits 0:4 encode minimum node on ring; bits 8:12 encode maximum node
            when C_MN23_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.MNxx(23);
            -- x"c00002b4", length of bulk data packets launched around the ring
            when C_PLEN_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.PLEN;
            -- x"c00002b8", gtwiz_reset_rx_pll_and_datapath_in port of gty reset module
            when C_RSRX_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.RSRX;
            -- x"c00002bc", ring mst Param Desc Git #
            when C_PHASH_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.PHASH;
            when others => 
                axi_rdata <= C_EMPTY_STATUS;
        end case;
    end process;

end;
