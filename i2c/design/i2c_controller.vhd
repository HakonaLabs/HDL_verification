library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.round;

entity i2c_controller is
  generic (
    clk_hz            : integer   := 50_000_000;
    i2c_hz            : integer   := 100_000;
    sda_delay_ns_gc   : integer   := 400;
    scl_hp_cnt_max_gc : integer   := 31
  );
  port (
    CLK         : in std_logic;
    rst         : in std_logic;
    -- I2C interface
    SCL         : out std_logic     :='Z';
    SDA         : inout std_logic   :='Z';
    -- Command Bus // AXI
    CMD_TDATA   : in std_logic_vector(7 downto 0);
    CMD_TVALID  : in std_logic;
    CMD_TREADY  : out std_logic;
    -- Read Bus // AXI
    RD_TDATA    : out std_logic_vector(7 downto 0);
    RD_TVALID   : out std_logic;
    RD_TREADY   : in std_logic;
    -- Not Acknowledge // Pulsed on every received NACK
    NACK        : out std_logic
  );
end i2c_controller;

architecture rtl of i2c_controller is
  -- Constant list
  -- Delay 
  constant sda_delay_ns         : integer := sda_delay_ns_gc;
  constant sda_delay_cycles     : integer := integer(real(sda_delay_ns) / ((1.0 / real(clk_hz)) * 1.0e9));
  -- Clock cycles per half period of SCL rounded to nearest int
  constant cycles_per_half_scl  : integer := integer(round(real(clk_hz) / real(i2c_hz)) / 2.0);
  constant clk_cnt_max          : integer := cycles_per_half_scl -1;
  constant scl_hp_cnt_max       : integer := scl_hp_cnt_max_gc;
  -- Control Commands
  constant CMD_BUS_RST          : std_logic_vector(7 downto 0)  := x"00";  
  constant CMD_START_CONDITION  : std_logic_vector(7 downto 0)  := x"01";
  constant CMD_TX_BYTE          : std_logic_vector(7 downto 0)  := x"02";
  constant CMD_RX_BYTE_ACK      : std_logic_vector(7 downto 0)  := x"03";
  constant CMD_RX_BYTE_NACK     : std_logic_vector(7 downto 0)  := x"04";
  constant CMD_STOP_CONDITION   : std_logic_vector(7 downto 0)  := x"05";
  -- FSM State List
  type state_type is (  RST_SEQ,          -- Reset Sequence (I2C Bus reset)
                        WAIT_COMMAND,     -- Waiting for a command 
                        START_CONDITION,  -- While SCL is HIGH, set SDA LOW at the middle of SCL period
                        STOP_CONDITION,   -- Once TX has been requested, we'll wait for the data to be transmitted to be valid
                        WAIT_TX_BYTE,     --
                        TX_BYTE,          --
                        RX_BYTE,          --
                        RETURN_RX_BYTE    --
                        );
  signal state  : state_type;
  -- Internal SDA / SDCL signals
  signal scl_i        : std_logic   := '1';
  signal sda_i        : std_logic   := '1';
  -- Read ACK/NACK 
  signal rx_nack_bit  : std_logic   := '0';
  signal byte_to_send : std_logic_vector(7 downto 0);
  signal sample_ack   : std_logic;
  -- Shift Register for delaying SDA
  signal sda_delay    : std_logic_vector(sda_delay_cycles-2 downto 0)  := (others => '0');
  -- Cycles per half period
   signal clk_cnt     : integer range 0 to clk_cnt_max;
  -- SCL half period counter
  signal scl_hp_cnt   : integer range 0 to scl_hp_cnt_max;

  signal sda_sampled  : std_logic_vector(7 downto 0);


begin
  -- Tri-State driver
  SCL_OUT_PROC : process(scl_i)
  begin
    if scl_i = '0' then
      SCL <= '0';
    else
      SCL <= 'Z';
    end if;
  end process;

  SDA_OUT_PROC : process(CLK)
  begin
    if rising_edge(CLK) then
      if RST='1' then
        sda_delay <= (others => '1');
      else
        -- Shift register 
        sda_delay <= sda_i & sda_delay(sda_delay'high downto 1);
        if sda_delay(0) = '0' then
          SDA <= '0';
        else
          SDA <= 'Z';
        end if;
      end if;
    end if;
  end process;

  FSM_PROC : process(CLK)

  procedure change_state(next_state : state_type) is
  begin
    clk_cnt     <= 0;
    scl_hp_cnt  <= 0;
    state <= next_state;
  end procedure;

  impure function scl_half_period(count : integer) return boolean is
  begin
    if clk_cnt = clk_cnt_max then
      clk_cnt <= 0;
      scl_i   <= not scl_i;
      -- ACK Check
      if sample_ack='1' and scl_i='1' then
        sample_ack <= '0';
        --report "SCL_HALF_PERIOD : Checking ACK bit";
        if SDA='0' then
          NACK <= '0';
        else
          NACK <= '1';
        end if;
      end if;

      if scl_hp_cnt = scl_hp_cnt_max then
        scl_hp_cnt <= 0;
      else
        scl_hp_cnt <= scl_hp_cnt+1;
      end if;

      return scl_hp_cnt = count;
    
    else
      clk_cnt <= clk_cnt+1;
      return false;
    end if;
  end function;

  impure function read_sda return std_logic is
  begin
    if SDA='0' then
      return '0';
    else  
      return '1';
    end if;
  end function;

  begin
    if rising_edge(CLK) then
      if RST = '1' then
        CMD_TREADY  <= '0';
        RD_TVALID   <= '0';
        RD_TDATA    <= (others => '0');
        NACK        <= '0';
        scl_i       <= '1';
        sda_i       <= '1';
        rx_nack_bit <= '0';
        byte_to_send<= (others => '0');
        sample_ack  <= '0';
        sda_sampled <= (others => '0');
        clk_cnt     <= 0;
        scl_hp_cnt  <= 0;
        state <= RST_SEQ;
  
      else
        --Defaults
        NACK <= '0';
        case state is
          -- Reset Sequence // Waits N cycles for a safe release of I2C bus
          when RST_SEQ =>
            sda_i <= '1';
              if scl_half_period(15) then
                change_state(WAIT_COMMAND);
              end if;

          -- Waits for a command to be received
          when WAIT_COMMAND =>
            CMD_TREADY <= '1';
            if CMD_TVALID='1' and CMD_TREADY='1' then
              CMD_TREADY <= '0';
              case CMD_TDATA is 
                when CMD_START_CONDITION =>
                  change_state(START_CONDITION);
                
                when CMD_TX_BYTE =>
                  change_state(WAIT_TX_BYTE);
                
                when CMD_RX_BYTE_ACK =>
                  rx_nack_bit <= '0';
                  change_state(RX_BYTE);
                
                when CMD_RX_BYTE_NACK =>
                  rx_nack_bit <= '1';
                  change_state(RX_BYTE);

                when CMD_STOP_CONDITION =>
                  change_state(STOP_CONDITION);
                
                when others=> --CMD_BUS_RST
                  change_state(RST_SEQ);
              
              end case;
            end if;

          when START_CONDITION =>
            -- While SCL is HIGH, set SDA LOW at the middle of SCL period
            if scl_half_period(0) then
              sda_i <= '0';   -- START Protocol condition
              change_state(WAIT_COMMAND);
            end if;
            scl_i <= '1';
          -- While SCL is HIGH, set SDA LOW at the middle of SCL period
          when STOP_CONDITION =>
            -- STOP Protocol condition 1/2
            if scl_half_period(0) then
              sda_i <= '0';   
            end if;
            -- STOP Protocol condition 2/2
            if scl_half_period(2) then
              sda_i <= '1';   
              scl_i <= '1';
              change_state(WAIT_COMMAND);
            end if;
          -- Once TX has been requested, we'll wait for the data to be transmitted to be valid
          when WAIT_TX_BYTE=>
            CMD_TREADY <= '1';
            if CMD_TVALID='1' and CMD_TREADY='1' then
              CMD_TREADY    <= '0';
              byte_to_send  <= CMD_TDATA;
              change_state(TX_BYTE);
            end if;
          -- Transmit 
          When TX_BYTE =>
            for i in 0 to 7 loop
              if scl_half_period( i*2 ) then
                --report "TX_BYTE : TX bit " & to_string(i);
                sda_i         <= byte_to_send(7);
                byte_to_send  <= byte_to_send(6 downto 0) & '0';
              end if;              
            end loop;

            if scl_half_period(16) then
              --report "TX_BYTE : Releasing SDA";
              sda_i <= '1';
            end if;

            if scl_half_period(17) then
              sample_ack <= '1';
              change_state(WAIT_COMMAND);
            end if;

          when RX_BYTE =>
            if scl_half_period(0) then
              sda_i <= '1';
            end if;

            for i in 1 to 8 loop
              if scl_half_period( i*2 ) then
                --report "RX bit " & to_string(i);
                sda_sampled <= sda_sampled(6 downto 0) & read_sda;
              end if;              
            end loop;

            if scl_half_period(16) then
              --report "RX_BYTE : Sending ACK or NACK";
              --Send ACK or NACK
              sda_i <= rx_nack_bit;
            end if;

            if scl_half_period(17) then
              change_state(RETURN_RX_BYTE);
            end if;
          
          when RETURN_RX_BYTE =>
            RD_TDATA  <= sda_sampled;
            RD_TVALID <= '1';
            if RD_TVALID='1' and RD_TREADY='1' then
              RD_TVALID <= '0';
              change_state(WAIT_COMMAND);
            end if;
  
        end case;
  
      end if;
    end if;
  end process;

end architecture;