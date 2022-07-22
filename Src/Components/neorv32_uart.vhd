-- #################################################################################################
-- # << NEORV32 - Universal Asynchronous Receiver and Transmitter (UART0/1) >>                     #
-- # ********************************************************************************************* #
-- # Frame configuration: 1 start bit, 8 bit data, parity bit (none/even/odd), 1 stop bit,         #
-- # programmable BAUD rate via clock pre-scaler and 12-bit BAUD value configuration register,     #
-- # optional configurable RX and TX FIFOs.                                                        #
-- #                                                                                               #
-- # Interrupts: Configurable RX and TX interrupt (both triggered by specific FIFO fill-levels)    #
-- #                                                                                               #
-- # Support for RTS("RTR")/CTS hardware flow control:                                             #
-- # * uart_rts_o = 0: RX is ready to receive a new char, enabled via CTRL.ctrl_rts_en_c           #
-- # * uart_cts_i = 0: TX is allowed to send a new char, enabled via CTRL.ctrl_cts_en_c            #
-- #                                                                                               #
-- # UART0 / UART1:                                                                                #
-- # This module is used for implementing UART0 and UART1. The UART_PRIMARY generic configures the #
-- # interface register addresses and simulation outputs for UART0 (UART_PRIMARY = true) or UART1  #
-- # (UART_PRIMARY = false).                                                                       #
-- #                                                                                               #
-- # SIMULATION MODE:                                                                              #
-- # When the simulation mode is enabled (setting the ctrl.ctrl_sim_en_c bit) any write            #
-- # access to the TX register will not trigger any UART activity. Instead, the written data is    #
-- # output to the simulation environment. The lowest 8 bits of the written data are printed as    #
-- # ASCII char to the simulator console.                                                          #
-- # This char is also stored to the file "neorv32.uartX.sim_mode.text.out" (where X = 0 for UART0 #
-- # and X = 1 for UART1). The full 32-bit write data is also stored as 8-digit hexadecimal value  #
-- # to the file "neorv32.uartX.sim_mode.data.out" (where X = 0 for UART0 and X = 1 for UART1).    #
-- # No interrupts are triggered when in SIMULATION MODE.                                          #
-- # ********************************************************************************************* #
-- # BSD 3-Clause License                                                                          #
-- #                                                                                               #
-- # Copyright (c) 2021, Stephan Nolting. All rights reserved.                                     #
-- #                                                                                               #
-- # Redistribution and use in source and binary forms, with or without modification, are          #
-- # permitted provided that the following conditions are met:                                     #
-- #                                                                                               #
-- # 1. Redistributions of source code must retain the above copyright notice, this list of        #
-- #    conditions and the following disclaimer.                                                   #
-- #                                                                                               #
-- # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
-- #    conditions and the following disclaimer in the documentation and/or other materials        #
-- #    provided with the distribution.                                                            #
-- #                                                                                               #
-- # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
-- #    endorse or promote products derived from this software without specific prior written      #
-- #    permission.                                                                                #
-- #                                                                                               #
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
-- # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
-- # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
-- # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
-- # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
-- # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
-- # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
-- # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
-- # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
-- # ********************************************************************************************* #
-- # The NEORV32 Processor - https://github.com/stnolting/neorv32              (c) Stephan Nolting #
-- #################################################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY neorv32;
USE neorv32.neorv32_package.ALL;
USE std.textio.ALL;

ENTITY neorv32_uart IS
  GENERIC (
    UART_PRIMARY : BOOLEAN; -- true = primary UART (UART0), false = secondary UART (UART1)
    UART_RX_FIFO : NATURAL; -- RX fifo depth, has to be a power of two, min 1
    UART_TX_FIFO : NATURAL -- TX fifo depth, has to be a power of two, min 1
  );
  PORT (
    -- host access --
    clk_i : IN STD_LOGIC; -- global clock line
    addr_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- address
    rden_i : IN STD_LOGIC; -- read enable
    wren_i : IN STD_LOGIC; -- write enable
    data_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- data in
    data_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- data out
    ack_o : OUT STD_LOGIC; -- transfer acknowledge
    -- clock generator --
    clkgen_en_o : OUT STD_LOGIC; -- enable clock generator
    clkgen_i : IN STD_LOGIC_VECTOR(07 DOWNTO 0);
    -- com lines --
    uart_txd_o : OUT STD_LOGIC;
    uart_rxd_i : IN STD_LOGIC;
    -- hardware flow control --
    uart_rts_o : OUT STD_LOGIC; -- UART.RX ready to receive ("RTR"), low-active, optional
    uart_cts_i : IN STD_LOGIC; -- UART.TX allowed to transmit, low-active, optional
    -- interrupts --
    irq_rxd_o : OUT STD_LOGIC; -- uart data received interrupt
    irq_txd_o : OUT STD_LOGIC -- uart transmission done interrupt
  );
END neorv32_uart;

ARCHITECTURE neorv32_uart_rtl OF neorv32_uart IS

  -- interface configuration for UART0 / UART1 --
  CONSTANT uart_id_base_c : STD_LOGIC_VECTOR(data_width_c - 1 DOWNTO 0) := cond_sel_stdulogicvector_f(UART_PRIMARY, uart0_base_c, uart1_base_c);
  CONSTANT uart_id_size_c : NATURAL := cond_sel_natural_f(UART_PRIMARY, uart0_size_c, uart1_size_c);
  CONSTANT uart_id_ctrl_addr_c : STD_LOGIC_VECTOR(data_width_c - 1 DOWNTO 0) := cond_sel_stdulogicvector_f(UART_PRIMARY, uart0_ctrl_addr_c, uart1_ctrl_addr_c);
  CONSTANT uart_id_rtx_addr_c : STD_LOGIC_VECTOR(data_width_c - 1 DOWNTO 0) := cond_sel_stdulogicvector_f(UART_PRIMARY, uart0_rtx_addr_c, uart1_rtx_addr_c);

  -- IO space: module base address --
  CONSTANT hi_abb_c : NATURAL := index_size_f(io_size_c) - 1; -- high address boundary bit
  CONSTANT lo_abb_c : NATURAL := index_size_f(uart_id_size_c); -- low address boundary bit

  -- simulation output configuration --
  CONSTANT sim_screen_output_en_c : BOOLEAN := true; -- output lowest byte as char to simulator console when enabled
  CONSTANT sim_text_output_en_c : BOOLEAN := true; -- output lowest byte as char to text file when enabled
  CONSTANT sim_data_output_en_c : BOOLEAN := true; -- dump 32-bit TX word to file when enabled
  CONSTANT sim_uart_text_file_c : STRING := cond_sel_string_f(UART_PRIMARY, "neorv32.uart0.sim_mode.text.out", "neorv32.uart1.sim_mode.text.out");
  CONSTANT sim_uart_data_file_c : STRING := cond_sel_string_f(UART_PRIMARY, "neorv32.uart0.sim_mode.data.out", "neorv32.uart1.sim_mode.data.out");

  -- control register --
  SIGNAL ctrl : STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- control register bits --
  CONSTANT ctrl_baud00_c : NATURAL := 0; -- r/w: baud config bit 0
  CONSTANT ctrl_baud01_c : NATURAL := 1; -- r/w: baud config bit 1
  CONSTANT ctrl_baud02_c : NATURAL := 2; -- r/w: baud config bit 2
  CONSTANT ctrl_baud03_c : NATURAL := 3; -- r/w: baud config bit 3
  CONSTANT ctrl_baud04_c : NATURAL := 4; -- r/w: baud config bit 4
  CONSTANT ctrl_baud05_c : NATURAL := 5; -- r/w: baud config bit 5
  CONSTANT ctrl_baud06_c : NATURAL := 6; -- r/w: baud config bit 6
  CONSTANT ctrl_baud07_c : NATURAL := 7; -- r/w: baud config bit 7
  CONSTANT ctrl_baud08_c : NATURAL := 8; -- r/w: baud config bit 8
  CONSTANT ctrl_baud09_c : NATURAL := 9; -- r/w: baud config bit 9
  CONSTANT ctrl_baud10_c : NATURAL := 10; -- r/w: baud config bit 10
  CONSTANT ctrl_baud11_c : NATURAL := 11; -- r/w: baud config bit 11
  CONSTANT ctrl_sim_en_c : NATURAL := 12; -- r/w: UART <<SIMULATION MODE>> enable
  CONSTANT ctrl_rx_empty_c : NATURAL := 13; -- r/-: RX FIFO is empty
  CONSTANT ctrl_rx_half_c : NATURAL := 14; -- r/-: RX FIFO is at least half-full
  CONSTANT ctrl_rx_full_c : NATURAL := 15; -- r/-: RX FIFO is full
  CONSTANT ctrl_tx_empty_c : NATURAL := 16; -- r/-: TX FIFO is empty
  CONSTANT ctrl_tx_half_c : NATURAL := 17; -- r/-: TX FIFO is at least half-full
  CONSTANT ctrl_tx_full_c : NATURAL := 18; -- r/-: TX FIFO is full
  -- ...
  CONSTANT ctrl_rts_en_c : NATURAL := 20; -- r/w: enable hardware flow control: assert rts_o if ready to receive
  CONSTANT ctrl_cts_en_c : NATURAL := 21; -- r/w: enable hardware flow control: send only if cts_i is asserted
  CONSTANT ctrl_pmode0_c : NATURAL := 22; -- r/w: Parity config (0=even; 1=odd)
  CONSTANT ctrl_pmode1_c : NATURAL := 23; -- r/w: Enable parity bit
  CONSTANT ctrl_prsc0_c : NATURAL := 24; -- r/w: baud prsc bit 0
  CONSTANT ctrl_prsc1_c : NATURAL := 25; -- r/w: baud prsc bit 1
  CONSTANT ctrl_prsc2_c : NATURAL := 26; -- r/w: baud prsc bit 2
  CONSTANT ctrl_cts_c : NATURAL := 27; -- r/-: current state of CTS input
  CONSTANT ctrl_en_c : NATURAL := 28; -- r/w: UART enable
  CONSTANT ctrl_rx_irq_c : NATURAL := 29; -- r/w: RX IRQ mode: 1=FIFO at least half-full; 0=FIFO not empty
  CONSTANT ctrl_tx_irq_c : NATURAL := 30; -- r/w: TX IRQ mode: 1=FIFO less than half-full; 0=FIFO not full
  CONSTANT ctrl_tx_busy_c : NATURAL := 31; -- r/-: UART transmitter is busy

  -- data register flags --
  CONSTANT data_lsb_c : NATURAL := 0; -- r/-: received char LSB
  CONSTANT data_msb_c : NATURAL := 7; -- r/-: received char MSB
  -- ...
  CONSTANT data_rx_perr_c : NATURAL := 28; -- r/-: RX parity error
  CONSTANT data_rx_ferr_c : NATURAL := 29; -- r/-: RX frame error
  CONSTANT data_rx_overr_c : NATURAL := 30; -- r/-: RX data overrun
  CONSTANT data_rx_avail_c : NATURAL := 31; -- r/-: RX data available

  -- access control --
  SIGNAL acc_en : STD_LOGIC; -- module access enable
  SIGNAL addr : STD_LOGIC_VECTOR(31 DOWNTO 0); -- access address
  SIGNAL wren : STD_LOGIC; -- word write enable
  SIGNAL rden : STD_LOGIC; -- read enable

  -- clock generator --
  SIGNAL uart_clk : STD_LOGIC;

  -- numbers of bits in transmission frame --
  SIGNAL num_bits : STD_LOGIC_VECTOR(3 DOWNTO 0);

  -- hardware flow-control IO buffer --
  SIGNAL uart_cts_ff : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL uart_rts : STD_LOGIC;

  -- UART transmitter --
  TYPE tx_state_t IS (S_TX_IDLE, S_TX_GET, S_TX_CHECK, S_TX_TRANSMIT, S_TX_SIM);
  TYPE tx_engine_t IS RECORD
    state : tx_state_t;
    busy : STD_LOGIC;
    done : STD_LOGIC;
    bitcnt : STD_LOGIC_VECTOR(03 DOWNTO 0);
    sreg : STD_LOGIC_VECTOR(10 DOWNTO 0);
    baud_cnt : STD_LOGIC_VECTOR(11 DOWNTO 0);
    cts : STD_LOGIC; -- allow new transmission when 1
  END RECORD;
  SIGNAL tx_engine : tx_engine_t;

  -- UART receiver --
  TYPE rx_state_t IS (S_RX_IDLE, S_RX_RECEIVE);
  TYPE rx_engine_t IS RECORD
    state : rx_state_t;
    done : STD_LOGIC;
    sync : STD_LOGIC_VECTOR(04 DOWNTO 0);
    bitcnt : STD_LOGIC_VECTOR(03 DOWNTO 0);
    sreg : STD_LOGIC_VECTOR(09 DOWNTO 0);
    baud_cnt : STD_LOGIC_VECTOR(11 DOWNTO 0);
    overr : STD_LOGIC;
    rtr : STD_LOGIC; -- ready to receive when 1
  END RECORD;
  SIGNAL rx_engine : rx_engine_t;

  -- TX FIFO --
  TYPE tx_buffer_t IS RECORD
    we : STD_LOGIC; -- write enable
    re : STD_LOGIC; -- read enable
    clear : STD_LOGIC; -- sync reset, high-active
    wdata : STD_LOGIC_VECTOR(31 DOWNTO 0); -- write data
    rdata : STD_LOGIC_VECTOR(31 DOWNTO 0); -- read data
    avail : STD_LOGIC; -- data available?
    free : STD_LOGIC; -- free entry available?
    half : STD_LOGIC; -- half full
  END RECORD;
  SIGNAL tx_buffer : tx_buffer_t;

  -- RX FIFO --
  TYPE rx_buffer_t IS RECORD
    we : STD_LOGIC; -- write enable
    re : STD_LOGIC; -- read enable
    clear : STD_LOGIC; -- sync reset, high-active
    wdata : STD_LOGIC_VECTOR(9 DOWNTO 0); -- write data
    rdata : STD_LOGIC_VECTOR(9 DOWNTO 0); -- read data
    avail : STD_LOGIC; -- data available?
    free : STD_LOGIC; -- free entry available?
    half : STD_LOGIC; -- half full
  END RECORD;
  SIGNAL rx_buffer : rx_buffer_t;

  -- interrupt generator --
  TYPE irq_t IS RECORD
    set : STD_LOGIC;
    buf : STD_LOGIC_VECTOR(1 DOWNTO 0);
  END RECORD;
  SIGNAL rx_irq, tx_irq : irq_t;

BEGIN

  -- Sanity Checks --------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  ASSERT NOT (is_power_of_two_f(UART_RX_FIFO) = false) REPORT "NEORV32 PROCESSOR CONFIG ERROR: UART" &
  cond_sel_string_f(UART_PRIMARY, "0", "1") & " <UART_RX_FIFO> has to be a power of two." SEVERITY error;
  ASSERT NOT (is_power_of_two_f(UART_TX_FIFO) = false) REPORT "NEORV32 PROCESSOR CONFIG ERROR: UART" &
  cond_sel_string_f(UART_PRIMARY, "0", "1") & " <UART_TX_FIFO> has to be a power of two." SEVERITY error;
  -- Access Control -------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  acc_en <= '1' WHEN (addr_i(hi_abb_c DOWNTO lo_abb_c) = uart_id_base_c(hi_abb_c DOWNTO lo_abb_c)) ELSE
    '0';
  addr <= uart_id_base_c(31 DOWNTO lo_abb_c) & addr_i(lo_abb_c - 1 DOWNTO 2) & "00"; -- word aligned
  wren <= acc_en AND wren_i;
  rden <= acc_en AND rden_i;
  -- Read/Write Access ----------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  rw_access : PROCESS (clk_i)
  BEGIN
    IF rising_edge(clk_i) THEN
      -- bus access acknowledge --
      ack_o <= wren OR rden;

      -- write access --
      IF (wren = '1') THEN
        IF (addr = uart_id_ctrl_addr_c) THEN
          ctrl <= (OTHERS => '0');
          ctrl(ctrl_baud11_c DOWNTO ctrl_baud00_c) <= data_i(ctrl_baud11_c DOWNTO ctrl_baud00_c);
          ctrl(ctrl_sim_en_c) <= data_i(ctrl_sim_en_c);
          ctrl(ctrl_pmode1_c DOWNTO ctrl_pmode0_c) <= data_i(ctrl_pmode1_c DOWNTO ctrl_pmode0_c);
          ctrl(ctrl_prsc2_c DOWNTO ctrl_prsc0_c) <= data_i(ctrl_prsc2_c DOWNTO ctrl_prsc0_c);
          ctrl(ctrl_rts_en_c) <= data_i(ctrl_rts_en_c);
          ctrl(ctrl_cts_en_c) <= data_i(ctrl_cts_en_c);
          ctrl(ctrl_rx_irq_c) <= data_i(ctrl_rx_irq_c);
          ctrl(ctrl_tx_irq_c) <= data_i(ctrl_tx_irq_c);
          ctrl(ctrl_en_c) <= data_i(ctrl_en_c);
        END IF;
      END IF;

      -- read access --
      data_o <= (OTHERS => '0');
      IF (rden = '1') THEN
        IF (addr = uart_id_ctrl_addr_c) THEN
          data_o(ctrl_baud11_c DOWNTO ctrl_baud00_c) <= ctrl(ctrl_baud11_c DOWNTO ctrl_baud00_c);
          data_o(ctrl_sim_en_c) <= ctrl(ctrl_sim_en_c);
          data_o(ctrl_pmode1_c DOWNTO ctrl_pmode0_c) <= ctrl(ctrl_pmode1_c DOWNTO ctrl_pmode0_c);
          data_o(ctrl_prsc2_c DOWNTO ctrl_prsc0_c) <= ctrl(ctrl_prsc2_c DOWNTO ctrl_prsc0_c);
          data_o(ctrl_rts_en_c) <= ctrl(ctrl_rts_en_c);
          data_o(ctrl_cts_en_c) <= ctrl(ctrl_cts_en_c);
          data_o(ctrl_rx_empty_c) <= NOT rx_buffer.avail;
          data_o(ctrl_rx_half_c) <= rx_buffer.half;
          data_o(ctrl_rx_full_c) <= NOT rx_buffer.free;
          data_o(ctrl_tx_empty_c) <= NOT tx_buffer.avail;
          data_o(ctrl_tx_half_c) <= tx_buffer.half;
          data_o(ctrl_tx_full_c) <= NOT tx_buffer.free;
          data_o(ctrl_en_c) <= ctrl(ctrl_en_c);
          data_o(ctrl_rx_irq_c) <= ctrl(ctrl_rx_irq_c) AND bool_to_ulogic_f(BOOLEAN(UART_RX_FIFO > 1)); -- tie to zero if UART_RX_FIFO = 1
          data_o(ctrl_tx_irq_c) <= ctrl(ctrl_tx_irq_c) AND bool_to_ulogic_f(BOOLEAN(UART_TX_FIFO > 1)); -- tie to zero if UART_TX_FIFO = 1
          data_o(ctrl_tx_busy_c) <= tx_engine.busy;
          data_o(ctrl_cts_c) <= uart_cts_ff(1);
        ELSE -- uart_id_rtx_addr_c
          data_o(data_msb_c DOWNTO data_lsb_c) <= rx_buffer.rdata(7 DOWNTO 0);
          data_o(data_rx_perr_c) <= rx_buffer.rdata(8);
          data_o(data_rx_ferr_c) <= rx_buffer.rdata(9);
          data_o(data_rx_overr_c) <= rx_engine.overr;
          data_o(data_rx_avail_c) <= rx_buffer.avail; -- data available (valid?)
        END IF;
      END IF;
    END IF;
  END PROCESS rw_access;

  -- number of bits to be sampled --
  -- if parity flag is ENABLED:  11 bit -> "1011" (1 start bit + 8 data bits + 1 parity bit + 1 stop bit)
  -- if parity flag is DISABLED: 10 bit -> "1010" (1 start bit + 8 data bits + 1 stop bit)
  num_bits <= "1011" WHEN (ctrl(ctrl_pmode1_c) = '1') ELSE
    "1010";
  -- Clock Selection ------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  -- clock enable --
  clkgen_en_o <= ctrl(ctrl_en_c);

  -- uart clock select --
  uart_clk <= clkgen_i(to_integer(unsigned(ctrl(ctrl_prsc2_c DOWNTO ctrl_prsc0_c))));
  -- TX FIFO --------------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  tx_engine_fifo_inst : neorv32_fifo
  GENERIC MAP(
    FIFO_DEPTH => UART_TX_FIFO, -- number of fifo entries; has to be a power of two; min 1
    FIFO_WIDTH => 32, -- size of data elements in fifo (32-bit only for simulation)
    FIFO_RSYNC => false, -- async read
    FIFO_SAFE => true -- safe access
  )
  PORT MAP(
    -- control --
    clk_i => clk_i, -- clock, rising edge
    rstn_i => '1', -- async reset, low-active
    clear_i => tx_buffer.clear, -- sync reset, high-active
    level_o => OPEN,
    half_o => tx_buffer.half, -- FIFO at least half-full
    -- write port --
    wdata_i => tx_buffer.wdata, -- write data
    we_i => tx_buffer.we, -- write enable
    free_o => tx_buffer.free, -- at least one entry is free when set
    -- read port --
    re_i => tx_buffer.re, -- read enable
    rdata_o => tx_buffer.rdata, -- read data
    avail_o => tx_buffer.avail -- data available when set
  );

  -- control --
  tx_buffer.clear <= NOT ctrl(ctrl_en_c);

  -- write access --
  tx_buffer.we <= '1' WHEN (wren = '1') AND (addr = uart_id_rtx_addr_c) ELSE
  '0';
  tx_buffer.wdata <= data_i;
  -- UART Transmitter Engine ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  uart_tx_engine : PROCESS (clk_i)
  BEGIN
    IF rising_edge(clk_i) THEN
      -- defaults --
      uart_txd_o <= '1'; -- keep TX line idle (=high) if waiting for permission to start sending (->CTS)
      tx_buffer.re <= '0';
      tx_engine.done <= '0';

      -- FSM --
      IF (ctrl(ctrl_en_c) = '0') THEN -- disabled
        tx_engine.state <= S_TX_IDLE;
      ELSE
        CASE tx_engine.state IS

          WHEN S_TX_IDLE => -- wait for new data to send
            -- ------------------------------------------------------------
            IF (tx_buffer.avail = '1') THEN -- new data available
              IF (ctrl(ctrl_sim_en_c) = '0') THEN -- normal mode
                tx_engine.state <= S_TX_GET;
              ELSE -- simulation mode
                tx_engine.state <= S_TX_SIM;
              END IF;
              tx_buffer.re <= '1';
            END IF;

          WHEN S_TX_GET => -- get new data from buffer and prepare transmission
            -- ------------------------------------------------------------
            tx_engine.baud_cnt <= ctrl(ctrl_baud11_c DOWNTO ctrl_baud00_c);
            tx_engine.bitcnt <= num_bits;
            IF (ctrl(ctrl_pmode1_c) = '1') THEN -- add parity flag
              -- stop bit & parity bit & data (8-bit) & start bit
              tx_engine.sreg <= '1' & (xor_reduce_f(tx_buffer.rdata(7 DOWNTO 0)) XOR ctrl(ctrl_pmode0_c)) & tx_buffer.rdata(7 DOWNTO 0) & '0';
            ELSE
              -- (dummy fill-bit &) stop bit & data (8-bit) & start bit
              tx_engine.sreg <= '1' & '1' & tx_buffer.rdata(7 DOWNTO 0) & '0';
            END IF;
            tx_engine.state <= S_TX_CHECK;

          WHEN S_TX_CHECK => -- check if allowed to send
            -- ------------------------------------------------------------
            IF (tx_engine.cts = '1') THEN -- clear to send
              tx_engine.state <= S_TX_TRANSMIT;
            END IF;

          WHEN S_TX_TRANSMIT => -- transmit data
            -- ------------------------------------------------------------
            IF (uart_clk = '1') THEN
              IF (or_reduce_f(tx_engine.baud_cnt) = '0') THEN -- bit done?
                tx_engine.baud_cnt <= ctrl(ctrl_baud11_c DOWNTO ctrl_baud00_c);
                tx_engine.bitcnt <= STD_LOGIC_VECTOR(unsigned(tx_engine.bitcnt) - 1);
                tx_engine.sreg <= '1' & tx_engine.sreg(tx_engine.sreg'left DOWNTO 1);
              ELSE
                tx_engine.baud_cnt <= STD_LOGIC_VECTOR(unsigned(tx_engine.baud_cnt) - 1);
              END IF;
            END IF;
            uart_txd_o <= tx_engine.sreg(0);
            IF (or_reduce_f(tx_engine.bitcnt) = '0') THEN -- all bits send?
              tx_engine.done <= '1'; -- sending done
              tx_engine.state <= S_TX_IDLE;
            END IF;

          WHEN S_TX_SIM => -- simulation mode output
            -- ------------------------------------------------------------
            tx_engine.state <= S_TX_IDLE;

          WHEN OTHERS => -- undefined
            -- ------------------------------------------------------------
            tx_engine.state <= S_TX_IDLE;

        END CASE;
      END IF;
    END IF;
  END PROCESS uart_tx_engine;

  -- transmitter busy --
  tx_engine.busy <= '0' WHEN (tx_engine.state = S_TX_IDLE) ELSE
  '1';
  -- UART Receiver Engine -------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  uart_rx_engine : PROCESS (clk_i)
  BEGIN
    IF rising_edge(clk_i) THEN
      -- input synchronizer --
      rx_engine.sync <= uart_rxd_i & rx_engine.sync(rx_engine.sync'left DOWNTO 1);

      -- default --
      rx_engine.done <= '0';

      -- FSM --
      IF (ctrl(ctrl_en_c) = '0') THEN -- disabled
        rx_engine.overr <= '0';
        rx_engine.state <= S_RX_IDLE;
      ELSE
        CASE rx_engine.state IS

          WHEN S_RX_IDLE => -- idle; prepare receive
            -- ------------------------------------------------------------
            rx_engine.baud_cnt <= '0' & ctrl(ctrl_baud11_c DOWNTO ctrl_baud01_c); -- half baud delay at the beginning to sample in the middle of each bit
            rx_engine.bitcnt <= num_bits;
            IF (rx_engine.sync(3 DOWNTO 0) = "0011") THEN -- start bit? (falling edge)
              rx_engine.state <= S_RX_RECEIVE;
            END IF;

          WHEN S_RX_RECEIVE => -- receive data
            -- ------------------------------------------------------------
            IF (uart_clk = '1') THEN
              IF (or_reduce_f(rx_engine.baud_cnt) = '0') THEN -- bit done
                rx_engine.baud_cnt <= ctrl(ctrl_baud11_c DOWNTO ctrl_baud00_c);
                rx_engine.bitcnt <= STD_LOGIC_VECTOR(unsigned(rx_engine.bitcnt) - 1);
                rx_engine.sreg <= rx_engine.sync(2) & rx_engine.sreg(rx_engine.sreg'left DOWNTO 1);
              ELSE
                rx_engine.baud_cnt <= STD_LOGIC_VECTOR(unsigned(rx_engine.baud_cnt) - 1);
              END IF;
            END IF;
            IF (or_reduce_f(rx_engine.bitcnt) = '0') THEN -- all bits received?
              rx_engine.done <= '1'; -- receiving done
              rx_engine.state <= S_RX_IDLE;
            END IF;

          WHEN OTHERS => -- undefined
            -- ------------------------------------------------------------
            rx_engine.state <= S_RX_IDLE;

        END CASE;

        -- overrun flag --
        IF (rden = '1') AND (addr = uart_id_rtx_addr_c) THEN -- clear when reading data register
          rx_engine.overr <= '0';
        ELSIF (rx_buffer.we = '1') AND (rx_buffer.free = '0') THEN -- write to full FIFO
          rx_engine.overr <= '1';
        END IF;
      END IF;
    END IF;
  END PROCESS uart_rx_engine;

  -- RX engine ready for a new char? --
  rx_engine.rtr <= '1' WHEN (rx_engine.state = S_RX_IDLE) AND (ctrl(ctrl_en_c) = '1') ELSE
  '0';
  -- RX FIFO --------------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  rx_engine_fifo_inst : neorv32_fifo
  GENERIC MAP(
    FIFO_DEPTH => UART_RX_FIFO, -- number of fifo entries; has to be a power of two; min 1
    FIFO_WIDTH => 10, -- size of data elements in fifo
    FIFO_RSYNC => false, -- async read
    FIFO_SAFE => true -- safe access
  )
  PORT MAP(
    -- control --
    clk_i => clk_i, -- clock, rising edge
    rstn_i => '1', -- async reset, low-active
    clear_i => rx_buffer.clear, -- sync reset, high-active
    level_o => OPEN,
    half_o => rx_buffer.half, -- FIFO at least half-full
    -- write port --
    wdata_i => rx_buffer.wdata, -- write data
    we_i => rx_buffer.we, -- write enable
    free_o => rx_buffer.free, -- at least one entry is free when set
    -- read port --
    re_i => rx_buffer.re, -- read enable
    rdata_o => rx_buffer.rdata, -- read data
    avail_o => rx_buffer.avail -- data available when set
  );

  -- control --
  rx_buffer.clear <= NOT ctrl(ctrl_en_c);

  -- read/write access --
  rx_buffer.wdata(7 DOWNTO 0) <= rx_engine.sreg(7 DOWNTO 0) WHEN (ctrl(ctrl_pmode1_c) = '1') ELSE
  rx_engine.sreg(8 DOWNTO 1); -- RX data
  rx_buffer.wdata(8) <= ctrl(ctrl_pmode1_c) AND (xor_reduce_f(rx_engine.sreg(8 DOWNTO 0)) XOR ctrl(ctrl_pmode0_c)); -- parity error flag
  rx_buffer.wdata(9) <= NOT rx_engine.sreg(9); -- frame error flag: check stop bit (error if not set)
  rx_buffer.we <= '1' WHEN (rx_engine.bitcnt = "0000") AND (rx_engine.state = S_RX_RECEIVE) ELSE
  '0'; -- RX complete
  rx_buffer.re <= '1' WHEN (rden = '1') AND (addr = uart_id_rtx_addr_c) ELSE
  '0';
  -- Hardware Flow Control ------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  tx_engine.cts <= (NOT uart_cts_ff(1)) WHEN (ctrl(ctrl_cts_en_c) = '1') ELSE
  '1'; -- input is low-active, internal signal is high-active
  uart_rts <= (NOT rx_engine.rtr) WHEN (ctrl(ctrl_rts_en_c) = '1') ELSE
    '0'; -- output is low-active

  -- flow-control input/output synchronizer --
  flow_control_buffer : PROCESS (clk_i)
  BEGIN
    IF rising_edge(clk_i) THEN -- should be mapped to IOBs
      uart_cts_ff <= uart_cts_ff(0) & uart_cts_i;
      uart_rts_o <= uart_rts;
    END IF;
  END PROCESS flow_control_buffer;
  -- Interrupt Generator --------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  irq_type : PROCESS (ctrl, tx_buffer, rx_buffer, tx_engine.done)
  BEGIN
    -- TX interrupt --
    IF (UART_TX_FIFO = 1) OR (ctrl(ctrl_tx_irq_c) = '0') THEN
      tx_irq.set <= tx_buffer.free AND tx_engine.done; -- fire IRQ if FIFO is not full
    ELSE
      tx_irq.set <= (NOT tx_buffer.half) AND tx_engine.done; -- fire IRQ if FIFO is less than half-full
    END IF;
    -- RX interrupt --
    IF (UART_RX_FIFO = 1) OR (ctrl(ctrl_rx_irq_c) = '0') THEN
      rx_irq.set <= rx_buffer.avail; -- fire IRQ if FIFO is not empty
    ELSE
      rx_irq.set <= rx_buffer.half; -- fire IRQ if FIFO is at least half-full
    END IF;
  END PROCESS irq_type;

  -- interrupt edge detector --
  irq_detect : PROCESS (clk_i)
  BEGIN
    IF rising_edge(clk_i) THEN
      IF (ctrl(ctrl_en_c) = '0') THEN
        tx_irq.buf <= "00";
        rx_irq.buf <= "00";
      ELSE
        tx_irq.buf <= tx_irq.buf(0) & tx_irq.set;
        rx_irq.buf <= rx_irq.buf(0) & rx_irq.set;
      END IF;
    END IF;
  END PROCESS irq_detect;

  -- IRQ requests to CPU --
  irq_txd_o <= '1' WHEN (tx_irq.buf = "01") ELSE
    '0';
  irq_rxd_o <= '1' WHEN (rx_irq.buf = "01") ELSE
    '0';
  -- SIMULATION Transmitter -----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  -- pragma translate_off
  -- synthesis translate_off
  -- RTL_SYNTHESIS OFF
  sim_output : PROCESS (clk_i) -- for SIMULATION ONLY!
    FILE file_uart_text_out : text OPEN write_mode IS sim_uart_text_file_c;
    FILE file_uart_data_out : text OPEN write_mode IS sim_uart_data_file_c;
    VARIABLE char_v : INTEGER;
    VARIABLE line_screen_v : line; -- we need several line variables here since "writeline" seems to flush the source variable
    VARIABLE line_text_v : line;
    VARIABLE line_data_v : line;
  BEGIN
    IF rising_edge(clk_i) THEN
      IF (tx_engine.state = S_TX_SIM) THEN -- UART simulation mode

        -- print lowest byte as ASCII char --
        char_v := to_integer(unsigned(tx_buffer.rdata(7 DOWNTO 0)));
        IF (char_v >= 128) THEN -- out of range?
          char_v := 0;
        END IF;

        IF (char_v /= 10) AND (char_v /= 13) THEN -- skip line breaks - they are issued via "writeline"
          IF (sim_screen_output_en_c = true) THEN
            write(line_screen_v, CHARACTER'val(char_v));
          END IF;
          IF (sim_text_output_en_c = true) THEN
            write(line_text_v, CHARACTER'val(char_v));
          END IF;
        END IF;

        IF (char_v = 10) THEN -- line break: write to screen and text file
          IF (sim_screen_output_en_c = true) THEN
            writeline(output, line_screen_v);
          END IF;
          IF (sim_text_output_en_c = true) THEN
            writeline(file_uart_text_out, line_text_v);
          END IF;
        END IF;

        -- dump raw data as 8 hex chars to file --
        IF (sim_data_output_en_c = true) THEN
          FOR x IN 7 DOWNTO 0 LOOP
            write(line_data_v, to_hexchar_f(tx_buffer.rdata(3 + x * 4 DOWNTO 0 + x * 4))); -- write in hex form
          END LOOP; -- x
          writeline(file_uart_data_out, line_data_v);
        END IF;

      END IF;
    END IF;
  END PROCESS sim_output;
  -- RTL_SYNTHESIS ON
  -- synthesis translate_on
  -- pragma translate_on

END neorv32_uart_rtl;
