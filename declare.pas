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
  TTPRecently =  record                                  { recently read tuple }
    qi:          byte;                                          { actual state }
    trj:         byte;{ tape or register from which the machine reads a symbol }
    trk:         byte; { tape or register to which the machine writes a symbol }
    sj:          byte;              { actual symbol read from the data carrier }
    sk:          byte;              { symbol to be written to the data carrier }
    dj:          byte;     { head moving direction over the input data carrier }
    dk:          byte;    { head moving direction over the result data carrier }
    trm:         byte;    { next tape or register from which the machine reads }
    qm:          byte;                                            { next state }
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
  qb:            byte;                                      { breakpoint state }
  sl:            integer;                                 { program step limit }
  splitted:      array[0..7] of TSplitted;                  { splitted command }
  t36com:        array[0..15] of TCommand;           { t36 file command buffer }
  tprec:         TTPRecently;                            { recently read tuple }
  trace:         boolean;                                      { turn tracking }
const
  COMMARRSIZE =  14;
  COMMENT =      #59;
  COMMANDS:      array[0..COMMARRSIZE] of string[7] = (
                 'break', 'help', 'info',   'limit', 'load',
                 'prog',  'quit', 'reg',    'reset', 'restore',
                 'run',   'step', 'symbol', 'tape',  'trace');
  DC:            string[2] = 'TR';
  HEADER1 =      'AlanZ80X v0.1';
  HEADER2 =      '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com> EUPL v1.2';
  HINT =         'Type ''help [command]'' for more information.';
  HMD:           string[3] = 'LSR';                   { head moving directions }
  MSGERR =       'Cannot load message file: ';
  MSGFILE =      'ALANZ80X.MSG';
  PROMPT =       'TM>';
  SPACE =        #95;
  STCOUNT =      127;                               { maximal number of states }
  SYMCOUNT =     40;                             { maximal number of symbolums }
  TPBLCOUNT =    5080;                         { maximal number of tuple block }
  TPBLSIZE  =    3;                                { byte allocated by a tuple }
  
