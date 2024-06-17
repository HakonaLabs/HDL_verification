--==========================================================================================
-- This VVC was generated with Bitvis VVC Generator
--==========================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--==========================================================================================
--==========================================================================================
package i2c_user_bfm_pkg is

  --==========================================================================================
  -- Types and constants for I2C_USER BFM
  --==========================================================================================
  constant C_SCOPE : string := "I2C_USER BFM";

  -- Interface record for BFM signals
  type t_i2c_user_if is record
    cmd_tdata  : std_logic_vector(7 downto 0); -- to dut
    cmd_tvalid : std_logic;                    -- to dut
    cmd_tready : std_logic;                    -- from dut
    rd_tdata   : std_logic_vector(7 downto 0); -- from dut
    rd_tvalid  : std_logic;                    -- from dut
    rd_tready  : std_logic;                    -- to dut
    nack       : std_logic;                    -- from dut
   end record;

  -- Configuration record to be assigned in the test harness.
  type t_i2c_user_bfm_config is
  record
    id_for_bfm               : t_msg_id; 
    id_for_bfm_wait          : t_msg_id; 
    id_for_bfm_poll          : t_msg_id;
    target_addr              : std_logic_vector(6 downto 0);
    bit_period               : time;
  end record;

  -- Define the default value for the BFM config
  constant C_I2C_USER_BFM_CONFIG_DEFAULT : t_i2c_user_bfm_config := (
    id_for_bfm               => ID_BFM,     
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL ,
    target_addr              => "0000000",
    bit_period               => -1 ns
  );

  --==========================================================================================
  -- BFM procedures
  --==========================================================================================

  -- Functions
  -- Initialize all signals going to the DUT
  function init_i2c_user_if_signals return t_i2c_user_if;
  -- Procedures
  procedure i2c_user_transmit(
    constant data_array : in t_byte_array;
    signal clk          : in std_logic;
    signal i2c_user_if  : inout t_i2c_user_if;
    constant msg        : in string             := "";
    constant scope      : in string             := C_VVC_CMD_SCOPE_DEFAULT;
    constant config     : t_i2c_user_bfm_config := C_I2C_USER_BFM_CONFIG_DEFAULT
  );
   
  procedure i2c_user_receive(
    constant data_array : in t_byte_array;
    signal clk          : in std_logic;
    signal i2c_user_if  : inout t_i2c_user_if;
    constant msg        : in string             := "";
    constant scope      : in string             := C_VVC_CMD_SCOPE_DEFAULT;
    constant config     : t_i2c_user_bfm_config := C_I2C_USER_BFM_CONFIG_DEFAULT
  );

end package i2c_user_bfm_pkg;


--==========================================================================================
--==========================================================================================

package body i2c_user_bfm_pkg is

  function init_i2c_user_if_signals return t_i2c_user_if is
    variable r : t_i2c_user_if;
  begin
    -- Initialize all elements of type T_I2C_USER_IF
    r.cmd_tdata   := (others => 'X');    
    r.cmd_tvalid  := '0';
    r.cmd_tready  := 'Z';
    r.rd_tdata    := (others => 'Z');
    r.rd_tvalid   := 'Z';
    r.rd_tready   := '0';
    r.nack        := 'Z';
    -- Return initialized values
    return r;
  end function;

  -- Send a command to the I2C controller
  procedure send_cmd(
    constant tdata       : std_logic_vector(7 downto 0);
    constant proc_name   : string;
    constant scope       : string;
    constant config      : t_i2c_user_bfm_config;
    signal   clk         : std_logic;
    signal   i2c_user_if : inout t_i2c_user_if
    ) is
  begin
    log(config.id_for_bfm, proc_name & "(): receive cmd byte: 0x" & to_hstring(tdata), scope);

    i2c_user_if.cmd_tdata   <= tdata;
    i2c_user_if.cmd_tvalid  <= '1';

    loop
      wait until rising_edge(clk);

      if i2c_user_if.cmd_tready = '1' then
        exit;
      end if;
    end loop;

    i2c_user_if.cmd_tdata   <= (others => 'X');
    i2c_user_if.cmd_tvalid  <= '0';

  end procedure;

  procedure i2c_user_transmit(
    constant data_array : in t_byte_array;
    signal clk          : in std_logic;
    signal i2c_user_if  : inout t_i2c_user_if;
    constant msg        : in string             := "";
    constant scope      : in string             := C_VVC_CMD_SCOPE_DEFAULT;
    constant config     : t_i2c_user_bfm_config := C_I2C_USER_BFM_CONFIG_DEFAULT
  ) is 
    -- Constant list 
    constant proc_name  : string := "i2c_user_transmit"; 
    -- Internal procedure. Assembles the command including all required data
    procedure send_cmd(constant tdata : std_logic_vector(7 downto 0)) is
    begin
      send_cmd(tdata, proc_name, scope, config, clk, i2c_user_if);
    end procedure;

  begin

    log(config.id_for_bfm, proc_name & to_string(data_array, HEX, AS_IS, INCL_RADIX)
      & " target_addr: " & to_hstring(config.target_addr) & " " & add_msg_delimiter(msg), scope);

    send_cmd(x"01");  -- CMD_START_CONDITION
    send_cmd(x"02");  -- CMD_TX_BYTE
    send_cmd(config.target_addr & '0'); -- Target address + write bit

    for i in 0 to data_array'length -1 loop
      send_cmd(x"02"); -- CMD_TX_BYTE
      send_cmd(data_array(i));
    end loop;

    send_cmd(x"05");    -- CMD_STOP_CONDITION
  
  end procedure;

  procedure i2c_user_receive(
    constant data_array : in t_byte_array;
    signal clk          : in std_logic;
    signal i2c_user_if  : inout t_i2c_user_if;
    constant msg        : in string             := "";
    constant scope      : in string             := C_VVC_CMD_SCOPE_DEFAULT;
    constant config     : t_i2c_user_bfm_config := C_I2C_USER_BFM_CONFIG_DEFAULT
  ) is
  -- Constant list 
    constant proc_name  : string := "i2c_user_receive";

    procedure send_cmd(constant tdata : std_logic_vector(7 downto 0)) is
    begin
      send_cmd(tdata, proc_name, scope, config, clk, i2c_user_if);
    end procedure;

  begin

    check_value(config.bit_period /= -1 ns, TB_ERROR, "I2C config.bit_period period not set");

    log(config.id_for_bfm, proc_name & to_string(data_array, HEX, AS_IS, INCL_RADIX)
      & " target_addr: " & to_hstring(config.target_addr) & " " & add_msg_delimiter(msg), scope);

    send_cmd(x"01");  -- CMD_START_CONDITION
    send_cmd(x"02");  -- CMD_TX_BYTE
    send_cmd(config.target_addr & '1'); -- Target address + read bit

    for i in 0 to data_array'length -1 loop
      -- Send NACK when reading the last byte
      if i=data_array'length - 1 then
        send_cmd(x"04"); -- CMD_RX_BYTE_ACK
      else
        send_cmd(x"03"); -- CMD_RX_BYTE_NACK
      end if;
      -- C
      i2c_user_if.rd_tready <= '1';
      await_value(i2c_user_if.rd_tvalid, '1', 0 ns, config.bit_period * 10, "Waiting for rd_tvalid", scope);
      check_value(i2c_user_if.rd_tdata, data_array(i), "Received data should match expected");

    end loop;

    send_cmd(x"05");    -- CMD_STOP_CONDITION
    
  end procedure;

end package body i2c_user_bfm_pkg;

