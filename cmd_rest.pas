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
begin
  { reset Turing machine base configuration }
  with machine do
  begin
    for bi := 0 to 7 do
    begin
      if bi = 0
        then registers[bi].data := '_'
        else registers[bi].data := '00000';
      if bi = 0
        then registers[bi].permission:= 0     { ACC - read/write }
        else registers[bi].permission:= 1;    { others - read only }
    end;
  end;
  { message }
  if verbose then writemsg(68, true);
end;
