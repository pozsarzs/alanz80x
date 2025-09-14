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
  bi:    byte;
  c:     string[1];
begin
  { reset flags }
  flag_echo := false;
  flag_intr := false;
  flag_it := 2;
  flag_runt36cmd := false;
  flag_qb := 127;
  flag_sl := MAXINT;
  flag_trace := false;
  { reset variables related to Turing machine }
  progdesc := '';
  progname := '';
  { reset recent tuple }
  with tprec do
  begin
    aqi := 0;
    atrj := flag_it;
    trk := 0;
    sj := ord(SYMBOLSET[1]);
    sk := ord(SYMBOLSET[1]);
    dj := 0;
    dk := 0;
    trm := 0;
    qm := 0;
  end;
  { reset Turing machine base configuration }
  with machine do
  begin
    symbols:= SYMBOLSET;
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
        0: tapes[bi].accessmode:= 255; { NN }
        1: tapes[bi].accessmode:= 0;   { LO }
        2: tapes[bi].accessmode:= 0;   { LO }
        3: tapes[bi].accessmode:= 1;   { LS }
        4: tapes[bi].accessmode:= 1;   { LS }
        5: tapes[bi].accessmode:= 1;   { LS }
      end;
      tapes[bi].position := 1;
    end;
    { registers }
    for bi := 0 to 9 do
    begin
      case bi of
           0: registers[bi].value := ord(SYMBOLSET[1]);
           6: registers[bi].value := 0;
        7..9: registers[bi].value := ord(SYMBOLSET[1]);
      else
        registers[bi].value := tapes[bi].position;
      end;
      if (bi = 0) or (bi = 7)
        then registers[bi].permission:= 1  { RW }
        else registers[bi].permission:= 0; { RO }
      registers[bi].position := 1;
    end; 
    syncregs;
    { tuple memory }
    fillchar(tuples^, TPBLCOUNT * TPBLSIZE, 0);
    { t36 command buffer }
    for bi := 0 to 15 do t36com[bi] := '';
  end;
  { message }
  if verbose then writemsg(52, true);
end;
