onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/clk
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/rst
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/scl
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/sda
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/cmd_tdata
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/cmd_tvalid
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/cmd_tready
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/rd_tdata
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/rd_tvalid
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/rd_tready
add wave -noupdate -group TEST_HARNESS /i2c_controller_tb/TEST_HARNESS/nack
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/i2c_vvc_if
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/executor_is_busy
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/queue_is_increasing
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/last_cmd_idx_executed
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/terminate_current_cmd
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/entry_num_in_vvc_activity_register
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/vvc_transaction_info
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/vvc_transaction_info_trigger
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/transaction_info
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/vvc_status
add wave -noupdate -group I2C_VVC /i2c_controller_tb/TEST_HARNESS/I2C_VVC/vvc_config
add wave -noupdate -group I2C_USER_VVC /i2c_controller_tb/TEST_HARNESS/I2C_USER_VVC/clk
add wave -noupdate -group I2C_USER_VVC /i2c_controller_tb/TEST_HARNESS/I2C_USER_VVC/i2c_user_vvc_if
add wave -noupdate -group I2C_USER_VVC /i2c_controller_tb/TEST_HARNESS/I2C_USER_VVC/executor_is_busy
add wave -noupdate -group I2C_USER_VVC /i2c_controller_tb/TEST_HARNESS/I2C_USER_VVC/queue_is_increasing
add wave -noupdate -group I2C_USER_VVC /i2c_controller_tb/TEST_HARNESS/I2C_USER_VVC/last_cmd_idx_executed
add wave -noupdate -group I2C_USER_VVC /i2c_controller_tb/TEST_HARNESS/I2C_USER_VVC/terminate_current_cmd
add wave -noupdate -group I2C_USER_VVC /i2c_controller_tb/TEST_HARNESS/I2C_USER_VVC/entry_num_in_vvc_activity_register
add wave -noupdate -group I2C_USER_VVC /i2c_controller_tb/TEST_HARNESS/I2C_USER_VVC/vvc_status
add wave -noupdate -group I2C_USER_VVC /i2c_controller_tb/TEST_HARNESS/I2C_USER_VVC/vvc_config
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/CLK
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/rst
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/SCL
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/SDA
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/CMD_TDATA
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/CMD_TVALID
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/CMD_TREADY
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/RD_TDATA
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/RD_TVALID
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/RD_TREADY
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/NACK
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/state
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/scl_i
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/sda_i
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/rx_nack_bit
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/byte_to_send
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/sample_ack
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/sda_delay
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/clk_cnt
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/scl_hp_cnt
add wave -noupdate -expand -group DUT /i2c_controller_tb/TEST_HARNESS/DUT/sda_sampled
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1261575 ns}
