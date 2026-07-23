library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_dual_counter_fsm is
end tb_dual_counter_fsm;

architecture Behavior of tb_dual_counter_fsm is 
    component dual_counter_fsm_top
    port( clk, rst, up_A, up_B : in std_logic;
          low_A, high_A, low_B, high_B : in std_logic_vector(3 downto 0);
          out_A, out_B : out std_logic_vector(3 downto 0) );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal up_A : std_logic := '0'; -- A 上數
    signal up_B : std_logic := '1'; -- B 下數
    signal low_A : std_logic_vector(3 downto 0) := "0010";  -- 1
    signal high_A : std_logic_vector(3 downto 0) := "0111"; -- 4
    signal low_B : std_logic_vector(3 downto 0) := "0100";  -- 5
    signal high_B : std_logic_vector(3 downto 0) := "1111"; -- 8
    signal out_A, out_B : std_logic_vector(3 downto 0);

begin
    uut: dual_counter_fsm_top port map ( clk=>clk, rst=>rst, up_A=>up_A, low_A=>low_A, high_A=>high_A, out_A=>out_A,
                                         up_B=>up_B, low_B=>low_B, high_B=>high_B, out_B=>out_B );

    clk <= not clk after 5 ns; -- 10ns 時脈週期

    stim_proc: process
    begin		
        rst <= '1'; wait for 20 ns; rst <= '0';
        wait for 1000 ns;
        wait;
    end process;
end Behavior;