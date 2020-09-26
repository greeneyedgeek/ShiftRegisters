-- File Name: ShiftRegisters.vhd
-- Project Name: SHIFT REGISTERS VHDL IMPLEMENTATION
--
-- This is the top level entity for a SIPO Shift Register implementation on a Cyclone II
--
-- Author: Gabriel Fontaine-Escobar	
-- Date Created: Aug. 15, 2020
-- Date Modified: Sep. 25, 2020
--																										
-- References 
--																					
-- VHDL Whiz.(August 2020)
-- https://vhdlwhiz.com/shift-register/
--
-- Unknown Source.(August 2020)
-- Can't find the reference for the clock divider
--

library ieee;
use ieee.std_logic_1164.all;

entity ShiftRegisters is
	port(
		clk : in std_logic; -- clock signal
		clr : in std_logic; -- clear vector
		sel : in std_logic; -- 0: SISO 1: SIPO 
		d : in std_logic; -- serial input
		q : inout std_logic_vector(3 downto 0); -- output vector
		p : out std_logic_vector(3 downto 0); -- parallel output vector
		d_val : out std_logic;
		sta_d : out std_logic := '1';
		sta_clk : inout std_logic := '1'
		);
end ShiftRegisters;

architecture RTL of ShiftRegisters is
signal cmp_vct :  natural := 0; -- comparator
constant cnt_1hz :  natural := (25e6-1); -- 50Mhz clock, 50% duty cycle
signal cmp_1hz :  natural := 0; -- comparator
signal clk_1hz : std_logic := '0';
begin

  Clk1hzProc : process (clk) is
  begin
    if (rising_edge(clk)) then
      if (cmp_1hz = cnt_1hz) then
		  sta_clk <= not sta_clk;
        clk_1hz <= not clk_1hz;
        cmp_1hz <= 0;
      else
        cmp_1hz <= cmp_1hz + 1;
      end if;
    end if;
  end process Clk1hzProc;
  

	ShiftProcess : process (clk_1hz, clr) is
	begin
		if (clr = '0') then q <= (others => '0');
		elsif (rising_edge(clk_1hz)) then
			if (cmp_vct < q'length) then
			sta_d <= '0';
			d_val <= d;
			q(3) <= not d;
			q(2 downto 0) <= q(3 downto 1);
			cmp_vct <= cmp_vct + 1;
			else --if (cmp_vct = q'length) then
				sta_d <= '1';
				p <= q;
				cmp_vct <= 0;
			end if;
		end if;
	end process ShiftProcess;

end RTL; --of ShiftRegisters
