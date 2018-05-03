######################################################
#                                                   
#  RMC Tutorial
#  
#  I/O Placement File
#
# Design: ALU
#
#    Power Added: 1. Ring Pair on each Side (PVDD2DGZ and PVSS2DGZ Pads)
#                 2. Core Pair on North and South sides (PVDD1DGZ and PVSS1DGZ Pads) 
#    Corner Pads Added: 
#
#    Note: When adding your IOs, ensure sides are balanced.  If not, add VSS Core
#          pads to balance the IOs.
#
######################################################



Version: 2
#
#  North
######################################################
Pin: reset  N
pin: en  N
######################################################

#
#  East
#######################################################
Pin: change_input  E
Pin: temporary_overflow  E
Pin: output_signal[0]  E
Pin: output_signal[1]  E
Pin: output_signal[2]  E
Pin: output_signal[3]  E
Pin: output_signal[4]  E
Pin: output_signal[5]  E
Pin: output_signal[6]  E
Pin: output_signal[7]  E
######################################################


#
#  South
######################################################
Pin: clk  S
######################################################


#
#  West
#######################################################
Pin: parameter_A1_mul[0]  W
Pin: parameter_A1_mul[1]  W
Pin: parameter_A1_mul[2]  W
Pin: parameter_A1_mul[3]  W
Pin: parameter_A1_mul[4]  W
Pin: parameter_A1_mul[5]  W
Pin: parameter_A1_mul[6]  W
Pin: parameter_A1_mul[7]  W

Pin: parameter_A1_div[0]  W
Pin: parameter_A1_div[1]  W
Pin: parameter_A1_div[2]  W
Pin: parameter_A1_div[3]  W
Pin: parameter_A1_div[4]  W
Pin: parameter_A1_div[5]  W
Pin: parameter_A1_div[6]  W
Pin: parameter_A1_div[7]  W

Pin: parameter_A2_mul[0]  W
Pin: parameter_A2_mul[1]  W
Pin: parameter_A2_mul[2]  W
Pin: parameter_A2_mul[3]  W
Pin: parameter_A2_mul[4]  W
Pin: parameter_A2_mul[5]  W
Pin: parameter_A2_mul[6]  W
Pin: parameter_A2_mul[7]  W

Pin: parameter_A2_div[0]  W
Pin: parameter_A2_div[1]  W
Pin: parameter_A2_div[2]  W
Pin: parameter_A2_div[3]  W
Pin: parameter_A2_div[4]  W
Pin: parameter_A2_div[5]  W
Pin: parameter_A2_div[6]  W
Pin: parameter_A2_div[7]  W

Pin: parameter_B0_mul[0]  W
Pin: parameter_B0_mul[1]  W
Pin: parameter_B0_mul[2]  W
Pin: parameter_B0_mul[3]  W
Pin: parameter_B0_mul[4]  W
Pin: parameter_B0_mul[5]  W
Pin: parameter_B0_mul[6]  W
Pin: parameter_B0_mul[7]  W

Pin: parameter_B0_div[0]  W
Pin: parameter_B0_div[1]  W
Pin: parameter_B0_div[2]  W
Pin: parameter_B0_div[3]  W
Pin: parameter_B0_div[4]  W
Pin: parameter_B0_div[5]  W
Pin: parameter_B0_div[6]  W
Pin: parameter_B0_div[7]  W

Pin: parameter_B1_mul[0]  W
Pin: parameter_B1_mul[1]  W
Pin: parameter_B1_mul[2]  W
Pin: parameter_B1_mul[3]  W
Pin: parameter_B1_mul[4]  W
Pin: parameter_B1_mul[5]  W
Pin: parameter_B1_mul[6]  W
Pin: parameter_B1_mul[7]  W

Pin: parameter_B1_div[0]  W
Pin: parameter_B1_div[1]  W
Pin: parameter_B1_div[2]  W
Pin: parameter_B1_div[3]  W
Pin: parameter_B1_div[4]  W
Pin: parameter_B1_div[5]  W
Pin: parameter_B1_div[6]  W
Pin: parameter_B1_div[7]  W

Pin: parameter_B2_mul[0]  W
Pin: parameter_B2_mul[1]  W
Pin: parameter_B2_mul[2]  W
Pin: parameter_B2_mul[3]  W
Pin: parameter_B2_mul[4]  W
Pin: parameter_B2_mul[5]  W
Pin: parameter_B2_mul[6]  W
Pin: parameter_B2_mul[7]  W

Pin: parameter_B2_div[0]  W
Pin: parameter_B2_div[1]  W
Pin: parameter_B2_div[2]  W
Pin: parameter_B2_div[3]  W
Pin: parameter_B2_div[4]  W
Pin: parameter_B2_div[5]  W
Pin: parameter_B2_div[6]  W
Pin: parameter_B2_div[7]  W

Pin: input_signal[0]  W
Pin: input_signal[1]  W
Pin: input_signal[2]  W
Pin: input_signal[3]  W
Pin: input_signal[4]  W
Pin: input_signal[5]  W
Pin: input_signal[6]  W
Pin: input_signal[7]  W
######################################################


#
# Corners
#
#Pad: BR_CORNER SE PCORNERDG
#Pad: BL_CORNER SW PCORNERDG
#Pad: TL_CORNER NW PCORNERDG
#Pad: TR_CORNER NE PCORNERDG