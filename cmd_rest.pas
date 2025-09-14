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
  bi: byte;
begin
  { reset Turing machine base configuration }
  with machine do
  begin
    { tapes }
    for bi := 0 to 5 do
      tapes[bi].position := 1;
    { registers }
    for bi := 0 to 9 do
     case bi of
           0: registers[bi].value := ord(SYMBOLSET[1]);
           6: registers[bi].value := 0;
        7..9: registers[bi].value := ord(SYMBOLSET[1]);
     else
       registers[bi].value := tapes[bi].position;
     end;
    for bi := 0 to 7 do
      if (bi = 0) or (bi = 7)
        then registers[bi].permission:= 1  { RW }
        else registers[bi].permission:= 0; { RO }
    syncregs;
  end;
  { reset recent tuple }
  with tprec do
  begin
    aqi := 0;
    atrj := flag_it;
  end;
  { message }
  if verbose then writemsg(78, true);
end;
