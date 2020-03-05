-- Register package generated at: 05/03/2020 11:25:11
-- using: /home/jgc87821/ess/harmonized/src/reg_parse.py
-- Register definition file: ../param_map/param_map_usr.json
-- Project: Detector Group Readout Slave
-- Register space: User Configuration Register Register Space (Slave)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package usr_regs_slv_pkg is


    -- todo: fix alignment
    type t_usr_regs_slv_ro is record
        ro_test : std_logic_vector(32-1 downto 0);
        PHASH : std_logic_vector(32-1 downto 0);
    end record t_usr_regs_slv_ro;

    type t_usr_regs_slv_rw is record
        rw_test : std_logic_vector(32-1 downto 0);
    end record t_usr_regs_slv_rw;

    -- Define initialisation constants
    constant C_ro_test_INIT : std_logic_vector(32-1 downto 0) := x"feedf00d";
    constant C_rw_test_INIT : std_logic_vector(32-1 downto 0) := x"babacede";
    constant C_PHASH_INIT : std_logic_vector(32-1 downto 0) := x"25DF3D44";

    -- Assign initialisation constants
    constant C_USR_REGS_SLV_RO : t_usr_regs_slv_ro := (
        ro_test => C_ro_test_INIT(32-1 downto 0),
        PHASH => C_PHASH_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants
    constant C_USR_REGS_SLV_RW : t_usr_regs_slv_rw := (
        rw_test => C_rw_test_INIT(32-1 downto 0)
    );

    -- Assign initialisation constants in case they are needed in multiple files
    -- Addresses are 32-bits: correct sizing implemented in .vhd files
    constant C_ro_test_ADDR : std_logic_vector(31 downto 0) := x"40000000";
    constant C_rw_test_ADDR : std_logic_vector(31 downto 0) := x"40000004";
    constant C_PHASH_ADDR : std_logic_vector(31 downto 0) := x"40000008";

end package;
