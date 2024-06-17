library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- VUnit
library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;
-- UVVM Framework library
library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;
-- UVVM Utilities
library uvvm_util;
context uvvm_util.uvvm_util_context;
-- UVVM I2C
library bitvis_vip_i2c;
context bitvis_vip_i2c.vvc_context;
-- UVVM Custom - hakonix library
library hakonix_vip_i2c_user;
context hakonix_vip_i2c_user.vvc_context;
-- OSVVM 
library osvvm;
use osvvm.CoveragePkg.all;
use osvvm.AlertLogPkg.all;
use osvvm.RandomPkg.all;
-- I2C testbench package
use work.i2c_controller_tb_pkg.all;

entity i2c_controller_tb is
  generic(runner_cfg : string); -- VUnit 
end i2c_controller_tb;

architecture sim of i2c_controller_tb is

begin
  -- Test Harness instantiation
  TEST_HARNESS : entity work.i2c_controller_th(sim);

  SEQUENCER_PROC : process
    -- OSVVM 
    variable coverage           : CovPType;
    variable byte_i             : integer;
    variable byte               : std_logic_vector(7 downto 0);
    variable byte_count         : integer := 0;
    variable total_byte_count   : integer := 0;
    variable byte_arr           : t_byte_array(0 to 99);
    variable send_not_receive_i : integer;
    variable send_not_receive   : boolean;
    variable rand               : RandomPType;
    variable used_osvvm         : boolean := false;
    variable iteration_count    : integer := 0;

  begin
    --------------------
    -- VUNIT setup
    --------------------
    test_runner_setup(runner, runner_cfg);
    --------------------
    -- OSVVM setup
    --------------------
    SetAlertStopCount(ERROR,1);
    rand.InitSeed(rand'instance_name);
    --------------------
    -- UVVM setup
    --------------------
    enable_log_msg(ALL_MESSAGES);
    await_uvvm_initialization(VOID);
    -- UVVM I2C VVC configuration 
    shared_i2c_vvc_config(1).bfm_config.master_sda_to_scl               := i2c_period;
    shared_i2c_vvc_config(1).bfm_config.master_scl_to_sda               := i2c_period;
    shared_i2c_vvc_config(1).bfm_config.max_wait_scl_change             := i2c_period;
    shared_i2c_vvc_config(1).bfm_config.max_wait_sda_change             := i2c_period;
    shared_i2c_vvc_config(1).bfm_config.i2c_bit_time                    := i2c_period;
    shared_i2c_vvc_config(1).bfm_config.slave_mode_address(6 downto 0)  := unsigned(target_addr);
    -- Hakonix I2C VVC configuration
    shared_i2c_user_vvc_config(1).bfm_config.bit_period                 := i2c_period;
    shared_i2c_user_vvc_config(1).bfm_config.target_addr                := target_addr;

    log(ID_SEQUENCER, "Waiting for reset release");
    wait for 250 us;

      if run("send_1_byte") then
        
        log(ID_SEQUENCER, "Send 1 byte - i2c_slave_check + i2c_user_transmit");
        i2c_slave_check(I2C_VVCT, 1, x"CD", "Target expecting to receive 1 byte");
        i2c_user_transmit(I2C_USER_VVCT, 1, x"CD", "Controller sending 1 byte");
      
      elsif run("send_4_bytes") then

        log(ID_SEQUENCER, "Send 4 bytes - i2c_slave_check+i2c_user_transmit (overloaded) t_byte_array ");
        i2c_slave_check(I2C_VVCT, 1, t_byte_array'(x"A5", x"5A", x"A5", x"5A"), "Target expecting to receive 4 bytes");
        i2c_user_transmit(I2C_USER_VVCT, 1, t_byte_array'(x"A5", x"5A", x"A5", x"5A"), "Controller sending 4 bytes");

      elsif run("receive_1_byte") then

        log(ID_SEQUENCER, "Receive 1 byte - i2c_user_receive+i2c_slave_transmit ");
        i2c_user_receive(I2C_USER_VVCT, 1, x"5A", "Controller expecting to receive 1 byte ");
        i2c_slave_transmit(I2C_VVCT, 1, x"5A", "Target sending 1 byte");

      elsif run("receive_4_bytes") then

        log(ID_SEQUENCER, "Receive 4 bytes - i2c_user_receive+i2c_slave_transmit (overloaded) t_byte_array");
        i2c_user_receive(I2C_USER_VVCT, 1, t_byte_array'(x"A5", x"5A", x"A5", x"5A"), "Controller expecting to receive 4 bytes ");
        i2c_slave_transmit(I2C_VVCT, 1, t_byte_array'(x"A5", x"5A", x"A5", x"5A"), "Target sending 4 bytes");

      --elsif run("send_and_receive_4_bytes") then
      --  log(ID_SEQUENCER, "Send and receive 4 bites ");
      --  i2c_slave_check(I2C_VVCT, 1, t_byte_array'(x"12", x"34", x"56", x"78"), "Target expecting to receive 4 bytes");
      --  i2c_user_transmit(I2C_USER_VVCT, 1, t_byte_array'(x"12", x"34", x"56", x"78"), "Controller sending 4 bytes");
      --  i2c_user_receive(I2C_USER_VVCT, 1, t_byte_array'(x"9A", x"BC", x"DE", x"FF"), "Controller expecting to receive 4 bytes ");
      --  i2c_slave_transmit(I2C_VVCT, 1, t_byte_array'(x"9A", x"BC", x"DE", x"FF"), "Target sending 4 bytes");
      -- OSVVM randomized functional coverage 
      elsif run("constrained_random") then
        -- OSVVM status
        used_osvvm := true;
        --coverage.AddBins(
        -- AddCross adds cross coverage 
        coverage.AddCross(
          -- Byte values NumBin limits the size of the bin
          GenBin(
            Min     => 0,
            Max     => 255,
            NumBin  => 10
          ),
          -- Number of bytes to send
          Bin2 => GenBin(
            Min => 0,
            Max => 3
          ),
          -- Send and reseive operations
          Bin3 => GenBin(
            Min => 0,
            Max => 1
          )
        );
          -- IsCovered 
          while not coverage.IsCovered loop
            -- GetRandPoint returns a random value that hasn't been used yet
            (byte_i, byte_count, send_not_receive_i) := coverage.GetRandPoint;
            -- Intelligent cover for the bins deined above
            coverage.ICover( (byte_i, byte_count, send_not_receive_i) );
            
            byte := std_logic_vector(to_unsigned(byte_i, byte'length));
            -- Boolean value
            send_not_receive := send_not_receive_i = 1;

            byte_arr(0) := byte;
            
            --Fill the remaining bytes with random values
            for i in 1 to byte_count-1 loop
              byte_arr(i) := rand.RandSlv(byte'length);
            end loop;
            -- Iteration control variables
            iteration_count   := iteration_count + 1;
            total_byte_count  := total_byte_count + byte_count;
            -- Every 100 uterations, wait until all components are done
            if iteration_count mod 100 = 0 then
              flush_command_queue(VVC_BROADCAST);
            end if;

            if send_not_receive then
              info("Sending " & to_string(byte_count) & " byte(s) from controller to target");
              i2c_slave_check(I2C_VVCT, 1, byte_arr(0 to byte_count - 1), 
                "Target expecting to receive " & to_string(byte_count) & " byte(s)");
              i2c_user_transmit(I2C_USER_VVCT, 1, byte_arr(0 to byte_count - 1), 
                "Controller sending " & to_string(byte_count) & " byte(s)");

            else
              info("Sending " & to_string(byte_count) & " byte(s) from target to controller");
              i2c_user_receive(I2C_USER_VVCT, 1, byte_arr(0 to byte_count - 1), 
                "Controller expecting to receive " & to_string(byte_count) & " byte(s)");
              i2c_slave_transmit(I2C_VVCT, 1, byte_arr(0 to byte_count - 1), 
                "Target sending " & to_string(byte_count) & " byte(s)");

            end if;
          end loop;   
      end if;

    wait for 1 ms;

    --------------------
    -- UVVM cleanup
    --------------------
    await_completion(I2C_VVCT, 1, 100 ms);
    await_completion(I2C_USER_VVCT, 1, 100 ms);
    report_alert_counters(FINAL);
    --------------------
    -- OSVVM cleanup
    --------------------
    if used_osvvm then
      info("OSVVM - All coverage points met");
      info("Iterations:               " & to_string(iteration_count));
      info("Send and received bytes:  " & to_string(total_byte_count));
      info("Errors and warnings       " & to_string(GetAlertCount));
    end if;
    --------------------
    -- VUNIT cleanup
    --------------------
    test_runner_cleanup(runner);

  end process;

end architecture;