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
overlay procedure cmd_limit(p1: TSplitted);
var
  err: byte;                                                      { error code }
  ec:  integer;
  ip1: integer;                                           { function parameter }
const
  max= 32767;
begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get step limit }
    if sl = max then writemsg(74, true) else
    begin
      writemsg(75, false);
      writeln(sl, '.');
    end;
  end else
  begin
    if p1 = '-' then
    begin
      { reset step limit }
      sl := max;
      writemsg(76, true)
    end else
    begin
      { set step limit }
      val(p1, ip1, ec);
      if ec <> 0 then err := 24 else
        if ((ip1 < 0) or (ip1 > max)) then err := 23 else
        begin
          sl := ip1;
          writemsg(77, false);
          writeln(sl, '.');
        end
    end;
  end;
  { error message }
  if err > 0 then writemsg(err, true);
end;
