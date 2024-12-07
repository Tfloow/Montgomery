import numpy as np 
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd


color1 = "teal"
color2 = "brown"

### ADDER PLOT ###
size = [514,343,257,64]
Cycles = [3,4,5,18]
WNS = [0.376, 0.784, 0.358, 1.937]
LUTS = [2718, 2470, 2269, 2066]
REG = [3106, 3112, 3113, 3168]


fig, axs = plt.subplots(1,2,figsize=(10, 4))

ax1 = axs[0]
ax2 = axs[1]

ax1.set_title("Speed of the Adder")
ax1.plot(size,Cycles,"-o", label="# of Cycles", color=color1)

ax1_twin = ax1.twinx()
ax1_twin.plot(size,WNS,"--v", label="Worst Negative Slack", color=color1)

ax1.set_xlabel("Width of the Adder")
ax1.set_ylabel("Cycles")
ax1_twin.set_ylabel("Worst Negative Slack [ns]")
ax1.set_xlim(0,550)
ax1.set_ylim(0,20)
ax1_twin.set_ylim(0,2.5)
ax1.grid()

ax2.set_title("Utilization of the Adder")
ax2.plot(size, LUTS, "-^", label="# of Sliced LUTS", color=color2)
ax2.plot(size, REG,  "-s", label="# of Sliced Registers", color=color2)

ax2.set_xlabel("Width of the Adder")
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
ite = [5, 4,3,2,1]
Width_adder = [514, 514, 257, 257, 64]
Number_adder = [1, 1, 1, 3, 3]
Cycle_adder = [3, 3, 5, 4, 18]
Cycle = [3097, 3097, 6183, 13846, 28230]
WNS = [0.019, 0.346, 0.518, 0.381, 1.255]
LUTS = [8289, 9977, 11889, 14026, 12651]
REG = [7251, 7234, 10333, 21259, 25101]

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
ax1.set_xlim(0,6)
ax1_twin.set_ylim(0,2.5)
ax1.grid()

ax2.set_title("Utilization of the Montgomery Multiplier")
ax2.plot(ite, LUTS, "-^", label="# of Sliced LUTS", color=color2)
ax2.plot(ite, REG,  "-s", label="# of Sliced Registers", color=color2)
ax2.set_ylim(0,30000)

ax2_twin = ax2.twinx()
ax2_twin.plot(ite,Number_adder,"--v", label="# of Adder", color=color2)

ax2.set_xlabel("Iteration of the Design")
ax2.set_ylabel("Amount")
ax2_twin.set_ylabel("Amount of Adder")
ax2.set_xlim(0,6)
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

### RSA ###
# REDO IMPLEMENTATION TO FIND THE RIGHT DATA
ite = [1,2,3,4]
Cycle_montgomery = [3097, 3097,3097,3097]
Cycle = [106469, 107106, 107106,56754] # for 16 bit exponents
WNS = [-.333,.211,.049,0.102]
LUTS = [13886, 13877,12086, 20481]
REG = [13865, 13891,13891,21123]

print(f"Speed Improvements : {Cycle[-2]/Cycle[-1]}")
print(f"LUTS Improvements : {LUTS[-1]/LUTS[-2]}")
print(f"REG Improvements : {REG[-1]/REG[-2]}")

fig, axs = plt.subplots(1,2,figsize=(10, 4))

ax1 = axs[0]
ax2 = axs[1]

ax1.set_title("Speed of the Montgomery Multiplier")
ax1.plot(ite,Cycle_montgomery,"-o", label="# of Cycles Adder", color=color1)
ax1.plot(ite,Cycle,"-s", label="# of Cycles Montgomery", color=color1)
ax1.set_yscale("log")

ax1_twin = ax1.twinx()
ax1_twin.plot(ite,WNS,"--v", label="Worst Negative Slack", color=color1)

ax1.set_xlabel("Iteration of the Design")
ax1.set_ylabel("Cycles")
ax1_twin.set_ylabel("Worst Negative Slack [ns]")
ax1.set_xlim(0,6)
ax1.set_ylim(1,200000)
ax1_twin.set_ylim(-1,1)
ax1_twin.hlines(y=0,xmin=0,xmax=6, linestyles="--", alpha=0.5, color="grey")
ax1.grid()

ax2.set_title("Utilization of the Montgomery Multiplier")
ax2.plot(ite, LUTS, "-^", label="# of Sliced LUTS", color=color2, alpha=0.7)
ax2.plot(ite, REG,  "-s", label="# of Sliced Registers", color=color2, alpha=0.7)
ax2.set_ylim(0,25000)

ax2.set_xlabel("Iteration of the Design")
ax2.set_ylabel("Amount")
ax2.set_xlim(0,6)
ax2.grid()

handles1, labels1 = ax1.get_legend_handles_labels()
handles2, labels2 = ax1_twin.get_legend_handles_labels()
ax1.legend(handles1 + handles2, labels1 + labels2)

ax2.legend()
fig.tight_layout()

plt.savefig("rsa_report_perf.pdf")

### C,ARM,co-design
Montgomery_CPU_Cycle = [258559, 45607, 3097*6.5]
RSA_CPU_cycle = [258559*34,45607*34,381100] # simulation for 16 bits exponents
tag = ["C code", "ARM Assembly", "Co-Design"]
x = [i for i in range(0,258559,100)]
y = [i*34 for i in x]

fig, ax = plt.subplots(figsize=(8, 5))

ax.set_title("C vs ARM vs Co-Design Speed comparison\nfor encrypting a message with a 16 bits exponent")
ax.plot(x,y,"--", alpha=0.4,color="grey")
ax.scatter(Montgomery_CPU_Cycle,RSA_CPU_cycle, color=color1)
ax.set_xlabel("Amount of CPU cycles for one Montgomery Multiplication")
ax.set_ylabel("Amount of CPU cycles for encrypting using RSA")

for i, txt in enumerate(tag):
    ax.annotate(txt, (Montgomery_CPU_Cycle[i]-10000, RSA_CPU_cycle[i]+140000))

ax.grid()

ax.set_xlim(0)
fig.tight_layout()


plt.savefig("C_ARM_CO_comparison.pdf")

# speed with test vectors

seed = [5,4,3,2,1]
encryption = [718944, 717147, 718684, 717237, 717067]
decryption = [43150699, 42951548, 43212244, 43205017, 43116422]

# Set the Seaborn style
# sns.set_theme()
sns.set_style(style="whitegrid")

# Create subplots
data = pd.DataFrame({
    "Cycles": encryption + decryption,
    "Operation": ["Encryption"] * len(encryption) + ["Decryption"] * len(decryption)
})

fig, axs = plt.subplots(1, 2, figsize=(10, 4))

# Plot the histograms
sns.histplot(data[data["Operation"] == "Encryption"], x="Cycles", ax=axs[0], kde=False, color=color1, label="# Cycles")
sns.histplot(data[data["Operation"] == "Decryption"], x="Cycles", ax=axs[1], kde=False, color=color2, label="# Cycles")

# Set titles, labels, and legends
axs[0].set_title("Speed for encrypting using testvectors 2024.X")
axs[1].set_title("Speed for decrypting using testvectors 2024.X")

axs[0].set_xlabel("Amount of cycles")
axs[1].set_xlabel("Amount of cycles")

axs[0].set_ylabel("Occurrences")
axs[1].set_ylabel("Occurrences")

axs[0].legend()
axs[1].legend()

# Adjust layout and save the figure
#plt.tight_layout()
plt.savefig("encryption_decryption_perf.pdf")

# Loading and Sending

loading = [469 ,565 ,778 ,567 ,561 ,553 ,553 ,547 ,547 ,556 ,556 ,553 ,553 ,556 ,556 ,553 ,553 ,556 ,556 ,553 ,553 ,556 ,556 ,553 ,547 ,547 ,547 ,556 ,556 ,553 ,547 ,547 ,547 ,556 ,556 ,553 ,547 ,547 ,547 ,556]
sending = [166,157,172,172,157,157,163,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,19 ,142]


# Set the Seaborn style
# sns.set_theme()
sns.set_style(style="whitegrid")

# Create subplots
data = pd.DataFrame({
    "Cycles": loading + sending,
    "Operation": ["Loading DMA"] * len(loading) + ["Sending DMA"] * len(sending)
})

print(data[data["Operation"] == "Sending DMA"].describe())
print(data[data["Operation"] == "Loading DMA"].describe())

fig, axs = plt.subplots(figsize=(6, 4))

# Plot the histograms
axs.set_xlim(0,800)
sns.histplot(data[data["Operation"] == "Loading DMA"], x="Cycles", kde=False, color=color1, label="From Software to Hardware", binwidth=50, stat="percent")
sns.histplot(data[data["Operation"] == "Sending DMA"], x="Cycles", kde=False, color=color2, label="From Hardware to Software", binwidth=50, stat="percent")

# Set titles, labels, and legends
axs.set_title("Speed for Transmiting 1024 bits through DMA")

axs.set_xlabel("Amount of CPU Clock Cycles")

axs.set_ylabel("Percentage [%]")

axs.legend(loc="upper left")

# Adjust layout and save the figure
#plt.tight_layout()
plt.savefig("loading_sending_perf.pdf")


# Create subplots
data = pd.read_csv("RSA-CRT.csv")

fig, axs = plt.subplots(figsize=(6, 4))

# Plot the histograms
axs.set_xlim(4,6)
sns.histplot(data["RSA"], kde=False, color=color1, label="RSA",bins=5, stat="percent")
sns.histplot(data["RSA-CRT"], kde=False, color=color2, label="RSA-CRT",bins=5, stat="percent")

# Set titles, labels, and legends
axs.set_title("Comparison of Python implementation of RSA \nfor a 1022 bits decryption key")

axs.set_xlabel("Time [s]")

axs.set_ylabel("Percentage [%]")

axs.legend(loc="upper left")

# Adjust layout and save the figure
#plt.tight_layout()
plt.savefig("RSA_CRT_Python_perf.pdf")