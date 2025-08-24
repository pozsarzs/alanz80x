> [!WARNING]
> The program is still under development.  
>

# AlanZ80X

**An extended Turing machine implementation**  


## Technical documentation

The notations used in mathematical formulas are included in the description. The corresponding variable or constant is also indicated.


### How does the program store tuples?

#### In the file

The basic program is stored in the t36 file as follows:

```
SYMB _@#0123456789
CARD BEGIN
;    ----- s0-------- s1-------- s2-------- ... s12-------
     ST000 R8_RST2000 T3_RRT1001 R8#RST2000 ... R89RST2000
     ... 
CARD END
```

'STnnn' is the state, where nnn is the state number. The following groups are tuples for state nnn. Meaning of the characters in the first tuple:

- q<sub>i</sub> = 000, it is the initial state,
- t<sub>j</sub> = not specified, at the start t<sub>j</sub>=t<sub>0</sub>, in the following it is the same as the t<sub>m</sub> of the previous tuple.,
- r<sub>k</sub> = R8, it is the bottomless register (BLR),
- s<sub>j</sub> = not specified, the symbol number is the same as the tuple number in this status line,
- s<sub>k</sub> = '_', it is the symbol to be written to result tape,
- d<sub>j</sub> = R, it is the head moving direction over t<sub>j</sub> tape,
- d<sub>k</sub> = S, it is the head moving direction in r<sub>k</sub> register,
- t<sub>m</sub> = T2, it is the user program tape,
- q<sub>m</sub> = 000, it is the final state.


#### In the variable

The _recently read_ tuple is stored in the variable tprec. This variable is of type `TPRecently`, which is a record in the following structure:

```
type
  TTPRecently = record                                   { recently read tuple }
    aqi:        byte;                                           { actual state }
    atrj:       byte;                              { actual input data carrier }
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

Possible values of variables:
- `qi`: 0..127,
- `trj`: t<sub>0</sub>..t<sub>5</sub>: 0..5 and r<sub>0</sub>..r<sub>7</sub>: 6..13,
- `trk`: t<sub>0</sub>..t<sub>5</sub>: 0..5 and r<sub>0</sub>..r<sub>7</sub>: 6..13,
- `sj`: 0..39, it is one less than the symbol's position in the variable `machines.symbols`,
- `sk`: 0..39, it is one less than the symbol's position in the variable `machines.symbols`,
- `dj`: left = 0; stay = 1 and right = 2,
- `dk`: left = 0; stay = 1 and right = 2,
- `trm`: t<sub>0</sub>..t<sub>5</sub>: 0..5 and r<sub>0</sub>..r<sub>7</sub>: 6..13,
- `qm`: 0..127.


#### The tuple number

Each state has as many tuples as the cardinality of the symbol set. The exception is the final state, which causes the machine to stop. The number of tuples is 5080 based on the formula below:

$$
|tuples| = (|Q| - 1) \cdot |S|
$$

In the program the number of symbol is represented by the constant `SYMCOUNT`, and the number of tuples is by the constant `TPBLCOUNT`.

The tuples are logically organized into an array, one array index of which is the state and the other is the symbol number.

|               |s<sub>0</sub>|s<sub>1</sub>|s<sub>2</sub>|...|s<sub>39</sub>|
|:-------------:|------------:|------------:|------------:|---|-------------:|
|q<sub>0</sub>  |            0|            1|            2|...|            39|
|q<sub>1</sub>  |           40|           41|           42|...|            79|
|q<sub>2</sub>  |           80|           81|           82|...|           119|
|...            |...          |...          |...          |...|...           |
|q<sub>126</sub>|         5040|         5041|         5042|...|          5079|

The tuple number is the sequence number of elements in the array, which can be calculated as follows:

$$
tuple\\_number(q_n,s_n) = idx(q_n) \cdot |S| + idx(s_n)
$$

In the program, the q<sub>n</sub> is represented by the constant `STCOUNT` and the number of symbol is by the constant `SYMCOUNT`.


#### Bit encoding

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

** Head moving directions **  

|b2 b1 b0| tj  | tk  |
|:------:|:---:|:---:|
| 1  1  1|stay |right|
| 1  1  0|stay |left |
| 1  0  1|right|stay |
| 1  0  0|right|right|
| 0  1  1|right|left |
| 0  1  0|left |stay | 
| 0  0  1|left |right|
| 0  0  0|left |left |


#### The byte index

The byte number is the position of a byte within a tuple in the memory area, which can be calculated like this:

$$
byte\\_number(q_n,s_n,byte\\_count) = tuple\\_number(q_n,s_n) \cdot block\\_size + byte\\_count
$$

In the program, the block_size is represented by the constant `TPBLSIZE` with value 3, and the byte_count is by variable `byte_count`, with the number of the examined byte of the block (0..2). 


#### The memory address

The calculation of the memory address of a tuple is as follows:

$$
address(q_n,s_n,byte\\_count) = address(tuples\\_area) + byte\\_number(q_n,s_n,byte\\_count)
$$

In the program, the address is reprezented by `bn2tpaddr` variable, the tupless_area is by `machine.tuples^` pointer and the byte_count is by variable `byte_count`:
  
```
  bn2tpaddr := ptr(seg(machine.tuples^), ofs(machine.tuples^) + byte_number);
```
