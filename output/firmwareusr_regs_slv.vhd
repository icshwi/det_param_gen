-- Register map generated at: 24/03/2020 15:25:18
-- using: /epics/iocs/cmds/pkt-mux-cmd/dgro_master/det_param_gen/src/param_parse.py
-- Register definition file: ../../param_def/
-- Project: Detector Group Readout Slave
-- Register space: User Configuration Register Register Space (Slave)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.usr_regs_slv_pkg.all;
use work.axi4lite_pkg.all;

entity usr_regs_slv is
generic (
    C_AXI_ADDR_WIDTH : integer := 11;
    C_AXI_DATA_WIDTH : integer := 32
);
port (
    S_AXI_ACLK     : in  std_logic;
    S_AXI_ARESETN  : in  std_logic;
    S_AXI_SIGS_IN  : in  t_axi4lite_mosi;
    S_AXI_SIGS_OUT : out t_axi4lite_miso;
    RO_REGS_IN     : in  t_usr_regs_slv_ro;
    RW_REGS_OUT    : out t_usr_regs_slv_rw
);
end usr_regs_slv;

architecture behavioral of usr_regs_slv is

    constant C_EMPTY_STATUS : std_logic_vector(32-1 downto 0) := x"ba_ad_ba_ad";
    -- formula used by Python script is C_AXI_DATA_WIDTH/2 + 1
    -- not done directly in VHDL becuase generics can't be used in case statements
    constant C_ADDR_LSB : integer := 2;
    constant C_OPT_ADDR_BITS : integer := 2;
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
    signal ro_regs      : t_usr_regs_slv_ro;
    signal rw_regs      : t_usr_regs_slv_rw;
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
                rw_regs <= C_USR_REGS_SLV_RW;
            else
                -- Register the external (engine etc.) values into the ro registers every cycle
                ro_regs <= RO_REGS_IN;
                loc_addr := axi_awaddr(C_ADDR_MSB downto C_ADDR_LSB);
                if reg_wren = '1' then
                    -- read-only registers not included here
                    case loc_addr is
                        -- x"40000000", Loopback Register
                        when C_LPBK_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.LPBK(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
                                end if;
                            end loop;
                        -- x"4000000c", Read/write test register - initial value is 0xbabcede
                        when C_rw_test_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.rw_test(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
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
            -- x"40000000", Loopback Register
            when C_LPBK_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.LPBK;
            -- x"40000004", usr slv Param Desc Git #
            when C_PHASH_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.PHASH;
            -- x"40000008", Read only test register - should read 0xfeedfood
            when C_ro_test_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.ro_test;
            -- x"4000000c", Read/write test register - initial value is 0xbabcede
            when C_rw_test_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.rw_test;
            when others => 
                axi_rdata <= C_EMPTY_STATUS;
        end case;
    end process;

end;
