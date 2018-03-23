----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:25:08 03/22/2018 
-- Design Name: 
-- Module Name:    signed_inverter - combinatorial 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity signed_inverter is
    generic ( SIGNAL_LENGTH: positive);
    Port ( input_value : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           output_value : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0));
end signed_inverter;

architecture combinational of signed_inverter is

signal inversion: std_logic_vector (SIGNAL_LENGTH-1 downto 0);
signal carry: std_logic_vector(SIGNAL_LENGTH-1 downto 0);
begin

inversion <= not input_value;

-- implicit half adders to do a simple increment
carry(0) <= '1';
output_value <= inversion xor carry;
carry(SIGNAL_LENGTH-1 downto 1) <= inversion(SIGNAL_LENGTH-2 downto 0) and carry(SIGNAL_LENGTH-2 downto 0);

end combinational;

