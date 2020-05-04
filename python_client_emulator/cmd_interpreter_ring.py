import ring_cmds as r
import serial as s


port = '/dev/ttyUSB1'
output_dir_rng = '../output/address_map/'
output_dir_mst = '../../../../dgro_master/det_param_gen/output/address_map/'
rate = 230400
flow = 0
time = 1

ser = s.Serial(port, baudrate=rate, timeout=time, rtscts=flow)
ser.flushInput()
ser.flushOutput()

# todo args
r.cmd_interpreter(ser, "ics_constants.vhd",  output_dir_mst +"ring_regs_mst_map.txt",  output_dir_rng +"ring_regs_slv_map.txt", "ring_bringup.txt")


