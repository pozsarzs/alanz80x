{ +--------------------------------------------------------------------------+ }
{ | AlanZ80 v0.1 * Turing machine                                            | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_prog.pas                                                             | }
{ | 'PROG' command                                                           | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'prog' }
overlay procedure cmd_prog;
var
 qi, r: byte;
begin
{  if length(machine.progname) = 0 then writeln(36, true) else
  begin
    writemsg(66, true);
    for qi := 0 to 126 do
    begin
      for r := 0 to 39 do
        if machine.rules[qi, r].sj <> #0
        then
          write(addzero(qi), machine.rules[qi, r].sj, machine.rules[qi, r].sk,
                machine.rules[qi, r].d, addzero(machine.rules[qi, r].qm), ' ');
        if machine.rules[qi, 0].sj <> #0 then writeln;
    end;
  end;}
end;

{
  p0 := addrcalc(5, 0);
  p1 := addrcalc(5, 1);
  p2 := addrcalc(5, 2);

  p0^ := 44;
  p1^ := 55;
  p2^ := 66;

 writeln(p0^, ' ', p1^, ' ', p2^);


  byte  bit  function  bit
  ------------------------
  1     7    tk/rk     3
  1     6    tk/rk     2
  1     5    tk/rk     1
  1     4    tk/rk     0
  1     3    sk        5
  1     2    sk        4
  1     1    sk        3
  1     0    sk        2
  2     7    sk        1
  2     6    tk        0
  2     5    dj/dk     2
  2     4    dj/dk     1
  2     3    dj/dk     0
  2     2    tm/rm     3
  2     1    tm/rm     2
  2     0    tm/rm     1
  3     7    tm/rm     0
  3     6    qm        6
  3     5    qm        5
  3     4    qm        4
  3     3    qm        3
  3     2    qm        2
  3     1    qm        1
  3     0    qm        0
 }
