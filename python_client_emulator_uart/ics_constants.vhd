----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/11/2017 09:14:09 AM
-- Design Name: 
-- Module Name: ics_constants - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package ics_constants is

    constant PKT_BYTES   : integer := 16; 

    constant ICS_HEADER  : std_logic_vector(15 downto 0) := x"CAFE";
    constant ICS_LOAD_TS : std_logic_vector(15 downto 0) := x"4000";
    constant ICS_RD_INIT : std_logic_vector(15 downto 0) := x"8000";
    constant ICS_RD_TERM : std_logic_vector(15 downto 0) := x"80C0";
    constant ICS_WR_INIT : std_logic_vector(15 downto 0) := x"8002";
    constant ICS_WR_DATA : std_logic_vector(15 downto 0) := x"80F2";
    constant ICS_WR_TERM : std_logic_vector(15 downto 0) := x"80C1";

    constant SLV_HEADER  : std_logic_vector(15 downto 0) := x"BABE";
    constant SLV_LOAD_TS : std_logic_vector(15 downto 0) := x"4009";
    constant SLV_RD_INIT : std_logic_vector(15 downto 0) := x"8080";
    constant SLV_RD_DATA : std_logic_vector(15 downto 0) := x"80A0";
    constant SLV_RD_TERM : std_logic_vector(15 downto 0) := x"80E0";
    constant SLV_WR_INIT : std_logic_vector(15 downto 0) := x"8081";
    constant SLV_WR_TERM : std_logic_vector(15 downto 0) := x"80D5";
    
    constant SLV_CHK_ERR : std_logic_vector(15 downto 0) := x"FF01";
    constant SLV_IND_ERR : std_logic_vector(15 downto 0) := x"80F1";


end ics_constants;

package body ics_constants is
end ics_constants;
