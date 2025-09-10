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
  PByte =           ^byte;
  TCommand =        string[255];
  TFilename =       string[12];
  TFiveDigit =      string[5];
  TRegContent =     string[6];
  TSplitted =       string[64];
  TThreeDigit =     string[3];
  { TYPES RELATED TO TURING MACHINES }
  TMachineContext = record                              { MACHINE CONTEXT TYPE }
    sqm:          byte;                                     { saved next state }
    strm:         byte;              { saved next input tape or register number}
    sr:           array[0..5] of integer;                    { saved registers }
  end;
  TRegisters =    record                                       { REGISTER TYPE }
    data:         TRegContent;                    { register content in string }
    permission:   byte;                                  { register permission }
    position:     byte;                                        { head position }
    value:        integer;                                    { register value }
  end;
  TTapes =        record                                           { TAPE TYPE }
    accessmode:   byte;                                      { file permission }
    data:         string[255];                                  { tape content }
    filename:     TFilename;                             { file or device name }
    position:     byte;                                        { head position }
  end;
  TTPRecently =   record                                          { TUPLE TYPE }
    aqi:          byte;                                         { actual state }
    atrj:         byte;                            { actual input data carrier }
    trk:          byte;            { tape or register to which writes a symbol }
    sj:           byte;             { actual symbol read from the data carrier }
    sk:           byte;             { symbol to be written to the data carrier }
    dj:           byte;    { head moving direction over the input data carrier }
    dk:           byte;   { head moving direction over the result data carrier }
    trm:          byte;   { next tape or register from which the machine reads }
    qm:           byte;                                           { next state }
  end;
  { TURING MACHINE BASE CONFIGURATION TYPE }
  TTuring =       record                                 { TURING MACHINE TYPE }
    registers:    array[0..7] of TRegisters;                   { registers set }
    savedcontext: TMachineContext;    { saved machine context for IRQ handling }
    symbols:      string[40];                                   { symbolum set }
    tapes:        array[0..5] of TTapes;                            { tape set }
    tuples:       PByte;                                         { state table }
  end;
var
  bi:             byte;
  comline:        byte;                 { number of line in t36 command buffer }
  command:        TCommand;                             { command line content }
  flag_echo:      boolean;                  { tape echo to standard out device }
  flag_intr:      boolean;                       { interrupt request detecting }
  flag_runmode:   boolean;                  { run mode (0/1: normal/interrupt) }
  flag_it:        byte;                                         { initial tape }
  flag_runt36cmd: boolean;                    { run commands from the t36 file }
  flag_qb:        byte;                                     { breakpoint state }
  flag_sl:        integer;                                { program step limit }
  flag_trace:     boolean;                                          { tracking }
  machine:        TTuring;                 { Turing machine base configuration }
  messages:       array[0..4095] of char;    { messages from alanz80x.msg file }
  progdesc:       string[64];                         { description of program }
  progname:       string[8];                                 { name of program }
  q:              boolean;                                        { allow exit }
  splitted:       array[0..7] of TSplitted;                 { splitted command }
  t36com:         array[0..15] of TCommand;          { t36 file command buffer }
  tprec:          TTPRecently;                           { recently read tuple }
const
  AM:             string[3] = 'LSO';
  COMMARRSIZE =   16;
  COMMENT =       #59;
  COMMANDS:       array[0..COMMARRSIZE] of string[7] = (
                  'break', 'echo',    'help', 'info', 'intr',
                  'limit', 'load',    'prog', 'quit', 'reg',
                  'reset', 'restore', 'run',  'step', 'symbol',
                  'tape',  'trace');
  DC:             string[2] = 'TR';
  HEADER1 =       'AlanZ80X v0.1';
  HEADER2 =       '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com> EUPL v1.2';
  HINT =          'Type ''help [command]'' for more information.';
  HMD:            string[3] = 'LSR';
  MSGERR =        'Cannot load message file: ';
  MSGFILE =       'alanz80x.msg';
  PRM:            string[3] = 'RWO';
  PROMPT =        'TM>';
  SYMBOLSET:      string[40] = '_#ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-';
  STCOUNT =       127;                              { maximal number of states }
  SYMCOUNT =      40;                            { maximal number of symbolums }
  TPBLCOUNT =     5080;                        { maximal number of tuple block }
  TPBLSIZE  =     3;                               { byte allocated by a tuple }
  TAPELENGTH =    255;                             { length of the tapes t1-t6 } 
    
