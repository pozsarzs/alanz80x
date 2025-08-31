{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_echo.pas                                                             | }
{ | Command 'echo'                                                           | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'echo' }
overlay procedure cmd_echo(p1: TSplitted);
var
  err: byte;                                                      { error code }
begin
  err := 0;
  { check parameters and set value }
  if length(p1) = 0 then echo := not echo else
    if upcase(p1[1]) + upcase(p1[2])  = 'ON' then echo := true else
      if upcase(p1[1]) + upcase(p1[2]) + upcase(p1[3]) = 'OFF'
        then echo := false
        else err := 34;
  { messages }
  if err > 0 then writemsg(err, true) else
    if echo then writemsg(114, true) else writemsg(115, true);
end;
