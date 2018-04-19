----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:51:45 04/10/2018 
-- Design Name: 
-- Module Name:    nbit_signed_divider - Behavioral 
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity division is
    generic(SIGNAL_LENGTH: INTEGER := 8);
    port(reset: in STD_LOGIC;
        en: in STD_LOGIC;
		  op_ready: in STD_LOGIC;
        clk: in STD_LOGIC;
        input_A: in STD_LOGIC_VECTOR((SIGNAL_LENGTH - 1) downto 0);
        input_B: in STD_LOGIC_VECTOR((SIGNAL_LENGTH - 1) downto 0);
        output: out STD_LOGIC_VECTOR((SIGNAL_LENGTH - 1) downto 0)
        );
end division;

architecture arch_division of division is

    signal nbuf: STD_LOGIC_VECTOR((2 * SIGNAL_LENGTH - 1) downto 0);
    signal dbuf: STD_LOGIC_VECTOR((SIGNAL_LENGTH - 1) downto 0);
    signal cnt: INTEGER range 0 to SIGNAL_LENGTH;
	 signal num: std_logic_vector (SIGNAL_LENGTH-1 downto 0);
	 signal den: std_logic_vector (SIGNAL_LENGTH-1 downto 0);
	 signal quotient: std_logic_vector (SIGNAL_LENGTH-1 downto 0);
	 signal out_ready: std_logic;
    alias nbufH is nbuf((2 * SIGNAL_LENGTH - 1) downto SIGNAL_LENGTH);
    alias nbufL is nbuf((SIGNAL_LENGTH - 1) downto 0);
	 
	 signal reversed_quotient, not_A, not_B: STD_LOGIC_VECTOR((SIGNAL_LENGTH - 1) downto 0);
	 signal output_sign: std_logic;
	 

begin

calculating:process(reset, en, clk)
    begin
        if reset = '1' then
            quotient <= (others => '0');
            cnt <= 0;
				nbuf <= (others => '0');
				dbuf <= (others => '0');
				out_ready <= '0';
        elsif rising_edge(clk) then
            if en = '1' and op_ready='0' then
                case cnt is
                when 0 =>
                    nbufH <= (others => '0');
                    nbufL <= num;
                    dbuf <= den;
                    cnt <= cnt + 1;
                when others =>
                    if nbuf((2 * SIGNAL_LENGTH - 2) downto (SIGNAL_LENGTH - 1)) >= dbuf then
                        nbufH <= '0' & (nbuf((2 * SIGNAL_LENGTH - 3) downto (SIGNAL_LENGTH - 1)) - dbuf((SIGNAL_LENGTH - 2) downto 0));
                        nbufL <= nbufL((SIGNAL_LENGTH - 2) downto 0) & '1';
                    else
                        nbuf <= nbuf((2 * SIGNAL_LENGTH - 2) downto 0) & '0';
                    end if;
                    if cnt /= SIGNAL_LENGTH+1 then
                        cnt <= cnt + 1;
                    else
                        cnt <= 0;
								quotient <= nbufL;
                    end if;
                end case;
				elsif en = '1' and op_ready='1' then
				    cnt <= 0;
					 nbuf <= (others => '0');
					 
				
            end if;
        end if;
end process calculating;

not_A <= not(input_A) + 1;
not_B <= not(input_B) + 1;

with input_A(SIGNAL_LENGTH-1) select
    num <= input_A when '0',
	        not_A   when '1';
			  
with input_B(SIGNAL_LENGTH-1) select
    den <= input_B when '0',
	        not_B   when '1';

--complement_input:process (op_ready)
--	 begin
--		if input_A(SIGNAL_LENGTH-1)='1' then
--			num<= not (input_A-1);
--		else
--			num<=input_A;
--		end if;
--		if input_B(SIGNAL_LENGTH-1)='1' then
--			den<= not (input_B-1);
--		else
--			den<=input_B;
--		end if;
--	end process complement_input;
	 
reversed_quotient <= not(quotient)+1;
output_sign <= input_A(SIGNAL_LENGTH-1) xor input_B(SIGNAL_LENGTH-1);

with output_sign select
    output <= quotient WHEN '0',
	           reversed_quotient WHEN '1',
	 (others => '0') when OTHERS;
	 
--complement_output:process (quotient)
--	begin
--		 if input_A(SIGNAL_LENGTH-1)='1' then
--			if input_B(SIGNAL_LENGTH-1)='1' then
--				output<=quotient;
--			else
--				output<=not(quotient)+1;
--			end if;
--		else
--			if input_B(SIGNAL_LENGTH-1)='0' then
--				output<=quotient;
--			else
--				output<=not(quotient)+1;
--			end if;
--		end if;
--		
--	end process complement_output;
	
end arch_division;

