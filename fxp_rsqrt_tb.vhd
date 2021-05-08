--testbench based off of HW 3's tb

library ieee;
use ieee.std_logic_1164.all;    -- IEEE standard for digital logic values
use ieee.numeric_std.all;       -- arithmetic functions for vectors
use std.textio.all;             -- Needed for file functions
use ieee.std_logic_textio.all;  -- Needed for std_logic_vector
use work.txt_util.all;

entity fxp_rsqrt_tb is

end entity;

architecture fxp_rsqrt_tb_arch of fxp_rsqrt_tb is

	constant clock_half_p : time := 10 ns;
	signal clk : std_logic := '0';

	constant W_bits : positive := 32;
	constant F_bits : positive := 16;
	constant N_iterations : positive := 3;

	signal input_sig : std_logic_vector(W_bits - 1 downto 0) := (others => '0');
	signal output_sig : std_logic_vector(W_bits - 1 downto 0) := (others => '0');
	


    	function to_std_logic_vector(s: string) return std_logic_vector is
        	variable slv: std_logic_vector(s'high-s'low downto 0);
       		variable k: integer;
    	begin
        	k := s'high-s'low;
        	for i in s'range loop
            	slv(k) := to_std_logic(s(i));
            	k := k - 1;
        	end loop;
        	return slv;
    	end to_std_logic_vector;

	component fxp_rsqrt is
		generic(W_bits : positive := 32;
			F_bits : positive := 16;
			N_iterations : positive := 3);

		port(clk : in std_logic;
	     	x : in std_logic_vector(W_bits-1 downto 0);
	     	y : out std_logic_vector(W_bits-1 downto 0));
	end component;

	begin

	DUT: fxp_rsqrt
		generic map(W_bits	=> W_bits,
			F_bits		=> F_bits,
			N_Iterations    => N_iterations)
		port map(clk		=> clk,
			 x		=> input_sig,
			 y		=> output_sig);

	clk <= not clk after clock_half_p;


    process
        file read_file_pointer   : text;
        file write_file_pointer  : text;
        variable line_in         : line;
        variable line_out        : line;
        variable input_string    : string(W_bits downto 1);
        variable input_vector    : std_logic_vector(W_bits-1 downto 0);
        --variable input_variable  : std_logic_vector(W_WIDTH-1 downto 0);
    begin
        file_open(read_file_pointer,  "fxp_rsqrt_input.txt",  read_mode);
        file_open(write_file_pointer, "fxp_rsqrt_output.txt", write_mode);
        while not endfile(read_file_pointer) loop
            readline(read_file_pointer, line_in);
            read(line_in, input_string);
            input_vector := to_std_logic_vector(input_string);
            report "line in = " & line_in.all & " value in = " & integer'image(to_integer(unsigned(input_vector)));
            input_sig <= input_vector; 
            write(line_out, output_sig, right, W_bits);
            writeline(write_file_pointer, line_out);
            wait until rising_edge(clk);
        end loop; 
        file_close(read_file_pointer);
        file_close(write_file_pointer);
        wait;
   end process;
 

end architecture;