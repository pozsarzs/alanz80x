{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_symb.pas                                                             | }
{ | Command 'symbol'                                                         | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'symbol' }
overlay procedure cmd_symbol(p1: TSplitted);
var
  c:      char;
  bi, bj: byte;
  err:    byte;                                                   { error code }
  s:      string[40];
label
  break1;
begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get symbol list }
    writemsg(31, false);
    writeln(machine.symbols);
  end else
  begin
    if p1 = '-' then
    begin
      { reset symbol list }
      machine.symbols := SPACE;
      writemsg(32, true)
    end else
    begin
      { set symbol list }
      s := p1;
      { - convert to uppercase and truncate to 40 }
      for bi := 1 to length(p1) do s[bi] := upcase(s[bi]);
      { - remove extra characters }
      for bi := 1 to length(s) - 1 do
        for bj := 1 to length(s) - 1 do
          if s[bj] > s[bj + 1] then
          begin
            c := s[bj];
            s[bj] := s[bj + 1];
            s[bj + 1] := c;
          end;
      for bi := 1 to 40 do
      begin
        if bi = length(s) then goto break1;
        if s[bi] = s[bi + 1] then
        begin
         delete(s, bi, 1);
         err := 34;
        end;
      end;
    break1:
      machine.symbols := SPACE + s;
      { warning messages }
      if length(p1) > 40 then writemsg(35, true);
      if err > 0 then writemsg(err, true);
      { messages }
      writemsg(33, false);
      writeln(machine.symbols, '''.');
    end;
  end;
end;
