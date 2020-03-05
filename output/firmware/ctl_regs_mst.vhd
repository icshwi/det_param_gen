-- Register map generated at: 05/03/2020 11:55:28
-- using: /home/jgc87821/ess/harmonized/src/reg_parse.py
-- Register definition file: ../param_map/param_map_ctl.json
-- Project: Detector Group Readout Master
-- Register space: Packet Engine Configuration Register Register Space (Master)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ctl_regs_mst_pkg.all;
use work.axi4lite_pkg.all;

entity ctl_regs_mst is
generic (
    C_AXI_ADDR_WIDTH : integer := 32;
    C_AXI_DATA_WIDTH : integer := 32
);
port (
    S_AXI_ACLK     : in  std_logic;
    S_AXI_ARESETN  : in  std_logic;
    S_AXI_SIGS_IN  : in  t_axi4lite_mosi;
    S_AXI_SIGS_OUT : out t_axi4lite_miso;
    RO_REGS_IN     : in  t_ctl_regs_mst_ro;
    RW_REGS_OUT    : out t_ctl_regs_mst_rw
);
end ctl_regs_mst;

architecture behavioral of ctl_regs_mst is

    constant C_EMPTY_STATUS : std_logic_vector(32-1 downto 0) := x"ba_ad_ba_ad";
    -- formula used by Python script is C_AXI_DATA_WIDTH/2 + 1
    -- not done directly in VHDL becuase generics can't be used in case statements
    constant C_ADDR_LSB : integer := 2;
    constant C_OPT_ADDR_BITS : integer := 4;
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
    signal ro_regs      : t_ctl_regs_mst_ro;
    signal rw_regs      : t_ctl_regs_mst_rw;
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
                rw_regs <= C_CTL_REGS_MST_RW;
            else
                -- Register the external (engine etc.) values into the ro registers every cycle
                ro_regs <= RO_REGS_IN;
                loc_addr := axi_awaddr(C_ADDR_MSB downto C_ADDR_LSB);
                if reg_wren = '1' then
                    -- read-only registers not included here
                    case loc_addr is
                        -- x"c000101c", Global reset
                        when C_global_rst_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                            for byte_index in 0 to (C_AXI_DATA_WIDTH/8-1) loop
                                if S_AXI_SIGS_IN.wstrb(byte_index) = '1' then
                                    rw_regs.global_rst(byte_index*8+7 downto byte_index*8) <= S_AXI_SIGS_IN.wdata(byte_index*8+7 downto byte_index*8);
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
            -- x"c0001000", Lower 32 bits of FPGA DNA
            when C_device_dna_0_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.device_dna_0;
            -- x"c0001004", Middle 32 bits of FPGA DNA
            when C_device_dna_1_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.device_dna_1;
            -- x"c0001008", Upper 32 bits of FPGA DNA
            when C_device_dna_2_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.device_dna_2;
            -- x"c000100c", Bitstream generation time
            when C_build_time_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.build_time;
            -- x"c0001010", Lower 32 bits of Git hash
            when C_git_hash_0_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.git_hash_0;
            -- x"c0001014", Middle 32 bits of Git hash
            when C_git_hash_1_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.git_hash_1;
            -- x"c0001018", Upper 32 bits of Git hash
            when C_git_hash_2_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.git_hash_2;
            -- x"c000101c", Global reset
            when C_global_rst_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= rw_regs.global_rst;
            -- x"c0001020", ctl mst Param Desc Git #
            when C_PHASH_ADDR(C_ADDR_MSB downto C_ADDR_LSB) =>
                axi_rdata <= ro_regs.PHASH;
            when others => 
                axi_rdata <= C_EMPTY_STATUS;
        end case;
    end process;

end;
