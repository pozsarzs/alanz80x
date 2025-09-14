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
  bi:     byte;
  err:    byte;                                                   { error code }
  ip1:    integer;                                        { function parameter }
const
  P1MIN = 0;                                               { valid range of p1 }
  P1MAX = 9;

  { WRITE SELECTED REGISTER CONTENT AND PERMISSION }
  procedure writeregrec(n: byte);
  begin
    case n of
         7: writemsg(39, false);
      8..9: writemsg(n + 115, false);
    else
      writemsg(n + 97, false);
    end;
    write('   ');
    case machine.registers[n].permission of
      0: write(PRM[1]+PRM[3]);
      1: write(PRM[1]+PRM[2]);
      2: write(PRM[2]+PRM[3]);
    end;
    write('    ', machine.registers[n].value:5, '  ');
    write(machine.registers[n].data:6);
    write('     ');
    writeln(machine.registers[n].position:3);
  end;

begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { show all }
    writemsg(96, true);
    writemsg(92, true);
    for bi := P1MIN to P1MAX do writeregrec(bi);
  end else
  begin
    { show selected }
    if parcomp(p1, ip1, err, P1MIN, P1MAX) then
    begin
      writemsg(96, true);
      writemsg(92, true);
      writeregrec(ip1);
    end;
  end;
  { error message }
  if err > 0 then writemsg(err, true);
end;
