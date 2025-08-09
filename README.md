> [!WARNING]
> The program is still under development.  
>

# AlanZ80X

**An extended Turing machine implementation**  


## About this implementation

_The AlanZ80X is an idea that takes the concept of a Turing machine to a new level. It may be possible, but it’s not certain that it will succeed. It might get made, but it's not certain. But I can say that it's great for fun. And to be challenging in the fun, it has to fit into 64kB._  

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
|interrupts              |4                                                    |
|registers               |?                                                     |
|source files            |base program and settings (*.t36)                    |
|                        |user program code (*.p36)                            |
|                        |user data (*.d36)                                    |
|                        |IRQ flag (*.i36)                                     |
|work files              |temporary tape (*.t36)                               |
|                        |stack tape - virtual memory (*.s36)                  |
|target files            |result tape (*.r36)                                  |
|built-in commands       |? (can also be used in a program file)               |
|example program         |? scripts                                            |


## Screenshots

Startup screen  
![CLI-1](startup.png)

Example #1  
![CLI-2](example1.png)


## Machine of sets - sets of the machine

### Head movement direction set

Finite set of head movement directions is as follows:

D = {d0..d2}, where the

- d0 = 'L' is the left direction,
- d1 = 'S' is the stay here, and
- d2 = 'R' is the right direction.

### State set

The state is called an m-configuration in Turing terminology. The finite set of states is as follows:

Q = {q0..q255}, where the

- q0 is the mandatory final state,
- q1-253 free space,
- q254 is command vectors,
- q255 interrupt vectors.

#### Tape symbol set

Finite set of tape symbols is as follows:

S = {s0..s39}, where the

- s0 is the mandatory blank (_) character.
- s1-s39 is are optional symbols.

The set has cardinality at least one, and its first element is always the blank
symbol.

#### Tape set

Finite set of tape is as follows:

T = {tc, td, tp, tr, ts, tt}, where the
- tc = consol or output device: CON:, LST:, PUN:.
- td = filename.d36, it is the data tape,
- tp = filename.p36, it is the user program tape,
- tr = filename.r36, it is the result tape,
- ts = filename.s36, it is the stack tape,
- tt = filename.t36, it is the temporary tape,

## Operation

The operation of the machine is based on state transitions, which can be described by 8tuples, in the form below.

|mode|initial state|from| to  |read|write|move|move|final state|          8-tuple                |
|:--:|:-----------:|:--:|:---:|:--:|:---:|:--:|:--:|:---------:|:-------------------------------:|
| M1 |      qi     | tj | tk  | sj | sk  | dj | dk |    qm     |(qi, tj, tk, sj, sk, dj, dk, qm) |	
| M2 |      qi     | tj | rk  | sj | sk  | dj | d1 |    qm     |(qi, tj, tk, sj, sk, dj, 'S', qm)|	
| M3 |      qi     | rj | tk  | sj | sk  | d1 | dk |    qm     |(qi, tj, tk, sj, sk, 'S', dk, qm)|	

Notes:  
- qi is the actual state, qi ∈ Q.
- tj is the tape from which the machine reads a symbol, tj ∈ T and tj <> tc.
- tk is the the tape to which the machine writes a symbol, tk ∈ T.
- sj is the actual symbol read from the tape, sj ∈ S.
- sk is the symbol to be written to the tape, sk ∈ S.
- dj is the head moving direction over tape tj, dj ∈ D.
- dk is the head moving direction over tape tk, dj ∈ D. If tk = tc -> dj = d1 (stay).
- qm is the next state, qm ∈ Q.
- rj is the register from which the machine reads a symbol, rj ∈ R and rj = r0 (ACC), dj = d1.
- rk is the register to which the machine writes a symbol, rk ∈ R and rk = r0 (ACC), dk = d1.

In the CODE section of the program, the 8-tuples must be specified in the following form: `001 irabRL002 ...`, where the:  

- qi = 001, it is the initial state,
- tj = d (= td), it is the data tape,
- tk = r (= tr), it is the result tape,
- sj = 'a', it is the read symbol from data tape,
- sk = 'b', it is the symbol to be written to result tape,
- dj = 'R' (=d2), it is the head moving direction over data tape,
- dk = 'L' (=d0), it is the head moving direction over result tape,
- qm = 002, it is the final state.


## Registers

(...)


## Structure of files used by programs

### The t36 file

This file type is used to load the Turing machine's (base) program, define initial settings, and automate execution. The following table follows the structure of the file and provides a brief description of the lines.  

|Label                      |Description                   |Alanz80  |AlanZ80X |Note           |
|---------------------------|------------------------------|:-------:|:-------:|---------------|
|`; comment`                |comment                       |         |         |               |
|`PROG BEGIN`               |begin of program              |mandatory|mandatory|               |
|`NAME progname`            |program name                  |mandatory|mandatory|<= 8 chars.    |
|`SYMB 0123456789PROG`      |set of symbols                |mandatory|mandatory|<= 40 chars.   |
|`STAT 3`                   |number of states              |mandatory|mandatory|with q0        |
|`CARD BEGIN`               |begin of the card section     |mandatory|mandatory|               |
|`     STnn ...`            |base program                  |mandatory|mandatory|See later!     |
|`CARD END`                 |end of card section           |mandatory|mandatory|               |
|`TAPE BEGIN`               |begin of tape section         |optional |mandatory|               |
|`     SYMB 012345679`      |data tape content             |optional |optional |               |
|`     SPOS 1`              |data tape start position      |optional |optional |               |
|`     CNSL WO devicename:` |assign device to console      |   N/A   |mandatory|See later!     |
|`     DATA RO filename.d36`|assign file to data tape      |   N/A   |mandatory|RO/WO/RW       |
|`     PROG RO filename.p36`|assign file to program tape   |   N/A   |mandatory|RO/WO/RW       |
|`     STCK RW filename.s36`|assign file to stack tape     |   N/A   |mandatory|RO/WO/RW       |
|`     RSLT RW filename.r36`|assign file to result tape    |   N/A   |mandatory|RO/WO/RW       |
|`     TEMP RW filename.t36`|assign file to temporary tape |   N/A   |mandatory|RO/WO/RW       |
|`TAPE END`                 |end of tape section           |optional |mandatory|               |
|`COMM BEGIN`               |begin of command section      |optional |optional |               |
|`     ...`                 |command line commands         |optional |optional |               |
|`COMM END`                 |end of command section        |optional |optional |               |
|`PROG END`                 |end of program                |mandatory|mandatory|               |

Note:  
- This file type has limited use with the previous version of the Turing machine, the table provides guidance.
- If the first symbol specified in the CONF section is not blank, then it will be inserted.

### Data format on tapes

The tape stores data in human-readable form.

|Type of tape  |Description       |Note                                 |Example content |
|--------------|------------------|-------------------------------------|----------------|
|data tape     |for input data    |not empty, created by the user       |`D36_1_123_5643`|
|program tape  |for user program  |not empty, created by the user       |`P36_1##_4#`    |
|result tape   |for output data   |created or overwritten by the program|`R36_123_511_1` |
|stack tape    |for stack         |created or overwritten by the program|`S36_23_54_12`  |
|temporary tape|for temporary data|created or overwritten by the program|`T36_23_54_12`  |


## Example program

```
; You can use this with AlanZ80X extended Turing machine implementation.
; The program turns on tracing after starting, then start machine. The machine
; reads the instructions from the program tape and the corresponding data from
; the data tape. It uses the stack tape and the result tape to perform the
; operations, the machine stops and the result is stored on the latter.
; After stopping, it loads a machine with a different configuration (represented
; by the next.t36 file and continues working with its result.

PROG BEGIN
NAME PLUS1X
DESC Conversion between Roman and Arabic numerals 
SYMB 0123456789IVXLCDM
STAT 33
CARD BEGIN
     ST01 ... 
     ST02 ... 
     ... 
CARD END
TAPE BEGIN
     DATA RO data.d36
     PROG RO program.p36
     STCK RW stack.s36
     RSLT RW output.r36
TAPE END
COMM BEGIN
     TRACE ON
     RUN
     LOAD next.t36
COMM END
PROG END
```
