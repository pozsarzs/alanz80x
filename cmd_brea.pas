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
procedure cmd_break(p1: TSplitted);
var
  err: byte;                                                      { error code }
  ec:  integer;
  ip1: integer;                                           { function parameter }
begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get breakpoint address }
    if qb = 0 then writemsg(25, true) else
    begin
      writemsg(26, false);
      writeln(addzero(qb, true), '.');
    end;
  end else
  begin
    if p1 = '-' then
    begin
      { reset breakpoint }
      qb := 0;
      writemsg(27, true);
    end else
    begin
      { set breakpoint address }
      val(p1, ip1, ec);
      if ec <> 0 then err := 23 else
        if (ip1 < 0) or (ip1 > 255) then err := 24 else
        begin
          qb := ip1;
          writemsg(28, false);
          writeln(addzero(qb, true), '.');
        end;
    end;
  end;
  { error message }
  if err > 0 then writemsg(err, true);
end;
