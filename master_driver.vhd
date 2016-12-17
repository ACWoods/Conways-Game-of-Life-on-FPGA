library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.board_pkg.all;

entity master_vga_display_driver is
port(btn : in std_logic_vector(3 downto 0);
	sw : in std_logic_vector(7 downto 0);
    clk : in std_logic;
	vgaRed : out std_logic_vector(3 downto 1);
	vgaGreen : out std_logic_vector(3 downto 1);
	vgaBlue : out std_logic_vector(3 downto 2);
	Hsync : out std_logic;
	Vsync : out std_logic);
	
end entity master_vga_display_driver;

architecture structural of master_vga_display_driver is
signal blank_internal : std_logic;
signal hc_internal : unsigned(10 downto 0);
signal vc_internal : unsigned(10 downto 0);
signal red_internal : std_logic;
signal green_internal : std_logic;
signal blue_internal : std_logic;
signal board_int : board_matrix;

constant DIVISOR_1 : integer := 25_000_000;		-- clock divisor for game of life clock
constant DIVISOR_2 : integer := 8_750_000;		-- clock divisor for button debouncer clock
signal internal_clk : std_logic;
signal button_clk_int : std_logic := '0';

-- COMPONENT DECLARATIONS OF DISPLAY DRIVER		
	
component vga_controller
port(reset : in std_logic;
	pixel_clk : in std_logic;
	horizontal_sync : out std_logic;
	vertical_sync : out std_logic;
	hcount : out unsigned(10 downto 0);
	vcount : out unsigned(10 downto 0);
	blank : out std_logic);
end component vga_controller;


component img_generator
port(reset : in std_logic;
	column, row: in unsigned(10 downto 0);
	blank : in std_logic;
	pattern_signal : in std_logic;
	button : in std_logic_vector(3 downto 0);
	user_input : in std_logic;
	in_clk : in std_logic;
	button_clk : in std_logic;
	red, green, blue : out std_logic);
end component img_generator;



-- BINDING INDICATIONS
for all : vga_controller use entity work.myvgacontroller(behavior);
for all : img_generator use entity work.img_generator(dataflow);

begin

	vgaRed(1) <= red_internal;
	vgaRed(2) <= red_internal;
	vgaRed(3) <= red_internal;
	
	vgaGreen(1) <= green_internal;
	vgaGreen(2) <= green_internal;
	vgaGreen(3) <= green_internal;
	
	vgaBlue(2) <= blue_internal;
	vgaBlue(3) <= blue_internal;
	

	-- COMPONENT INSTANTIATIONS
	I1: vga_controller port map(reset => sw(6),
								pixel_clk => clk,
								horizontal_sync => Hsync,	-- As defined in 1200 series general .ucf file
								vertical_sync => Vsync,
								hcount => hc_internal,
								vcount => vc_internal,
								blank => blank_internal);
									
									
	I2: img_generator port map(reset => sw(2),
								column => hc_internal,
								row => vc_internal,
								blank => blank_internal,
								pattern_signal => sw(1),
								user_input => sw(7),
								button => btn,
								in_clk => internal_clk,
								button_clk => button_clk_int,
								red => red_internal,
								green => green_internal,
								blue => blue_internal);							

								
	-- DIVISOR = 50,000,000 Hz / 2 Hz = 25,000,000
	-- Therefore, 25,000,000 cycles of the 50 MHz clock make one cycle of the 2 Hz signal.
		
	clock_divider : process(clk,sw(0)) -- divide clock by DIVISOR for game of life signal
	variable count : integer range 0 to DIVISOR_1/2 := 0;
	
	begin
		if(sw(0) = '0') then
         internal_clk <= '0';
         count := 0;
		elsif(rising_edge(clk)) then
			if(count = (DIVISOR_1/2) - 1) then		-- Minus 1 required because internal_clk needs to pulse on every DIVISORth pulse, not on every pulse immediately succeeding the DIVISORth pulse
				internal_clk <= NOT internal_clk;
				count := 0;
			else
				count := count + 1;
			end if;
		end if;
		 
	end process clock_divider;
	
	debouncer_clock_divider : process(clk) -- divide clock by DIVISOR for game of life signal
	variable count : integer range 0 to DIVISOR_2/2 := 0;
	
	begin
		if(rising_edge(clk)) then
			if(count = (DIVISOR_2/2) - 1) then		-- Minus 1 required because button_clk needs to pulse on every DIVISORth pulse, not on every pulse immediately succeeding the DIVISORth pulse
				button_clk_int <= NOT button_clk_int;
				count := 0;
			else
				count := count + 1;
			end if;
		end if;
		 
	end process debouncer_clock_divider;
	
	

									
									
end architecture structural;