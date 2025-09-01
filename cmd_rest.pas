{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_rest.pas                                                             | }
{ | Command 'restore'                                                        | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'restore' }
overlay procedure cmd_restore(verbose: boolean);
var
  bi, bj: byte;
  blank:  char;
begin
  { reset Turing machine base configuration }
  with machine do
  begin
    blank := SYMBOLSET[1];
    for bi := 0 to 6 do
      if bi = 0
        then setreg(bi, ord(blank))
        else setreg(bi, 0);
    tprec.aqi := 0;
    tprec.atrj := it;
  end;
  { message }
  if verbose then writemsg(78, true);
end;
