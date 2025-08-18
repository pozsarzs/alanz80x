> [!WARNING]
> The program is still under development.  
>

# AlanZ80X

**An extended Turing machine implementation**  


## Technical documentation

The notations used in mathematical formulas are included in the description. The corresponding variable or constant is also indicated.


### How does the program store tuples?

The basic program is stored in the t36 file as follows:

```
CARD BEGIN
     ST001 t1t3brlr2001 t1t3crlr2002 ...
     ST002 ... 
     ... 
CARD END
```

`STnnn` is the state, where nnn is the state number. The following groups are tuples for state nnn. Meaning of the characters in the first tuple:

- qi = 001, it is the initial state,
- tj/rj = t01, it is the data tape,
- tk/rk = t03, it is the result tape,
- sj = 'a', it is the read symbol from data tape,
- sk = 'b', it is the symbol to be written to result tape,
- dj = R, it is the head moving direction over data tape,
- dk = L, it is the head moving direction over result tape,
- tm/rm = r02, it is the PTP register,
- qm = 002, it is the final state.

The recently read tuple is stored in the variable tprec. This variable is of type TPRecently, which is a record in the following structure:

```
type
  TTPRecently = record                                   { recently read tuple }
    qi:         byte;                                           { actual state }
    trj:        byte; { tape or register from which the machine reads a symbol }
    trk:        byte;  { tape or register to which the machine writes a symbol }
    sj:         char;               { actual symbol read from the data carrier }
    sk:         char;               { symbol to be written to the data carrier }
    dj:         byte;      { head moving direction over the input data carrier }
    dk:         byte;     { head moving direction over the result data carrier }
    trm:        byte;     { next tape or register from which the machine reads }
    qm:         byte;                                             { next state }
var
    tprec:      TPRecently;                             { recently read tuple }

```

Each state has as many tuples as the cardinality of the symbol set. The exception is the final state, which causes the machine to stop:

  |tuples| = (|Q| - 1) * |S| = 127 * 40 = 5080

In the program the number of symbol is represented by the constant `SYMCOUNT`, and the number of tuples is by the constant `TPBLCOUNT`.

The tuples are logically organized into an array, one array index of which is the state and the other is the symbol number. The element number is the logical index of the tuple. The logical index can have values from 0..5079.

|    | s0 | s1 | s2 |...|s39 |
|:--:|---:|---:|---:|---|---:|
| q0 |   0|   1|  2 |...|  39|
| q1 |  40|  41| 42 |...|  79|
| q2 |  80|  81| 82 |...| 119|
|... |... |... |... |...|... |
|q126|5040|5041|5042|...|5079|

  logical_index(qn,sn) = idx(qn) * |S| + idx(sn)

In the program functions, the qn is represented by the constant `STCOUNT` and the number of symbol is by the constant `SYMCOUNT`.

Due to the economical use of available small memory space (Z80 - 64 kB), tuples are not stored in a record array, but in an area allocated at runtime in the heap. A tuple uses three bytes, which is called a tuple block. The order of the bytes is the same as the read/write order.

The bit encoding in the touple block is as follows:

|bit|0|variable|bit|1|variable|bit|2|variable|bit|
|:-:|-|:------:|:-:|-|:------:|:-:|-|:------:|:-:|
| 7 | |  trk   | 3 | |   sk   | 1 | |  trm   | 0 |
| 6 | |  trk   | 2 | |   sk   | 0 | |   qm   | 6 |
| 5 | |  trk   | 1 | | dj/dk  | 2 | |   qm   | 5 |
| 4 | |  trk   | 0 | | dj/dk  | 1 | |   qm   | 4 |
| 3 | |   sk   | 5 | | dj/dk  | 0 | |   qm   | 3 |
| 2 | |   sk   | 4 | |  trm   | 3 | |   qm   | 2 |
| 1 | |   sk   | 3 | |  trm   | 2 | |   qm   | 1 |
| 0 | |   sk   | 2 | |  trm   | 1 | |   qm   | 0 |

The physical index determines the number of the tuple block within the memory area, which can be calculated like this:

 physical_index(qn,sn) = logical_index(qn,sn) * TPBLSIZE + byte_count, where the
   
 - `TPBLSIZE` is a constant with value 3,
 - `byte_count` is a variable, with the number of the examined byte of the block (0..2).
The physical index can have values from (0,1,2)..(15237, 15238, 15239).

The calculation of the memory address of a tuple is as follows:

 address(qn,sn) = address(tuples_area) + physical_index(qn,sn).

What is implemented in the program is as follows:
  
```
  tpaddress := ptr(seg(machine.tuples^),
               ofs(machine.tuples^) + physical_index);
```
