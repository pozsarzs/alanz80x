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
  { reset machine configuration }
  {with machine do
  begin
    progdesc := '';
    progname := '';
    progcount := 0;
    aqi := 1;
    for bi := 0 to 49 do
      for bj := 0 to 39 do
      begin
        rules[bi, bj].D := 'R';
        rules[bi, bj].qm := 1; 
        rules[bi, bj].Sj := #0; 
        rules[bi, bj].Sk := #0;
      end;
    states := 2;
    symbols := SPACE;
    tapepos := 1;
    tape := '';
    tapeposbak := tapepos;
    tapebak := tape;
    for bi := 1 to 255 do tape := tape + SPACE;
  end;}
  { reset t36 command buffer } 
  {for bi := 0 to 15 do t36com[bi] := '';}
  { reset program others }
  qb := 0;
  sl := 32767;
  machine.symbols:='_                                       ';
  if verbose then writemsg(42, true);
end;
