> [!WARNING]
> The program is still under development.  
>

# AlanZ80X

**An extended Turing machine implementation**  


## About this implementation

_The AlanZ80X is an idea that takes the concept of a Turing machine to a new level. It may be possible, but it’s not certain that it will succeed. It might get made, but it's not certain. But I can say that it's great for fun. And to be challenging in the fun, it has to fit into 64kB._  


### In a nutshell 

This state machine differs from Turing's original model in several ways: it has four general and two special I/O tapes and some registers.

Unlike the traditional multi-tape Turing, this machine always handles only two tapes (and/or registers), it reads the one specified in the previous tuple and writes the one specified in the current tuple. The purpose and permissions of the general tapes are not specified, but the machine starts with a recommended default setting that can be changed. The recommended setup defines a user data and program tape, a temporary tape, and a results tape. The machine has two additional special-purpose tapes: the stack and the other representing one of the standard output devices. Machine can write to output device: CON:, AUX:, LST:, PRN:, TRM: and if you are very lucky, how do you have PUN: instead of or in addition tape. The tapes are represented by text files that are updated after each step.

One register can be used arbitrarily and the others provide information about the current state of the machine. The purpose and permissions of the registers are predefined. The registers store data as a string of symbols, and can be specified in the tuple instead of a tape.

The machine also has a simple interrupt handling. The interrupt request is initiated by a keystroke.

The machine works only based on the status table. The machine's basic program (tuples), settings, and commands required for automated execution contained in t36 file. In the state change table, the basic program is divided into parts according to the number of instruction codes and interrupts on the program tape.


### How it works?

The framework is command-line controlled. The help provides information about the commands available on the command line. We can change the program's breakpoint, tracking, number of steps, symbol set, and the association of tapes and files. We can get various information about the machine, tapes, and registers. We can load the t36 file and run the machine even step by step.

Its operation is generally simple: the loaded t36 file contains all the data required for the machine to operate. After starting the machine, it determines the symbol to be printed and the next state based on the scanned symbol and the current state.

This process is not that simple in the default setting: after the machine starts, it starts reading the program tape (t<sub>2</sub>), then reads the corresponding data from the data tape (t<sub>1</sub>). The program and data tape now are read-only. During operations, the stack tape (t<sub>5</sub>), which acts as a traditional stack, the temporary tape (t<sub>4</sub>) and the accumulator register (r<sub>0</sub>) can also be used. The result tape (t<sub>3</sub>) is used to print the result. It is also possible to write to the console, but this is always write-only.

Because the tape functions are just names, they must be ensured by setting the appropriate permissions and writing the status table correctly. For example, there is no pre-written stack management.

The state vectors for commands and interrupts are placed in two rows of the state table (jump tables). When an interrupt request is detected, the basic program jumps to the appropriate state and then acts accordingly.

Copyright (C) 2025 Pozsár Zsolt <pozsarzs@gmail.com>  


## Features

|features             |                                                     |
|---------------------|-----------------------------------------------------|
|version              |v0.1                                                 |
|licence              |EUPL v1.2                                            |
|architecture         |i86, Z80                                             |
|OS                   |CP/M and DOS                                         |
|compiler             |Borland Turbo Pascal v3.01a PC-DOS and CP/M-80 (1985)|
|framework            |                                                     |
| ~ user interface    |CLI                                                  |
| ~ language          |en                                                   |
| ~ commands          |15                                                   |
| ~ extras            |breakpoint, tracking                                 |
| ~ example programs  |1                                                    |
|state machine        |                                                     | 
| ~ commands          |number of symbols - 3                                |
| ~ interrupts        |number of symbols - 3                                |
| ~ registers         |1 general                                            |
|                     |6 status                                             |
|                     |1 special ('bottomless')                             |
| ~ state set         |up to 128 states                                     |
| ~ symbol set        |up to 40 characters (2 mandatory and 38 optional)    |
| ~ tapes             |1 virtual (to standard output)                       |
|                     |4 general                                            |
|                     |1 special (stack)                                    |
| ~ files             |base 'program' and settings (*.t36)                  |


## Screenshots

Startup screen  
![CLI-1](startup.png)

Example #1  
![CLI-2](example1.png)


## The mathematical model of the machine

### Formal description

$$
M = (Q, T, R, S, D, q_0, \delta), \text{ where the: }
$$

 - Q: finite state set,
 - T: finite tape set,
 - R: finite register set,
 - S: finite symbol set,
 - D: finite head moving direction set,
 - q<sub>0</sub>: initial state and
 - $\delta$: transition function.


### Transition function

$$
\delta: (Q \times (T \cup R) \times S) \rightarrow Q \times (T \cup R) \times S \times D
$$

Input:  current state, a selected data source (tape or register), and the symbol read from it.  
Output: new state, selected data target (tape or register), symbol to be written, and head movement.


## Machine of sets - sets of the machine

These are the machine's sets in alphabetical order, with indexed elements. Most elements of a set are abstract identifiers, but any elements that have a value are specified. This value is used in the t36 file and in program messages.


### Head movement direction set

Finite set of head movement directions is as follows:

$$
D = \\{ d_0, d_1, d_2 \\}, \text{ where the: }
$$

- d<sub>0</sub> = L, it is the left direction,
- d<sub>1</sub> = S, it is the stay here, 
- d<sub>2</sub> = R, it is the right direction.

Left/right moves must be specified for all registers and tapes, but for some they are ineffective. The stack head moves independently, for single-symbol registers the head cannot move, for standard output it always moves right.


### Register set

The finite set of registers and the symbol chains on them are as follows:

$$
R = \\{ r_0, \dots, r_7 \\} \text{ and } w(t_n) \in S^*, \text{ where the: }
$$

- r<sub>0</sub>: Accumulator (ACC) - char type,
- r<sub>1</sub>: t<sub>1</sub> Tape Position (1TP) - integer type,
- r<sub>2</sub>: t<sub>2</sub> Tape Position (2TP) - integer type,
- r<sub>3</sub>: t<sub>3</sub> Tape Position (3TP) - integer type,
- r<sub>4</sub>: t<sub>4</sub> Tape Position (4TP) - integer type,
- r<sub>5</sub>: Stack Tape Position (STP) - integer type,
- r<sub>6</sub>: Program Step Counter (PSC) - integer type,
- r<sub>7</sub>: Bottomless register (BLR) - char type,
- w: Symbol chain in the register.

All register value are stored as string. Reading and writing is done in the same way as with tape. The bottomless register swallows the symbol written into it and always returns '_' when read.


### State set

The state is called an m-configuration in Turing terminology. The finite set of states is as follows:

$$
Q = \\{ q_0, \dots, q_{127} \\}, \text{ where the: }
$$

- q<sub>0</sub>, is the default initial state,
- q<sub>1</sub>-q<sub>124</sub> are the free space,
- q<sub>125</sub> is command vectors,
- q<sub>126</sub> interrupt vectors,
- q<sub>127</sub> is the mandatory final state.


### Tape symbol set

Finite set of tape symbols is as follows:

$$
S = \\{ s_0, \dots, s_{39} \\}, \text{ where the: }
$$

- s<sub>0</sub> is the mandatory blank character (_),
- s<sub>1</sub> is the mandatory end character (#),
- s<sub>2</sub>-s<sub>39</sub> are optional symbols.

The set must have at least two elements. To use registers, decimal numbers must also be included in the symbol set. Default symbol set is '_#ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-'.


### Tape set

The finite set of tapes and the symbol chains on them are as follows:

$$
T = \\{ t_0, \dots, t_5 \\} \text{ and } w(t_n) \in S^*, \text{ where the: }
$$

- t<sub>0</sub>: standard output device of the OS (CON:, LST:, ...),
- t<sub>1</sub>-t<sub>4</sub>: general purpose tapes,
- t<sub>5</sub>: stack tape,
- w: Symbol chain on the tape.

By default:
- t<sub>0</sub>: redirected to the CON: device,
- t<sub>1</sub>: data tape,
- t<sub>2</sub>: program tape,
- t<sub>3</sub>: result tape,
- t<sub>4</sub>: temporary tape and
- t<sub>5</sub>: stack tape.


## Operation

The operation of the machine is based on state transitions, which can be described by tuples, in the form below. Operating modes determine the direction of read and write operations.

|mode|   initial   |     from    |      to     |    read     |    write    |    move     |     move    |            next           |    final    |                                                                              9-tuple                                                                |
|:--:|:-----------:|:-----------:|:-----------:|:-----------:|:-----------:|:-----------:|:-----------:|:-------------------------:|:-----------:|:---------------------------------------------------------------------------------------------------------------------------------------------------:|
| M1 |q<sub>i</sub>|t<sub>j</sub>|t<sub>k</sub>|s<sub>j</sub>|s<sub>k</sub>|d<sub>j</sub>|d<sub>k</sub>|t<sub>m</sub>/r<sub>m</sub>|q<sub>m</sub>|(q<sub>i</sub>, t<sub>j</sub>, t<sub>k</sub>, s<sub>j</sub>, s<sub>k</sub>, d<sub>j</sub>, d<sub>k</sub>, t<sub>m</sub>/r<sub>m</sub>, q<sub>m</sub>)|
| M2 |q<sub>i</sub>|t<sub>j</sub>|r<sub>k</sub>|s<sub>j</sub>|s<sub>k</sub>|d<sub>j</sub>|d<sub>k</sub>|t<sub>m</sub>/r<sub>m</sub>|q<sub>m</sub>|(q<sub>i</sub>, t<sub>j</sub>, r<sub>k</sub>, s<sub>j</sub>, s<sub>k</sub>, d<sub>j</sub>, d<sub>k</sub>, t<sub>m</sub>/r<sub>m</sub>, q<sub>m</sub>)|
| M3 |q<sub>i</sub>|r<sub>j</sub>|t<sub>k</sub>|s<sub>j</sub>|s<sub>k</sub>|d<sub>j</sub>|d<sub>k</sub>|t<sub>m</sub>/r<sub>m</sub>|q<sub>m</sub>|(q<sub>i</sub>, r<sub>j</sub>, t<sub>k</sub>, s<sub>j</sub>, s<sub>k</sub>, d<sub>j</sub>, d<sub>k</sub>, t<sub>m</sub>/r<sub>m</sub>, q<sub>m</sub>)|
| M4 |q<sub>i</sub>|r<sub>j</sub>|r<sub>k</sub>|s<sub>j</sub>|s<sub>k</sub>|d<sub>j</sub>|d<sub>k</sub>|t<sub>m</sub>/r<sub>m</sub>|q<sub>m</sub>|(q<sub>i</sub>, r<sub>j</sub>, r<sub>k</sub>, s<sub>j</sub>, s<sub>k</sub>, d<sub>j</sub>, d<sub>k</sub>, t<sub>m</sub>/r<sub>m</sub>, q<sub>m</sub>)|

Notes:  
- d<sub>j</sub> is the head moving direction over the input data carrier, d<sub>j</sub> $\in$ D,
- d<sub>k</sub> is the head moving direction over the result data carrier, d<sub>k</sub> $\in$ D,
- d<sub>j</sub> and d<sub>k</sub> cannot be 'S' at the same time,
- q<sub>i</sub> is the actual state, q<sub>i</sub> $\in$ Q,
- q<sub>m</sub> is the next state, q<sub>m</sub> $\in$ Q,
- r<sub>j</sub> is the register from which the machine reads a symbol, r<sub>j</sub> $\in$ C,
- r<sub>k</sub> is the the register to which the machine writes a symbol, r<sub>j</sub> $\in$ C,
- r<sub>m</sub> is the next register from which the machine reads a symbol, t<sub>m</sub> $\in$ C,
- s<sub>j</sub> is the actual symbol read from the data carrier, s<sub>j</sub> $\in$ S,
- s<sub>k</sub> is the symbol to be written to the data carrier, s<sub>k</sub> $\in$ S,
- t<sub>j</sub> is the tape from which the machine reads a symbol, t<sub>j</sub> $\in$ C,
- t<sub>k</sub> is the tape to which the machine writes a symbol, t<sub>j</sub> $\in$ C,
- t<sub>m</sub> is the next tape from which the machine reads a symbol, t<sub>m</sub> $\in$ C.


## Structure of files used by programs

### The t36 file

This file type is used to load the Turing machine's (base) program, define initial settings, and automate execution. The following table follows the structure of the file and provides a brief description of the lines.  

|Label                      |Description                   |Alanz80  |AlanZ80X |
|---------------------------|------------------------------|:-------:|:-------:|
|`; comment`                |comment                       |         |         |
|`PROG BEGIN`               |begin of program              |mandatory|mandatory|
|`NAME progname`            |program name                  |mandatory|mandatory|
|`SYMB _#0123456789`        |set of symbols                |mandatory|mandatory|
|`STAT 3`                   |number of states              |mandatory|   N/A   |
|`ECHO ON\|OFF`             |tape write echo to TAP0       |   N/A   |optional |
|`INTR ON\|OFF`             |interrupt detection           |   N/A   |optional |
|`CARD BEGIN`               |begin of the card section     |mandatory|mandatory|
|`     STnnn ...`           |base program                  |mandatory|mandatory|
|`CARD END`                 |end of card section           |mandatory|mandatory|
|`TAPE BEGIN`               |begin of tape section         |optional |mandatory|
|`     INIT 2`              |initial tape                  |   N/A   |optional |
|`     SYMB 012345679`      |data tape content             |optional |   N/A   |
|`     SPOS 1`              |data tape start position      |optional |   N/A   |
|`     TAP0 WO devicename:` |assign device to output       |   N/A   |mandatory|
|`     TAPn RO filename.ext`|assign file to general tape   |   N/A   |mandatory|
|`     STCK RW filename.ext`|assign file to stack tape     |   N/A   |mandatory|
|`TAPE END`                 |end of tape section           |optional |mandatory|
|`COMM BEGIN`               |begin of command section      |optional |optional |
|`     ...`                 |command line commands         |optional |optional |
|`COMM END`                 |end of command section        |optional |optional |
|`PROG END`                 |end of program                |mandatory|mandatory|

Note:  
- This file type has limited use with the previous version of the Turing machine, the table provides guidance.
- If the first and second symbols specified in the CONF section is not '_#', then they will be inserted.
- The default value of the ECHO option is OFF.
- The default value of the INTR option is OFF.
- The default value of the INIT option in TAPE section is 1 (tape t<sub>1</sub>).
- The 9-tuples must be specified in the following form:

 `ST000 R7_RST2000 ...`, where the:  

'STnnn' is the state, where nnn is the state number. The following groups are tuples for state nnn. Meaning of the characters in the first tuple:

- q<sub>i</sub> = 000, it is the initial state,
- t<sub>j</sub> = not specified, at the start t<sub>j</sub>=t<sub>0</sub>, in the following it is the same as the t<sub>m</sub> of the previous tuple.,
- r<sub>k</sub> = R7, it is the bottomless register (BLR),
- s<sub>j</sub> = not specified, the symbol number is the same as the tuple number in this status line,
- s<sub>k</sub> = '_', it is the symbol to be written to result tape,
- d<sub>j</sub> = R, it is the head moving direction over t<sub>j</sub> tape,
- d<sub>k</sub> = S, it is the head moving direction in r<sub>k</sub> register,
- t<sub>m</sub> = T2, it is the 2nd general tape,
- q<sub>m</sub> = 000, it is the final state.


### Tapes

The tape stores data in human-readable form. Their content is updated with every change in status.


## Example program

### Program tape

`@1_@1_#`

### Data tape

`12_54_#`

### Base program card

```
; You can use this with AlanZ80X extended Turing machine implementation.
; The program turns on tracing after starting, then start machine. The machine
; reads the instructions from the program tape and the corresponding data from
; the data tape. The machine write result to the result tape.

PROG BEGIN
NAME INC1
DESC Increment the input number by 1 
INTR OFF
SYMB _@#0123456789
CARD BEGIN
;    ----- s0-------- s1-------- s2-------- s3-------- s4-------- s5-------- s6-------- s7-------- s8-------- s9-------- s10------- s11------- s12-------
     ST000 R8_RST2000 T3_RRT1001 R8#RST2000 R80RST2000 R81RST2000 R82RST2000 R83RST2000 R84RST2000 R85RST2000 R86RST2000 R87RST2000 R88RST2000 R89RST2000
     ST001 T3_SLT3002 R8@RST1001 R8@RST1001 T30RRT1001 T31RRT1001 T32RRT1001 T33RRT1001 T34RRT1001 T35RRT1001 T36RRT1001 T37RRT1001 T38RRT1001 T39RRT1001
     ST002 T3_RST3010 T3@L5T3002 T3@L5T3002 T30L5T3002 T31L5T3002 T32L5T3002 T33L5T3002 T34L5T3002 T35L5T3002 T36L5T3002 T37L5T3002 T38L5T3002 T39L5T3002
     ST010 T3_LST3011 R8@RST3010 R8#RST3010 T30RST3010 T31RST3011 T32RST3010 T33RST3010 T34RST3010 T35RST3010 T36RST3010 T37RST3010 T38RST3010 T39RST3010 
     ST011 T3_LST2000 R8@RST3011 R8#RST3011 T31LST2000 T32LST2000 T33LST2000 T34LST2000 T35LST2000 T36LST2000 T37LST2000 T38LST2000 T39LST2000 T30LST2000
     ST012 T31LST2000 R8@RST3012 R8#RST3012 T31LST3011 T32LST3011 T33LST3011 T34LST3011 T35LST3011 T36LST3011 T37LST3011 T38LST3011 T39LST3011 T30LST3011 
     ST125 R8_RST2125 R8_RST2125 R70RST2127 R71RST1010 R8_RST2125 R8_RST2125 R8_RST2125 R8_RST2125 R8_RST2125 R8_RST2125 R8_RST2125 R8_RST2125 R8_RST2125
CARD END
TAPE BEGIN
     TAP1 D RO data.tap
     TAP2 D RO program.tap
     TAP3 D RW result.tap
TAPE END
COMM BEGIN
     TRACE ON
     RUN
COMM END
PROG END
```


## Command line commands

The program can be controlled with the following command line commands.

|   |command                |description                                       |
|--:|-----------------------|--------------------------------------------------|
|  1|`break [state\|-]`     |set, get and reset breakpoint state (qb)          |
|  2|`help [command]`       |help with using the program                       |
|  3|`info`                 |show all information about this machine           |
|  5|`limit [steps\|-]`     |set, get and reset number of steps                |
|  6|`load filename.t36`    |load t36 file                                     |
|  7|`prog [from][to]`      |show program                                      |
|  8|`quit`                 |exit the program                                  |
|  9|`reg [0..7]`           |show register content                             |
| 10|`reset`                |reset program (cold reset)                        |
| 11|`restore`              |restore machine to original state (warm reset)    |
| 12|`run [head position]`  |run from data tape head position                  |
| 13|`step [head position]` |run step-by-step from data tape head position     |
| 14|`symbol [symbols\|-]`  |set, get and reset symbol set (S)                 |
| 15|`tape [0..5][filename]`|show tape content or assign file or device to tape|
| 16|`trace [on\|off]`      |turn tracking on and off                          |
