{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_rese.pas                                                             | }
{ | Command 'reset'                                                          | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'reset' }
procedure cmd_reset(verbose: boolean);
var
  bi, bj: byte;
  blank:  char;     
  c:      string[1];
begin
  { reset variables related to turing machines }
  echo := false;
  intr := false;
  it := 2;
  progdesc := '';
  progname := '';
  qb := 0;
  runt36com := false;
  sl := 32767;
  trace := false;
  { reset Turing machine base configuration }
  with machine do
  begin
    symbols:= '_#ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-';
    tprec.aqi := 0;
    tprec.atrj := it;
    { tapes }
    for bi := 0 to 5 do
    begin
      str(bi, c);
      case bi of
        0: tapes[bi].filename := 'CON:';
        1: tapes[bi].filename := 'PROGRAM.TAP';
        2: tapes[bi].filename := 'DATA.TAP';
        3: tapes[bi].filename := 'RESULT.TAP';
        4: tapes[bi].filename := 'TEMP.TAP';
        5: tapes[bi].filename := 'STACK.TAP';
      end;
      case bi of
        0: tapes[bi].permission:= 2; { WO }
        1: tapes[bi].permission:= 0; { RO }
        2: tapes[bi].permission:= 0; { RO }
        3: tapes[bi].permission:= 1; { RW }
        4: tapes[bi].permission:= 1; { RW }
        5: tapes[bi].permission:= 1; { RW }
      end;
    end;
    { registers }
    blank := SYMBOLSET[1];
    for bi := 0 to 6 do
    begin
      if bi = 0
        then setreg(bi, ord(blank))
        else setreg(bi, 0);
      if bi = 0
        then registers[bi].permission:= 1  { RW }
        else registers[bi].permission:= 0; { RO }
    end;
    { tuple memory }
    fillchar(tuples^, TPBLCOUNT * TPBLSIZE, 0);
    { t36 command buffer }
    for bi := 0 to 15 do t36com[bi] := '';
  end;
  { message }
  if verbose then writemsg(52, true);
end;
