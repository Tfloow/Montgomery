import numpy as np 
import matplotlib.pyplot as plt

### ADDER PLOT ###
size = [514,343,257,64]
Cycles = [3,4,5,18]
WNS = [0.133, 0.379, 0.474, 2.302]
LUTS = [3231, 2634, 2530, 2139]
REG = [3120, 3116, 3118, 3185]

color1 = "teal"
color2 = "brown"

fig, axs = plt.subplots(1,2,figsize=(10, 4))

ax1 = axs[0]
ax2 = axs[1]

ax1.set_title("Speed of the Adder")
ax1.plot(size,Cycles,"-o", label="# of Cycles", color=color1)

ax1_twin = ax1.twinx()
ax1_twin.plot(size,WNS,"--v", label="Worst Negative Slack", color=color1)

ax1.set_xlabel("Width of Adder")
ax1.set_ylabel("Cycles")
ax1_twin.set_ylabel("Worst Negative Slack [ns]")
ax1.set_xlim(0,550)
ax1.set_ylim(0,20)
ax1_twin.set_ylim(0,2.5)
ax1.grid()

ax2.set_title("Utilization of the Adder")
ax2.plot(size, LUTS, "-^", label="# of Sliced LUTS", color=color2)
ax2.plot(size, REG,  "-s", label="# of Sliced Registers", color=color2)

ax2.set_xlabel("Width of Adder")
ax2.set_ylabel("Amount")
ax2.set_xlim(0,550)
ax2.set_ylim(0,3500)
ax2.grid()

handles1, labels1 = ax1.get_legend_handles_labels()
handles2, labels2 = ax1_twin.get_legend_handles_labels()
ax1.legend(handles1 + handles2, labels1 + labels2, loc="upper right")

ax2.legend()
fig.tight_layout()

plt.savefig("adder_report_perf.pdf")
#plt.show()

### Montgomery ###
ite = [4,3,2,1]
Width_adder = [514, 257, 257, 64]
Number_adder = [1, 1, 3, 3]
Cycle_adder = [3, 5, 4, 18]
Cycle = [3097, 6183, 13846, 28230]
WNS = [0.346, 0.518, 0.381, 1.255]
LUTS = [9977, 11889, 14026, 12651]
REG = [7234, 10333, 21259, 25101]

fig, axs = plt.subplots(1,2,figsize=(10, 4))

ax1 = axs[0]
ax2 = axs[1]

ax1.set_title("Speed of the Montgomery Multiplier")
ax1.plot(ite,Cycle_adder,"-o", label="# of Cycles Adder", color=color1)
ax1.plot(ite,Cycle,"-s", label="# of Cycles Montgomery", color=color1)
ax1.set_yscale("log")

ax1_twin = ax1.twinx()
ax1_twin.plot(ite,WNS,"--v", label="Worst Negative Slack", color=color1)

ax1.set_xlabel("Iteration of the Design")
ax1.set_ylabel("Cycles")
ax1_twin.set_ylabel("Worst Negative Slack [ns]")
ax1.set_xlim(0,5)
ax1_twin.set_ylim(0,2.5)
ax1.grid()

ax2.set_title("Utilization of the Montgomery Multiplier")
ax2.plot(ite, LUTS, "-^", label="# of Sliced LUTS", color=color2)
ax2.plot(ite, REG,  "-s", label="# of Sliced Registers", color=color2)

ax2_twin = ax2.twinx()
ax2_twin.plot(ite,Number_adder,"--v", label="# of Adder", color=color2)

ax2.set_xlabel("Iteration of the Design")
ax2.set_ylabel("Amount")
ax2_twin.set_ylabel("Amount of Adder")
ax2.set_xlim(0,5)
ax2_twin.set_ylim(0,5)
ax2.grid()

handles1, labels1 = ax1.get_legend_handles_labels()
handles2, labels2 = ax1_twin.get_legend_handles_labels()
ax1.legend(handles1 + handles2, labels1 + labels2)

handles1, labels1 = ax2.get_legend_handles_labels()
handles2, labels2 = ax2_twin.get_legend_handles_labels()
ax2.legend(handles1 + handles2, labels1 + labels2)
fig.tight_layout()

plt.savefig("montgomery_report_perf.pdf")
#plt.show()
