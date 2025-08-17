{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | declare.pas                                                              | }
{ | Global declarations                                                      | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

type
  { GENERAL TYPES }
  PByte =        ^byte;                                    { byte pointer type }
  TCommand =     string[255];
  TFilename =    string[12];
  TSplitted =    string[64];
  TThreeDigit =  string[3];
  { TURING MACHINE BASE CONFIGURATION TYPE }
  TTuring =      record                         { Turing machine configuration }
    progdesc:    string[64];                          { description of program }
    progname:    string[8];                                  { name of program }
    symbols:     string[40];                                    { symbolum set }
    tuples:      PByte;                              { pointer to tuple memory }
  end;
  { TYPES RELATED TO TURING MACHINES }
  TTPRecently = record                                   { recently read tuple }
    qi:         byte;                                           { actual state }
    tj:         byte; { tape or register from which the machine reads a symbol }
    tk:         byte;  { tape or register to which the machine writes a symbol }
    sj:         char;               { actual symbol read from the data carrier }
    sk:         char;               { symbol to be written to the data carrier }
    dj:         byte;      { head moving direction over the input data carrier }
    dk:         byte;     { head moving direction over the result data carrier }
    trm:        byte;     { next tape or register from which the machine reads }
    qm:         byte;                                             { next state }
  end;
  TRegisters =   record
    r0_acc:      char;                                     { Accumulator (ACC) }
    r1_dtp:      integer;                           { Data Tape Position (DTP) }
    r2_ptp:      integer;                        { Program Tape Position (PTP) }
    r3_rtp:      integer;                         { Result Tape Position (RTP) }
    r4_stp:      integer;                          { Stack Tape Position (STP) }
    r5_ttp:      integer;                      { Temporary Tape Position (STP) }
    r6_psc:      integer;                         { Program Step Counter (PSC) }
    r7_ir:       byte;                             { Instruction Register (IR) }
  end;
var
  bi: byte;
  command:       TCommand;                              { command line content }
  machine:       TTuring;                       { Turing machine configuration }
  messages:      array[0..4095] of char;     { messages from alanz80x.msg file }
  p0, p1, p2:    PByte;
  q:             boolean;                                         { allow exit }
  qb:            byte;                                    { breakpoint address }
  sl:            integer;                                 { program step limit }
  splitted:      array[0..7] of TSplitted;                  { splitted command }
  trace:         boolean;                                      { turn tracking }
const
  COMMARRSIZE =  14;
  COMMENT =      #59;
  COMMANDS:      array[0..COMMARRSIZE] of string[7] = (
                 'break', 'help', 'info',   'limit', 'load',
                 'prog',  'quit', 'reg',    'reset', 'restore',
                 'run',   'step', 'symbol', 'tape',  'trace');
  HEADER1 =      'AlanZ80X v0.1';
  HEADER2 =      '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com> EUPL v1.2';
  HINT =         'Type ''help [command]'' for more information.';
  MSGERR =       'Cannot load message file: ';
  MSGFILE =      'ALANZ80X.MSG';
  PROMPT =       'TM>';
  TPBLCOUNT =    5080;       { number of tuples = |(q0-q126)| * |S| = 127 * 40 }
  TPBLSIZE  =    3;                                { byte allocated by a tuple }

{ Meaning of the bits in the touple block:
 
 byte  bit  function| bit   byte  bit  function| bit   byte  bit  function  bit
 -------------------+--------------------------+-------------------------------
  1     7    tk/rk  |  3     2     7    sk     |  1     3     7    tm/rm     0
  1     6    tk/rk  |  2     2     6    tk     |  0     3     6    qm        6
  1     5    tk/rk  |  1     2     5    dj/dk  |  2     3     5    qm        5
  1     4    tk/rk  |  0     2     4    dj/dk  |  1     3     4    qm        4
  1     3    sk     |  5     2     3    dj/dk  |  0     3     3    qm        3
  1     2    sk     |  4     2     2    tm/rm  |  3     3     2    qm        2
  1     1    sk     |  3     2     1    tm/rm  |  2     3     0    qm        0
  1     0    sk     |  2     2     0    tm/rm  |  1     3     0    qm        0
}
