{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_brea.pas                                                             | }
{ | Command 'break'                                                          | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'break' }
{overlay} procedure cmd_break(p1: TSplitted);
var
  err:    byte;                                                   { error code }
  ip1:    integer;                                        { function parameter }
const
  P1MIN = 1;                                               { valid range of p1 }
  P1MAX = 126;
begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get breakpoint address }
    if flag_qb = 127 then writemsg(35, true) else
    begin
      writemsg(36, false);
      writeln(addzero(flag_qb, 3), '.');
    end;
  end else
  begin
    if p1 = '-' then
    begin
      { reset breakpoint }
      flag_qb := 127;
      writemsg(37, true);
    end else
    begin
      { set breakpoint address }
      if parcomp(p1, ip1, err, P1MIN, P1MAX) then
      begin
        flag_qb := ip1;
        writemsg(38, false);
        writeln(addzero(flag_qb, 3), '.');
      end;
    end;
  end;
  { error message }
  if err > 0 then writemsg(err, true);
end;
