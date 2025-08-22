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
begin
  { reset Turing machine base configuration }
  with machine do
  begin
    progdesc := '';
    progname := '';
    for bi := 0 to 5 do
    begin
      files[bi].filename := '';
      case bi of
        0: files[bi].permission:= 2; { console - write only }
        1: files[bi].permission:= 0; { data - read only }
        2: files[bi].permission:= 0; { program - read only }
      else
        files[bi].permission:= 1;    { others - read/write }
      end;
    end;
    for bi := 0 to 7 do
    begin
      if bi = 0
        then registers[bi].data := '_    '
        else registers[bi].data := '00000';
      if bi = 0
        then registers[bi].permission:= 1     { ACC - read/write }
        else registers[bi].permission:= 0;    { others - read only }
    end;
    states := 0;
    symbols:= '_';
    for bi := 1 to 39 do symbols := symbols + #0;
    for bi := 0 to 15 do t36com[bi] := '';
    fillchar(tuples^, TPBLCOUNT * TPBLSIZE, 0);
  end;
  { reset variables related to turing machines }
  qb := 0;
  sl := 32767;
  { message }
  if verbose then writemsg(42, true);
end;
