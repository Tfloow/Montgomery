# Montgomery Multiplication

This work is protected under [**CC BY-NC-ND 4.0**](LICENSE) license. No derivative is permitted unless you have received the written permission by the two authors of this work and all involved party of this project.

____

Go to the [adder](/adder) folder

I think the state 7 is not quite ready yet 

| Width | Cycle |  WNS  | Slice LUTS | Slice Registers |
| :---: | :---: | :---: | :--------: | :-------------: |
|  514  |   3   | 0.376 |    2718    |      3106       |
|  514  |   3   | 0.133 |    3231    |      3120       |
|  343  |   4   | 0.379 |    2634    |      3116       |
|  257  |   5   | 0.474 |    2530    |      3118       |
|  64   |  18   | 2.302 |    2139    |      3185       |


![montgomery](report/montgomery.png)

![montgomery with more details of the verilog code](report/montgomery_details.png)

![FSM](report/fsm.png)