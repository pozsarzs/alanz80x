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
  TRegStr =      string[5];
  { TYPES RELATED TO TURING MACHINES }
  TTapes =       record
    filename:    TFilename;
    permission:  byte;
  end;
  TRegisters =   record                                            { registers }
    data:        TRegStr;
    permission:  byte;
  end;
  TTPRecently =  record                                  { recently read tuple }
    aqi:         byte;                                          { actual state }
    atrj:        byte;                             { actual input data carrier }
    trk:         byte; { tape or register to which the machine writes a symbol }
    sj:          byte;              { actual symbol read from the data carrier }
    sk:          byte;              { symbol to be written to the data carrier }
    dj:          byte;     { head moving direction over the input data carrier }
    dk:          byte;    { head moving direction over the result data carrier }
    trm:         byte;    { next tape or register from which the machine reads }
    qm:          byte;                                            { next state }
  end;
  { TURING MACHINE BASE CONFIGURATION TYPE }
  TTuring =      record                         { Turing machine configuration }
    progdesc:    string[64];                          { description of program }
    progname:    string[8];                                  { name of program }
    registers:   array[0..7] of TRegisters;                { register settings }
    symbols:     string[40];                                    { symbolum set }
    tapes:       array[0..5] of TTapes;                        { file settings }
    tuples:      PByte;                              { pointer to tuple memory }
    t36com:      array[0..15] of TCommand;           { t36 file command buffer }
  end;
var
  bi: byte;
  command:       TCommand;                              { command line content }
  comline:       byte;                  { number of line in t36 command buffer }
  machine:       TTuring;                  { Turing machine base configuration }
  messages:      array[0..4095] of char;     { messages from alanz80x.msg file }
  q:             boolean;                                         { allow exit }
  qb:            byte;                                      { breakpoint state }
  runt36com:     boolean;
  sl:            integer;                                 { program step limit }
  splitted:      array[0..7] of TSplitted;                  { splitted command }
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
  EXT:           string[5] = 'DPRST';
  HEADER1 =      'AlanZ80X v0.1';
  HEADER2 =      '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com> EUPL v1.2';
  HINT =         'Type ''help [command]'' for more information.';
  HMD:           string[3] = 'LSR';                   { head moving directions }
  MSGERR =       'Cannot load message file: ';
  MSGFILE =      'ALANZ80X.MSG';
  PRM:           string[3]= 'RWO';
  PROMPT =       'TM>';
  SPACE =        #95;
  STCOUNT =      127;                               { maximal number of states }
  SYMCOUNT =     40;                             { maximal number of symbolums }
  TPBLCOUNT =    5080;                         { maximal number of tuple block }
  TPBLSIZE  =    3;                                { byte allocated by a tuple }
  
