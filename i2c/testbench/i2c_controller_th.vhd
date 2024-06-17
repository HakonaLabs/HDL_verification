library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- UVVM framework library
library uvvm_vvc_framework;
-- UVVM I2C component library
library bitvis_vip_i2c;
-- Custom VVC 
library hakonix_vip_i2c_user;
-- Testbench package
use work.i2c_controller_tb_pkg.all;

entity i2c_controller_th is
end i2c_controller_th;

architecture sim of i2c_controller_th is
  
  signal clk        : std_logic                     := '1';
  signal rst        : std_logic                     := '1';
  -- I2C interface
  signal scl        : std_logic;
  signal sda        : std_logic;
  -- Command Bus interface // AXI
  signal cmd_tdata  : std_logic_vector(7 downto 0)  := (others => '0');
  signal cmd_tvalid : std_logic                     := '0';
  signal cmd_tready : std_logic;
  -- Read Bus interface // AXI
  signal rd_tdata   : std_logic_vector(7 downto 0);
  signal rd_tvalid  : std_logic;
  signal rd_tready  : std_logic                     := '0';
  -- Not Acknowledge // Pulsed on every received NACK
  signal nack       : std_logic;

begin
  -- Generate clock
  clk <= not clk after clk_period / 2;
  -- Release reset
  rst <= '0' after clk_period * 2;
  -- Pullup
  scl <= 'H';
  sda <= 'H';
  -- UVVM engine module initialization is required for every UVVM testbench
  UVVM_ENGINE : entity uvvm_vvc_framework.ti_uvvm_engine(func);

  DUT : entity work.i2c_controller(rtl)
  generic map (
    clk_hz => clk_hz,
    i2c_hz => i2c_hz
  )
  port map (
    clk         => clk,
    rst         => rst,
    scl         => scl,
    sda         => sda,
    cmd_tdata   => cmd_tdata,
    cmd_tvalid  => cmd_tvalid,
    cmd_tready  => cmd_tready,
    rd_tdata    => rd_tdata,
    rd_tvalid   => rd_tvalid,
    rd_tready   => rd_tready,
    nack        => nack
  );

  I2C_VVC : entity bitvis_vip_i2c.i2c_vvc(behave)
  generic map (
    GC_MASTER_MODE  => false
  )
  port map (
    i2c_vvc_if.scl => scl,
    i2c_vvc_if.sda => sda
  );

  I2C_USER_VVC : entity hakonix_vip_i2c_user.i2c_user_vvc(behave)
    port map (
    clk                        => clk, 
    i2c_user_vvc_if.cmd_tdata  => cmd_tdata,  -- to dut
    i2c_user_vvc_if.cmd_tvalid => cmd_tvalid, -- to dut
    i2c_user_vvc_if.cmd_tready => cmd_tready, -- from dut
    i2c_user_vvc_if.rd_tdata   => rd_tdata,   -- from dut
    i2c_user_vvc_if.rd_tvalid  => rd_tvalid,  -- from dut
    i2c_user_vvc_if.rd_tready  => rd_tready,  -- to dut
    i2c_user_vvc_if.nack       => nack        -- from dut
    );

end architecture;