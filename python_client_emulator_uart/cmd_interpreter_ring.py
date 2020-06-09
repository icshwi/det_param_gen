import ring_cmds as r
import serial as s


port = '/dev/ttyUSB1'
<<<<<<< HEAD
output_dir = '../output/address_map/'
=======
output_dir_rng = '../output/address_map/'
output_dir_mst = '../../../../dgro_master/det_param_gen/output/address_map/'
>>>>>>> b305ef73ed0b2428156c6882e1b719944bad6408
rate = 230400
flow = 0
time = 1

ser = s.Serial(port, baudrate=rate, timeout=time, rtscts=flow)
ser.flushInput()
ser.flushOutput()

# todo args
<<<<<<< HEAD
r.cmd_interpreter(ser, "ics_constants.vhd",  output_dir +"ring_regs_mst_map.txt",  output_dir +"ring_regs_slv_map.txt", "ring_bringup.txt")
=======
r.cmd_interpreter(ser, "ics_constants.vhd",  output_dir_mst +"ring_regs_mst_map.txt",  output_dir_rng +"ring_regs_slv_map.txt", "ring_bringup.txt")
>>>>>>> b305ef73ed0b2428156c6882e1b719944bad6408


