import os
from vunit import VUnit

vu = VUnit.from_argv()
vu.add_com()

# UVVM Utility Library
uvvm_util_lib = vu.add_library('uvvm_util')
uvvm_util_lib.add_source_files('uvvm/uvvm_util/src/*.vhd')

# UVVM Framework library
uvvm_vvc_framework_lib = vu.add_library('uvvm_vvc_framework')
uvvm_vvc_framework_lib.add_source_files('uvvm/uvvm_vvc_framework/src/*.vhd')

# UVVM scoreboard is required by te I2C library
bitvis_vip_scoreboard_lib = vu.add_library('bitvis_vip_scoreboard')
bitvis_vip_scoreboard_lib.add_source_files('uvvm/bitvis_vip_scoreboard/src/*.vhd')

# UVVM I2C BFM library
bitvis_vip_i2c_lib = vu.add_library('bitvis_vip_i2c')
bitvis_vip_i2c_lib.add_source_files('uvvm/uvvm_vvc_framework/src_target_dependent/*.vhd')
bitvis_vip_i2c_lib.add_source_files('uvvm/bitvis_vip_i2c/src/*.vhd')

# OSVVM Library
osvvm_lib  = vu.add_library('osvvm')
osvvm_lib.add_source_files('osvvm/*.vhd')

# I2C [DUT] controller Library
i2c_controller_lib = vu.add_library('i2c_controller_lib')
i2c_controller_lib.add_source_files('i2c/design/*.vhd')
i2c_controller_lib.add_source_files('i2c/testbench/*.vhd')

# Custom VVC component
hakonix_vip_i2c_user_lib = vu.add_library('hakonix_vip_i2c_user')
hakonix_vip_i2c_user_lib.add_source_files('uvvm/uvvm_vvc_framework/src_target_dependent/*.vhd')
hakonix_vip_i2c_user_lib.add_source_files('hakonix_vip_i2c_user/*.vhd')

# Load testbenches
for tb in i2c_controller_lib.get_test_benches():

    # Load any wave.do files found in the testbench folders when running in GUI mode
    tb_folder = os.path.dirname(tb._test_bench.design_unit.file_name)
    wave_file = os.path.join(tb_folder, 'wave.do')
    if os.path.isfile(wave_file):
        tb.set_sim_option("modelsim.init_file.gui", wave_file)

    # Don't optimize away unused signals when running in GUI mode
    tb.set_sim_option("modelsim.vsim_flags.gui", ["-voptargs=+acc"])

vu.main()