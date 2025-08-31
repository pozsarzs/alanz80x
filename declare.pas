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
  PByte =        ^byte;
  TCommand =     string[255];
  TFilename =    string[12];
  TSplitted =    string[64];
  TThreeDigit =  string[3];
  { TYPES RELATED TO TURING MACHINES }
  TTapes =       record                                            { TAPE TYPE }
    data:        string[255];                                   { tape content }
    filename:    TFilename;                              { file or device name }
    permission:  byte;                                       { file permission }
  end;
  TRegisters =   record                                        { REGISTER TYPE }
    data:        string[5];                                 { register content }
    permission:  byte;                                   { register permission }
  end;
  TTPRecently =  record                                           { TUPLE TYPE }
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
  TTuring =      record                                  { TURING MACHINE TYPE }
    registers:   array[0..6] of TRegisters;                    { registers set }
    symbols:     string[40];                                    { symbolum set }
    tapes:       array[0..5] of TTapes;                             { tape set }
    tuples:      PByte;                                          { state table }
  end;
var
  bi: byte;
  comline:       byte;                  { number of line in t36 command buffer }
  command:       TCommand;                              { command line content }
  machine:       TTuring;                  { Turing machine base configuration }
  messages:      array[0..4095] of char;     { messages from alanz80x.msg file }
  progdesc:      string[64];                          { description of program }
  progname:      string[8];                                  { name of program }
  qb:            byte;                                      { breakpoint state }
  it:            byte;                                          { initial tape }
  q:             boolean;                                         { allow exit }
  runt36com:     boolean;
  sl:            integer;                                 { program step limit }
  splitted:      array[0..7] of TSplitted;                  { splitted command }
  t36com:        array[0..15] of TCommand;           { t36 file command buffer }
  tprec:         TTPRecently;                            { recently read tuple }
  trace:         boolean;                                           { tracking }
  intr:          boolean;                        { interrupt request detecting }
  echo:          boolean;                   { tape echo to standard out device }
const
  COMMARRSIZE =  16;
  COMMENT =      #59;
  COMMANDS:      array[0..COMMARRSIZE] of string[7] = (
                 'break', 'echo',    'help', 'info', 'intr',
                 'limit', 'load',    'prog', 'quit', 'reg',
                 'reset', 'restore', 'run',  'step', 'symbol',
                 'tape',  'trace');
  DC:            string[2] = 'TR';
  HEADER1 =      'AlanZ80X v0.1';
  HEADER2 =      '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com> EUPL v1.2';
  HINT =         'Type ''help [command]'' for more information.';
  HMD:           string[3] = 'LSR';
  MSGERR =       'Cannot load message file: ';
  MSGFILE =      'ALANZ80X.MSG';
  PRM:           string[3]= 'RWO';
  PROMPT =       'TM>';
  SYMBOLSET:     string[40] = '_#ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-';
  STCOUNT =      127;                               { maximal number of states }
  SYMCOUNT =     40;                             { maximal number of symbolums }
  TPBLCOUNT =    5080;                         { maximal number of tuple block }
  TPBLSIZE  =    3;                                { byte allocated by a tuple }
  
