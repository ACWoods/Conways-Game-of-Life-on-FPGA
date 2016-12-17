-- timing diagram for the horizontal synch signal (HS)
-- 0                       856    976           1040 (pixels)
-- _________________________|------|_________________
--					   | FP |  SP  |       BP       |
-- timing diagram for the vertical synch signal (VS)
-- 0                                637   643   666 (lines)
-- __________________________________|----|________
--						          |FP| SP |   BP  |

--SPECIFICATIONS FOR 800 x 600 @ 72 Hz RESOLUTION, 50 MHz CLOCK:
--Horizontal :
	--Front Porch : 56 clock cycles
	--Sync Pulse : 120 clock cycles
	--Back Porch : 64 clock cycles
--Vertical :
	--Front Porch : 37 horizontal cycles
	--Sync Pulse : 6 horizontal cycles
	--Back Porch : 23 horizontal cycles
--h_sync polarity : '1'
--v_sync polarity : '1'

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity myvgacontroller is
port(reset : in std_logic;
	pixel_clk : in std_logic;
	horizontal_sync : out std_logic;
	vertical_sync : out std_logic;
	hcount : out unsigned(10 downto 0);	-- 11 bits required because these are signed numbers-MSB must be 0
	vcount : out unsigned(10 downto 0);
	blank : out std_logic);
	
end entity myvgacontroller;

architecture behavior of myvgacontroller is
constant HPXLMAX : unsigned(10 downto 0) := "10000010000";	-- 1040; maximum value for horizontal pixel counter 
	--With 50 Mhz clock, the horizontal scan takes 1040 CLOCK cycles
	
constant VLINESMAX : unsigned(10 downto 0) := "01010011010";	--  666; maximum value for vertical pixel counter
	--With 50 Mhz clock, the vertical scan takes 666 HORIZONTAL cycles

constant MAXCOL : unsigned(10 downto 0) := "01100100000";	--  800; total number of visible columns

constant MAXROW : unsigned(10 downto 0) := "01001011000";	--  600; total number of visible rows

constant HSYNC : unsigned(10 downto 0) := "01111010000";	--  976; value for the horizontal counter at which the horizontal synchronization pulse ends

constant VSYNC : unsigned(10 downto 0) := "01010000011";	--  643; value for the vertical counter at which the vertical synchronization pulse ends

constant SYNCPOL : std_logic := '1';	-- Polarity for horizontal and vertical sync pulses; 0 for both for this resolution

constant HFP   : unsigned(10 downto 0) := "01101011000";	--  856; value for the horizontal counter where the front porch ends

constant VFP   : unsigned(10 downto 0) := "01001111101";	--  637; value for the vertical counter where the front porch ends

signal internal_hcounter : unsigned(10 downto 0) := (others => '0'); -- horizontal counter
signal internal_vcounter : unsigned(10 downto 0) := (others => '0'); -- vertical counter
signal video_enable: std_logic;	-- Indicates visible area of screen


begin
	
	hcount <= internal_hcounter;
	vcount <= internal_vcounter;
	
	blank <= not video_enable when rising_edge(pixel_clk); 	-- 'blank' is active when outside the visible area.  
															--'blank is sent to the image generator which will output black color to the monitor if active
	
	-- Increment horizontal count on rising edge clock until rightmost column is reached, then reset and count again
	horizontal_count : process(pixel_clk)
	begin
		if(rising_edge(pixel_clk)) then
			if(reset = '1') then
				internal_hcounter <= (others => '0');
			elsif(internal_hcounter = HPXLMAX) then
				internal_hcounter <= (others => '0');
			else
				internal_hcounter <= internal_hcounter + 1;
			end if;
      end if;
	end process horizontal_count;

	-- Increment vertical count when one row scan is completed on rising edge clock until bottom row is reached, then reset and count again
	vertical_count : process(pixel_clk)
	begin
		if(rising_edge(pixel_clk)) then
			if(reset = '1') then
				internal_vcounter <= (others => '0');
			elsif(internal_hcounter = HPXLMAX) then
				if(internal_vcounter = VLINESMAX) then
					internal_vcounter <= (others => '0');
				else
					internal_vcounter <= internal_vcounter + 1;
				end if;
			end if;
      end if;
	end process vertical_count;
	
	-- Generate horizontal sync pulse; pulse is set when horizontal counter is between front porch and back porch
	sync_columns: process(pixel_clk)
	begin
      if(rising_edge(pixel_clk)) then
         if(internal_hcounter >= HFP and internal_hcounter < HSYNC) then
            horizontal_sync <= SYNCPOL;
         else
			horizontal_sync <= NOT SYNCPOL;
         end if;
      end if;
	end process sync_columns;
	
	-- Generate vertical sync pulse; pulse is set when vertical counter is between front porch and back porch, active for two horizontal rows
	sync_rows: process(pixel_clk)
	begin
      if(rising_edge(pixel_clk)) then
         if(internal_vcounter >= VFP and internal_vcounter < VSYNC) then
            vertical_sync <= SYNCPOL;
         else
			vertical_sync <= NOT SYNCPOL;
         end if;
      end if;
	end process sync_rows;

	 -- enable video output when pixel is in visible area
   video_enable <= '1' when (internal_hcounter < MAXCOL and internal_vcounter < MAXROW) 
					else '0';
   
 end architecture behavior;





