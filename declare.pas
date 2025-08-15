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
  TCommand =    string[255];
  TFilename=    string[12];
  TSplitted =   string[64];
  TThreeDigit = string[3];
var
  bi: byte;
  command:      TCommand;                               { command line content }
  messages:     array[0..4095] of char;      { messages from alanz80x.msg file }
  tuples:       array[0..15240] of byte;                      { chained tuples }
  q:            boolean;                                          { allow exit }
  qb:           byte;                                     { breakpoint address }
  sl:           integer;                                  { program step limit }
  splitted:     array[0..7] of TSplitted;                   { splitted command }
  trace:        boolean;                                       { turn tracking }
const
  COMMARRSIZE = 14;
  COMMENT =     #59;
  COMMANDS:     array[0..COMMARRSIZE] of string[7] = ('break', 'help', 'info',
                'limit', 'load', 'prog', 'quit', 'reset', 'restore', 'run',
                'state', 'step', 'symbol', 'tape', 'trace');
  HEADER1 =     'AlanZ80X v0.1';
  HEADER2 =     '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com> EUPL v1.2';
  HINT =        'Type ''help [command]'' for more information.';
  MSGERR =      'Cannot load message file: ';
  MSGFILE =     'alanz80x.msg';
  PROMPT =      'TM>';

{
szalagazonosító: tk: 4 bit (0-13)
kiírandó szimbólum sk: 6 bit (0-39)
fejmozgás dj+dk: 3 bit (0-7) - SS nélkül
következő be szalag tm: 4 bit (0-13)
következő állapot: qm:  7 bit (0-127)
Csak q=0..126-ig tárolunk tuple-t, a végsőhöz már nem, mert ott megáll.
Helyfoglalás: 24 b * 127 * 40 = 15240 byte
}
