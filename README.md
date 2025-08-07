> [!WARNING]
> The program is still under development.  
>

# AlanZ80X

**An extended Turing machine implementation**  


## About this implementation

_The AlanZ80X is an idea that tries to combine a microcontroller and a state machine. It might get made, but it's not certain. But I can say that it's great for fun. And to be challenging in the fun, it has to fit into 64kB._  

### In a nutshell 

This state machine differs from Turing's original model in several ways: it has four general I/O tapes, a stack tape and some registers. Can write to standard output device (CON:, PRN:, LST:) instead of tape. The tapes are represented by typed files. One register can be used arbitrarily and the others provide information about the current state of the machine. The machine also has a simple interrupt handling. The interrupt request is initiated by flag files. The machine's basic program, settings, and commands required for automated execution contained in t36 file. In the state change table, the basic program is divided into parts according to the number of instruction codes and interrupts on the program tape.

### How it works?

The framework is command-line controlled. When the t36 file is loaded, the machine is initialized, the basic program is loaded, and - if specified - the commands are executed. After the machine starts, it starts reading the program tape (p36) and, if necessary, the data tape (d36). The program and data tape are read-only by default, but this can be overridden. During operations, the stack tape (s36), which acts as a traditional stack, the temporary tape (t36) and the accumulator register (ACC) can also be used. The result tape (r36) is used to print the result, which is by default read/write only. It is also possible to write to the console, but this is write-only. The result tape can be used in the same way as the single tape of a traditional Turing machine. The machine works only by reading and writing symbols and using state transitions.
When an interrupt request is detected, the basic program jumps to the appropriate state and then acts accordingly. On a multitasking system, the signal file can be created by another program, but on CP/M and DOS we have to make do with the options provided by the framework system. A hot-key creates the file, which is handled by the running machine. (The machine does not handle the keystrokes.)

Copyright (C) 2025 Pozsár Zsolt <pozsarzs@gmail.com>  


## Features

|features                |                                                     |
|------------------------|-----------------------------------------------------|
|version                 |v0.1                                                 |
|licence                 |EUPL v1.2                                            |
|language                |en                                                   |
|user interface          |CLI                                                  |
|programming language    |Borland Turbo Pascal 3.x                             |
|architecture            |ix86, Z80                                            |
|OS                      |CP/M and DOS (and others, see comments in the source.|
|symbol set              |up to 40 characters                                  |
|state set               |up to 100 states                                     |
|example program         |? scripts                                            |
|source files            |base program and settings (*.t36)                    |
|                        |user program code (*.p36)                            |
|                        |user data (*.d36)                                    |
|                        |IRQ flag (*.i36)                                     |
|work files              |temporary tape (*.t36)                               |
|                        |stack tape - virtual memory (*.s36)                  |
|target files            |result tape (*.r36)                                  |
|built-in commands       |? (can also be used in a program file)               |


## Screenshots

Startup screen  
![CLI](startup.png)

Example #1  
![CLI](example1.png)


## Structure of files used by programs

### The t36 file

This file type is used to load the Turing machine's (base) program, define initial settings, and automate execution. The following table follows the structure of the file and provides a brief description of the lines.  

|Label                      |Description                |Alanz80  |AlanZ80X |Note           |
|---------------------------|---------------------------|:-------:|:-------:|---------------|
|`; comment`                |comment                    |         |         |               |
|`PROG BEGIN`               |begin of program           |mandatory|mandatory|               |
|`NAME progname`            |program name               |mandatory|mandatory|<= 8 chars.    |
|`SYMB 0123456789PROG`      |set of symbols             |mandatory|mandatory|<= 40 chars.   |
|`STAT 3`                   |number of states           |mandatory|mandatory|with q0        |
|`CARD BEGIN`               |begin of the card section  |mandatory|mandatory|               |
|`     STnn ...`            |base program               |mandatory|mandatory|See later!     |
|`CARD END`                 |end of card section        |mandatory|mandatory|               |
|`TAPE BEGIN`               |begin of tape section      |optional |mandatory|               |
|`     SYMB 012345679`      |data tape content          |optional |optional |               |
|`     SPOS 1`              |data tape start position   |optional |optional |               |
|`     CNSL WO devicename`  |assign device to console   |   N/A   |mandatory|See later!     |
|`     DATA RO filename.d36`|assign file to data tape   |   N/A   |mandatory|RO/WO/RW       |
|`     PROG RO filename.p36`|assign file to program tape|   N/A   |mandatory|RO/WO/RW       |
|`     STCK RW filename.s36`|assign file to stack tape  |   N/A   |mandatory|RO/WO/RW       |
|`     RSLT RW filename.r36`|assign file to result tape |   N/A   |mandatory|RO/WO/RW       |
|`     TEMP RW filename.t36`|assign file to result tape |   N/A   |mandatory|RO/WO/RW       |
|`TAPE END`                 |end of tape section        |optional |mandatory|               |
|`COMM BEGIN`               |begin of command section   |optional |optional |               |
|`     ...`                 |command line commands      |optional |optional |               |
|`COMM END`                 |end of command section     |optional |optional |               |
|`PROG END`                 |end of program             |mandatory|mandatory|               |

#### Base program format

AlanZ80:  
  `STqi SjSkDqm SjSkDqm ... SjSkDqm`  
For example: `ST01 56R02`, where qi = 01; Sj = '5'; Sk = '6'; D = R and qm = 02.
  
AlanZ80X:  
  `STqi TjSjTkSkTjDTkDqm TjSjTkSkTjDTkDqm ... TjSjTkSkTjDTkDqm`
For example: `ST01 ixryirrr02`, where  qi = 01; Sj = 'x' from tape Tj = i; Sk = 'y' to tape Tk = r; D = R relation to the tape Tj = i; D = R relation to the tape Tk = r; and qm = 02.

See README.md for details.

#### Console devices


CON:' in CP/M, which could be written or read;

the LIST device, usually referred to as 'LST:' in CP/M, which could only be written;

the PUNCH device, usually referred to as 'PUN:' in CP/M, which could only be written;

the READER device, usually referred to as 'RDR:


CON: — console (input and output)
AUX: — an auxiliary device. In CP/M 1 and 2, PIP used PUN: (paper tape punch) and RDR: (paper tape reader) instead of AUX:
LST: — list output device, usually the printer
PRN: — as LST:, but lines were numbered, tabs expanded and form feeds added every 60 lines
NUL: — null device, akin to /dev/null
EOF: — input device that produced end-of-file characters, ASCII 0x1A
INP: — custom input device, by default the same as EOF:
OUT: — custom output device, by default the same as NUL:

Note:  
*:
**:

|`     STnn *`              |base program                |qi SjSkDqm|qi TjSjTkSkDDqm|T: i|p|s|r       |

|`     CNSL devicename`     |assign device to console    |   N/A    |mandatory      |WO                 |
|`     CNSL WO CON:        `|assign device to console    |   N/A    |mandatory      |WO                 |
|`     CNSL WO PRN:        `|assign device to console    |   N/A    |mandatory      |WO                 |
|`     DATA RO filename.d36`|assign file to data tape    |   N/A    |mandatory      |RO/WO/RW           |
|`     PROG RO filename.p36`|assign file to program tape |   N/A    |mandatory      |RO/WO/RW           |
|`     STCK RW filename.s36`|assign file to stack tape   |   N/A    |mandatory      |RO/WO/RW           |
|`     RSLT RW filename.r36`|assign file to result tape  |   N/A    |mandatory      |RO/WO/RW           |


### Data format on tapes

The tape stores data in human-readable form.

|Type of tape|Description     |Note                                 |Example content |
|------------|----------------|-------------------------------------|----------------|
|data tape   |for input data  |not empty, created by the user       |`D36_1_123_5643`|
|program tape|for user program|not empty, created by the user       |`P36_1##_4#`    |
|stack tape  |for stack       |created or overwritten by the program|`S36_23_54_12`  |
|result tape |for output data |created or overwritten by the program|`R36_123_511_1` |


## Example programs

```
; This example program also increments the input number by 1, but in a different
; way. You can use this with AlanZ80X extended Turing machine implementation.
; The program turns on tracing after starting, then start machine. The machine
; reads the instructions from the program tape and the corresponding data from
; the data tape. It uses the stack tape and the result tape to perform the
; operations, the machine stops and the result is stored on the latter.
; After stopping, it loads a machine with a different configuration (represented
; by the next.t36 file and continues working with its result.

PROG BEGIN
NAME PLUS1X
DESC Increment the input number by 1
SYMB 0123456789
STAT 3
CARD BEGIN
     ST01 ... 
     ST02 ... 
     ... 
CARD END
TAPE BEGIN
     DATA RO data.tap
     PROG RO program.tap
     STCK RW stack.tap
     RSLT RW output.tap
TAPE END
COMM BEGIN
     TRACE ON
     RUN
     LOAD next.t36
COMM END
PROG END
```
