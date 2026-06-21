# Project 3: Dual Counter with FSM Control (雙計數器輪流計數控制系統)

## 項目簡介 (Project Description)
本項目為 FPGA 數位電路設計之 **Project 3：設計一個有限狀態機 (FSM) 控制兩個獨立計數器進行輪流計數**。

系統內部包含兩個可動態配置上下限與計數方向的通用計數器（Counter A & B）。透過頂層的 2-State FSM 進行硬體排程管理：當 Counter A 被致能並完成指定範圍的計數後，會發出完成訊號通知 FSM 切換至 Counter B；此時 Counter A 暫停，換 Counter B 開始計數，直到 Counter B 也完成計數後再切換回 Counter A。系統以此邏輯不斷循環，實現完美的硬體輪流調度。

---

## 硬體架構圖 (Block Diagram)

本專案架構採用 Mermaid 語法繪製，原生支援 GitHub 深色與淺色主題切換。

```mermaid
flowchart TD
    %% 外部輸入訊號
    clk([外部輸入 clk])
    rst([外部輸入 rst])
    inputs_A[輸入設定: up_A, low_A, high_A]
    inputs_B[輸入設定: up_B, low_B, high_B]

    %% 核心控制與計數單元
    FSM["【 FSM 核心控制狀態機 】<br/>- 狀態: STATE_A (A計數) / STATE_B (B計數)<br/>- 依據 done_A / done_B 進行狀態交替切換"]
    
    Counter_A["【 Counter_Instance_A 】<br/>(可配置計數器 A)<br/>- 依據 low_A / high_A 範圍計數<br/>- 數到邊界時發出 done_A"]
    
    Counter_B["【 Counter_Instance_B 】<br/>(可配置計數器 B)<br/>- 依據 low_B / high_B 範圍計數<br/>- 數到邊界時發出 done_B"]

    %% 時脈與重置連線
    clk --> FSM
    clk --> Counter_A
    clk --> Counter_B
    rst --> FSM
    rst --> Counter_A
    rst --> Counter_B

    %% 設定參數連線
    inputs_A --> Counter_A
    inputs_B --> Counter_B

    %% FSM 與計數器互動控制
    FSM -->|en_A 致能訊號| Counter_A
    FSM -->|en_B 致能訊號| Counter_B
    Counter_A -->|done_A 完成訊號| FSM
    Counter_B -->|done_B 完成訊號| FSM

    %% 外部輸出
    Counter_A --> out_A([頂層輸出端口 out_A])
    Counter_B --> out_B([頂層輸出端口 out_B])

```

---

## 模組設計說明 (Module Specifications)

### 1. 可配置計數器模組 (`configurable_counter.vhd`)

* **動態邊界**：支援透過外部輸入即時變更計數下限（`lower_bound`）與上限（`upper_bound`）。
* **方向控制**：藉由 `up_down` 訊號控制計數器為正向上數（`1`）或反向下數（`0`）。
* **自動邊界判定**：當計數值抵達設定的極限時，內部組合邏輯會立刻拉高 `done` 訊號，並在下一個時脈正緣自動執行 Wrap-around（歸繞）回到起始點。

### 2. 頂層控制模組 (`dual_counter_fsm_top.vhd`)

* **FSM 狀態機核心**：內建 `STATE_A` 與 `STATE_B` 兩個狀態，專職負責雙計數器的排程控制。
* **狀態轉移邏輯**：
* 處於 `STATE_A` 時：僅拉高 `en_A` 啟用 Counter A。當接收到 `done_A = '1'` 時，下一狀態轉移至 `STATE_B`。
* 處於 `STATE_B` 時：僅拉高 `en_B` 啟用 Counter B。當接收到 `done_B = '1'` 時，下一狀態跳回 `STATE_A`。



### 3. 測試平台 (`tb_dual_counter_fsm.vhd`)

* **時脈模擬**：產生週期為 10ns（頻率 100MHz）的系統時脈。
* **硬體測試配置**：
* **Counter A**：配置為 `up_A = '1'`（上數），範圍 `0000` 到 `0111`（0 至 7）。
* **Counter B**：配置為 `up_B = '0'`（下數），範圍 `1111` 到 `1000`（15 至 8）。



---

## 模擬環境與運行指引 (How to Run)

1. 將 `configurable_counter.vhd` 與 `dual_counter_fsm_top.vhd` 檔案加入至 **Xilinx Vivado** 專案的 `Design Sources` 中。
2. 將 `tb_dual_counter_fsm.vhd` 加入至 `Simulation Sources` 中。
3. 在 Vivado 左側選單點擊 **Run Simulation -> Run Behavioral Simulation**。
4. 觀察波形：驗證 `out_A` 從 0 數到 7 結束後，是否立即保持定值，並由 `out_B` 接手從 15 倒數到 8。

```
