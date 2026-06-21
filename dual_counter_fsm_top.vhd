library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dual_counter_fsm_top is
    Port ( clk     : in  STD_LOGIC;
           rst     : in  STD_LOGIC;
           -- 計數器 A 設定
           up_A    : in  STD_LOGIC;
           low_A   : in  STD_LOGIC_VECTOR (3 downto 0);
           high_A  : in  STD_LOGIC_VECTOR (3 downto 0);
           out_A   : out STD_LOGIC_VECTOR (3 downto 0);
           -- 計數器 B 設定
           up_B    : in  STD_LOGIC;
           low_B   : in  STD_LOGIC_VECTOR (3 downto 0);
           high_B  : in  STD_LOGIC_VECTOR (3 downto 0);
           out_B   : out STD_LOGIC_VECTOR (3 downto 0)
         );
end dual_counter_fsm_top;

architecture Behavioral of dual_counter_fsm_top is
    -- 宣告子模組
    component configurable_counter
        port( clk, rst, en, up_down : in STD_LOGIC;
              lower_bound, upper_bound : in STD_LOGIC_VECTOR(3 downto 0);
              count_out : out STD_LOGIC_VECTOR(3 downto 0);
              done : out STD_LOGIC );
    end component;

    -- 內部橋接線
    signal en_A, en_B     : STD_LOGIC;
    signal done_A, done_B : STD_LOGIC;

    -- ? 定義狀態機的狀態種類
    type state_type is (STATE_A, STATE_B);
    signal current_state, next_state : state_type;

begin

    -- 實體化 Counter A & B 
    Counter_Instance_A: configurable_counter port map (
        clk => clk, rst => rst, en => en_A, up_down => up_A,
        lower_bound => low_A, upper_bound => high_A, count_out => out_A, done => done_A );

    Counter_Instance_B: configurable_counter port map (
        clk => clk, rst => rst, en => en_B, up_down => up_B,
        lower_bound => low_B, upper_bound => high_B, count_out => out_B, done => done_B );

    -- ? FSM 狀態暫存器處理 (時脈正緣觸發轉換)
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= STATE_A; -- 重置時預設先讓 A 跑
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- ? FSM 狀態轉移邏輯
    process(current_state, done_A, done_B)
    begin
        case current_state is
            when STATE_A =>
                if done_A = '1' then
                    next_state <= STATE_B; -- A 數完了，交棒給 B
                else
                    next_state <= STATE_A; -- A 還沒數完，繼續保持
                end if;

            when STATE_B =>
                if done_B = '1' then
                    next_state <= STATE_A; -- B 數完了，交棒回 A
                else
                    next_state <= STATE_B; -- B 還沒數完，繼續保持
                end if;
        end case;
    end process;

    -- ? 根據目前的狀態，決定開啟哪一個計數器的電路 (解碼電路)
    en_A <= '1' when current_state = STATE_A else '0';
    en_B <= '1' when current_state = STATE_B else '0';

end Behavioral;