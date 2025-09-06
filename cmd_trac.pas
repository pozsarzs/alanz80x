{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_trac.pas                                                             | }
{ | Command 'trace'                                                          | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'trace' }
overlay procedure cmd_trace(p1: TSplitted);
var
  err: byte;                                                      { error code }
begin
  err := 0;
  { check parameters and set value }
  if length(p1) = 0 then flag_trace := not flag_trace else
    if upcase(p1[1]) + upcase(p1[2])  = 'ON' then flag_trace := true else
      if upcase(p1[1]) + upcase(p1[2]) + upcase(p1[3]) = 'OFF'
        then flag_trace := false
        else err := 34;
  { messages }
  if err > 0 then writemsg(err, true) else
    if flag_trace then writemsg(56, true) else writemsg(57, true);
end;
