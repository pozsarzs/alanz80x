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
    fillchar(tuples^, TPBLCOUNT * TPBLSIZE, 0);
    symbols:='_';
    for bi := 1 to 39 do symbols := symbols + #0;
    progdesc := '';
    progname := '';
  end;
  { reset variables related to turing machines }
  qb := 0;
  sl := 32767;
  for bi := 0 to 15 do t36com[bi] := '';
  { message }
  if verbose then writemsg(42, true);
end;
