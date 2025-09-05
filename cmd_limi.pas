{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_limi.pas                                                             | }
{ | Command 'limit'                                                          | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'limit' }
{overlay} procedure cmd_limit(p1: TSplitted);
var
  err:    byte;                                                   { error code }
  ip1:    integer;                                        { function parameter }
const
  P1MIN = 1;                                               { valid range of p1 }
  P1MAX = 32766;
begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get step limit }
    if flag_sl = P1MAX + 1 then writemsg(84, true) else
    begin
      writemsg(85, false);
      writeln(flag_sl, '.');
    end;
  end else
  begin
    if p1 = '-' then
    begin
      { reset step limit }
      flag_sl := P1MAX + 1;
      writemsg(86, true)
    end else
    begin
      { set step limit }
      if parcomp(p1, ip1, err, P1MIN, P1MAX) then
      begin
        flag_sl := ip1;
        writemsg(87, false);
        writeln(flag_sl, '.');
      end
    end;
  end;
  { error message }
  if err > 0 then writemsg(err, true);
end;
