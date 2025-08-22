{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_reg.pas                                                              | }
{ | Command 'reg'                                                            | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'reg' }
procedure cmd_reg(p1: TSplitted);
var
  bi:  byte;
  ec:  integer;
  err: byte;                                                      { error code }
  ip1: integer;                                           { function parameter }

  { write selected register content }
  procedure writeregcontent(n: byte);
  begin
    writemsg(n + 86, false);
    write(machine.registers[n].data, '  (');
    case machine.registers[n].permission of
      0: write(PRM[1]+PRM[3]);
      1: write(PRM[1]+PRM[2]);
      2: write(PRM[2]+PRM[3]);
    end;
    writeln(')');
  end;

begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { show all }
    writemsg(85, true);
    for bi := 0 to 7 do writeregcontent(bi);
  end else
  begin
    { show selected }
    val(p1, ip1, ec);
    if ec <> 0 then err := 23 else
      if (ip1 < 0) or (ip1 > 7) then err := 24 else
      begin
        writemsg(85, true);
        writeregcontent(ip1);
      end;
  end;
  { error message }
  if err > 0 then writemsg(err, true);
end;
