import ring_cmds as r
import serial as s


port = '/dev/ttyUSB0'
rate = 230400
flow = 0
time = 1

ser = s.Serial(port, baudrate=rate, timeout=time, rtscts=flow)
ser.flushInput()
ser.flushOutput()

# todo args
r.cmd_interpreter(ser, "ics_constants.vhd", "ring_regs_mst_map.txt", "ring_regs_slv_map.txt", "ring_bringup.txt")


