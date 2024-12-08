import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

# Data for the Adder Plot
size = [514, 343, 257, 64]
cycles = [3, 4, 5, 18]
wns = [0.376, 0.784, 0.358, 1.937]
luts = [2718, 2470, 2269, 2066]
reg = [3106, 3112, 3113, 3168]

# Convert to DataFrame
adder_data = pd.DataFrame({
    "Size": size,
    "Cycles": cycles,
    "WNS": wns,
    "LUTs": luts,
    "Registers": reg
})

# Set Seaborn style
sns.set_theme()

# Create subplots
fig, axs = plt.subplots(1, 2, figsize=(10, 4))

# Plot Speed of the Adder
sns.lineplot(data=adder_data, x="Size", y="Cycles", marker="o", label="# of Cycles", color="teal", ax=axs[0])
sns.lineplot(data=adder_data, x="Size", y="WNS", marker="v", label="Worst Negative Slack", color="teal", linestyle="--", ax=axs[0].twinx())

# Customize the first subplot
axs[0].set_title("Speed of the Adder")
axs[0].set_xlabel("Width of the Adder")
axs[0].set_ylabel("Cycles")
axs[0].set_xlim(0, 550)
axs[0].set_ylim(0, 20)
axs[0].grid()

# Plot Utilization of the Adder
sns.lineplot(data=adder_data, x="Size", y="LUTs", marker="^", label="# of Sliced LUTs", color="brown", ax=axs[1])
sns.lineplot(data=adder_data, x="Size", y="Registers", marker="s", label="# of Sliced Registers", color="brown", ax=axs[1])

# Customize the second subplot
axs[1].set_title("Utilization of the Adder")
axs[1].set_xlabel("Width of the Adder")
axs[1].set_ylabel("Amount")
axs[1].set_xlim(0, 550)
axs[1].set_ylim(0, 3500)
axs[1].grid()

# Adjust layout and save
plt.tight_layout()
plt.savefig("adder_report_perf.pdf")


# Data for Montgomery Multiplier
ite = [5, 4, 3, 2, 1]
width_adder = [514, 514, 257, 257, 64]
number_adder = [1, 1, 1, 3, 3]
cycle_adder = [3, 3, 5, 4, 18]
cycle = [3097, 3097, 6183, 13846, 28230]
wns = [0.019, 0.346, 0.518, 0.381, 1.255]
luts = [8289, 9977, 11889, 14026, 12651]
reg = [7251, 7234, 10333, 21259, 25101]

# Convert to DataFrame
montgomery_data = pd.DataFrame({
    "Iteration": ite,
    "Cycle_Adder": cycle_adder,
    "Cycle_Montgomery": cycle,
    "WNS": wns,
    "LUTs": luts,
    "Registers": reg,
    "Number_Adder": number_adder
})

# Create subplots
fig, axs = plt.subplots(1, 2, figsize=(10, 4))

# Plot Speed of Montgomery Multiplier
sns.lineplot(data=montgomery_data, x="Iteration", y="Cycle_Adder", marker="o", label="# of Cycles Adder", color="teal", ax=axs[0])
sns.lineplot(data=montgomery_data, x="Iteration", y="Cycle_Montgomery", marker="s", label="# of Cycles Montgomery", color="teal", ax=axs[0])
axs[0].set_yscale("log")

sns.lineplot(data=montgomery_data, x="Iteration", y="WNS", marker="v", label="Worst Negative Slack", color="teal", linestyle="--", ax=axs[0].twinx())

# Customize the first subplot
axs[0].set_title("Speed of the Montgomery Multiplier")
axs[0].set_xlabel("Iteration of the Design")
axs[0].set_ylabel("Cycles")
axs[0].set_xlim(0, 6)
axs[0].grid()

# Plot Utilization of Montgomery Multiplier
sns.lineplot(data=montgomery_data, x="Iteration", y="LUTs", marker="^", label="# of Sliced LUTs", color="brown", ax=axs[1])
sns.lineplot(data=montgomery_data, x="Iteration", y="Registers", marker="s", label="# of Sliced Registers", color="brown", ax=axs[1])
sns.lineplot(data=montgomery_data, x="Iteration", y="Number_Adder", marker="v", label="# of Adders", color="brown", linestyle="--", ax=axs[1].twinx())

# Customize the second subplot
axs[1].set_title("Utilization of the Montgomery Multiplier")
axs[1].set_xlabel("Iteration of the Design")
axs[1].set_ylabel("Amount")
axs[1].set_xlim(0, 6)
axs[1].grid()

# Adjust layout and save
plt.tight_layout()
plt.savefig("montgomery_report_perf.pdf")

# Data for RSA
ite = [1, 2, 3]
cycle_montgomery = [3097, 3097, 3097]
cycle = [106469, 106469, 107106]  # For 16-bit exponents
wns = [-0.333, 0.118, 0.211]
luts = [13886, 13886, 13877]
reg = [13865, 13865, 13891]

# Convert to DataFrame
rsa_data = pd.DataFrame({
    "Iteration": ite,
    "Cycle_Montgomery": cycle_montgomery,
    "Cycle": cycle,
    "WNS": wns,
    "LUTs": luts,
    "Registers": reg
})

# Set Seaborn style
sns.set_theme()

# Create subplots
fig, axs = plt.subplots(1, 2, figsize=(10, 4))

# Plot Speed of RSA
sns.lineplot(data=rsa_data, x="Iteration", y="Cycle_Montgomery", marker="o", label="# of Cycles Montgomery", color="teal", ax=axs[0])
sns.lineplot(data=rsa_data, x="Iteration", y="Cycle", marker="s", label="# of Cycles RSA", color="teal", ax=axs[0])
sns.lineplot(data=rsa_data, x="Iteration", y="WNS", marker="v", label="Worst Negative Slack", color="teal", linestyle="--", ax=axs[0].twinx())

# Customize the first subplot
axs[0].set_title("Speed of the RSA Multiplier")
axs[0].set_xlabel("Iteration of the Design")
axs[0].set_ylabel("Cycles")
axs[0].set_xlim(0, 6)
axs[0].grid()
axs[0].twinx().hlines(y=0, xmin=0, xmax=6, linestyles="--", alpha=0.5, color="grey")
axs[0].twinx().set_ylim(-2.5, 2.5)
axs[0].twinx().set_ylabel("Worst Negative Slack [ns]")

# Plot Utilization of RSA
sns.lineplot(data=rsa_data, x="Iteration", y="LUTs", marker="^", label="# of Sliced LUTs", color="brown", ax=axs[1])
sns.lineplot(data=rsa_data, x="Iteration", y="Registers", marker="s", label="# of Sliced Registers", color="brown", ax=axs[1])

# Customize the second subplot
axs[1].set_title("Utilization of the RSA Multiplier")
axs[1].set_xlabel("Iteration of the Design")
axs[1].set_ylabel("Amount")
axs[1].set_xlim(0, 6)
axs[1].set_ylim(0, 30000)
axs[1].grid()

# Adjust layout and save
plt.tight_layout()
plt.savefig("rsa_report_perf.pdf")

seed = [5,4,3,2,1]
encryption = [718944, 717147, 718684, 717237, 717067]
decryption = [43150699, 42951548, 43212244, 43205017, 43116422]

# Assuming `encryption` and `decryption` are lists of data
# Convert data into a Pandas DataFrame for Seaborn
data = pd.DataFrame({
    "Cycles": encryption + decryption,
    "Operation": ["Encryption"] * len(encryption) + ["Decryption"] * len(decryption)
})

# Set the Seaborn style
sns.set_theme()

# Create subplots
fig, axs = plt.subplots(1, 2, figsize=(10, 4))

# Plot the histograms
sns.histplot(data[data["Operation"] == "Encryption"], x="Cycles", ax=axs[0], kde=False, color="b", label="# Cycles")
sns.histplot(data[data["Operation"] == "Decryption"], x="Cycles", ax=axs[1], kde=False, color="r", label="# Cycles")

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
plt.tight_layout()
plt.savefig("encryption_decryption_perf.pdf")
