library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity configurable_counter is
    Port ( clk         : in  STD_LOGIC;
           rst         : in  STD_LOGIC;
           en          : in  STD_LOGIC;
           up_down     : in  STD_LOGIC;
           lower_bound : in  STD_LOGIC_VECTOR (3 downto 0);
           upper_bound : in  STD_LOGIC_VECTOR (3 downto 0);
           count_out   : out STD_LOGIC_VECTOR (3 downto 0);
           done        : out STD_LOGIC                     -- ? 新增：完成一輪的通知訊號
         );
end configurable_counter;

architecture Behavioral of configurable_counter is
    signal cnt_reg : unsigned(3 downto 0) := (others => '0');
begin
    count_out <= std_logic_vector(cnt_reg);

    -- ? 邏輯判斷：當計數器走到邊界且正在計數時，done 拉高為 '1'
    done <= '1' when (en = '1' and up_down = '1' and cnt_reg = unsigned(upper_bound)) else
            '1' when (en = '1' and up_down = '0' and cnt_reg = unsigned(lower_bound)) else
            '0';

    process(clk, rst)
    begin
        if rst = '1' then
            -- ? 換成這段：讓硬體根據「方向」決定重置的起跑點
            if up_down = '1' then
                cnt_reg <= unsigned(lower_bound); -- 上數晶片（Counter A）：重置回下限
            else
                cnt_reg <= unsigned(upper_bound); -- 下數晶片（Counter B）：重置回上限
            end if;
            
        elsif rising_edge(clk) then
            if en = '1' then
                if up_down = '1' then
                    if cnt_reg >= unsigned(upper_bound) or cnt_reg < unsigned(lower_bound) then
                        cnt_reg <= unsigned(lower_bound);
                    else
                        cnt_reg <= cnt_reg + 1;
                    end if;
                else
                    if cnt_reg <= unsigned(lower_bound) or cnt_reg > unsigned(upper_bound) then
                        cnt_reg <= unsigned(upper_bound);
                    else
                        cnt_reg <= cnt_reg - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;