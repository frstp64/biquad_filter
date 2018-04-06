----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:27:28 03/23/2018 
-- Design Name: 
-- Module Name:    signed_multiplier - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity signed_multiplier is
 generic ( SIGNAL_LENGTH: positive);
 PORT(
		input_A : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
		input_B : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
		clk : IN  std_logic;
		reset : IN  std_logic;
		en : IN  std_logic;
		output : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
	  );
end signed_multiplier;

architecture cheat_multiplier of signed_multiplier is

signal signed_long_output: std_logic_vector(SIGNAL_LENGTH*2-1 downto 0);

begin

signed_long_output <= std_logic_vector(signed(input_A) * signed(input_B));

output <= signed_long_output(SIGNAL_LENGTH-1 downto 0);

end cheat_multiplier;

architecture wallace_tree of signed_multiplier is
type lut is array ( 0 to 2**2 - 1) of integer;

-- generated with python code
constant my_lut : lut := (
1 => 0, 2 => 0, 3 => 1, 4 => 2, 5 => 3, 6 => 3, 7 => 4, 8 => 4, 9 => 4, 10 => 5, 11 => 5, 12 => 5, 13 => 5, 14 => 6, 15 => 6, 16 => 6, 17 => 6, 18 => 6, 19 => 6, 20 => 6, 21 => 7, 22 => 7, 23 => 7, 24 => 7, 25 => 7, 26 => 7, 27 => 7, 28 => 7, 29 => 7, 30 => 8, 31 => 8, 32 => 8, 33 => 8, 34 => 8, 35 => 8, 36 => 8, 37 => 8, 38 => 8, 39 => 8, 40 => 8, 41 => 8, 42 => 8, 43 => 9, 44 => 9, 45 => 9, 46 => 9, 47 => 9, 48 => 9, 49 => 9, 50 => 9, 51 => 9, 52 => 9, 53 => 9, 54 => 9, 55 => 9, 56 => 9, 57 => 9, 58 => 9, 59 => 9, 60 => 9, 61 => 9, 62 => 9, 63 => 9, 64 => 10, 65 => 10, 66 => 10, 67 => 10, 68 => 10, 69 => 10, 70 => 10, 71 => 10, 72 => 10, 73 => 10, 74 => 10, 75 => 10, 76 => 10, 77 => 10, 78 => 10, 79 => 10, 80 => 10, 81 => 10, 82 => 10, 83 => 10, 84 => 10, 85 => 10, 86 => 10, 87 => 10, 88 => 10, 89 => 10, 90 => 10, 91 => 10, 92 => 10, 93 => 10, 94 => 10, 95 => 11, 96 => 11, 97 => 11, 98 => 11, 99 => 11, 100 => 11, 101 => 11, 102 => 11, 103 => 11, 104 => 11, 105 => 11, 106 => 11, 107 => 11, 108 => 11, 109 => 11, 110 => 11, 111 => 11, 112 => 11, 113 => 11, 114 => 11, 115 => 11, 116 => 11, 117 => 11, 118 => 11, 119 => 11, 120 => 11, 121 => 11, 122 => 11, 123 => 11, 124 => 11, 125 => 11, 126 => 11, 127 => 11, 128 => 11);
constant reduction_level_number : integer := my_lut(SIGNAL_LENGTH-1);
begin


end wallace_tree;