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
  bi, bj:     byte;
  p0, p1, p2: PByte;
const
  directions: array[0..2] of char= ('L','S','R');
begin
  if length(machine.progname) <> 0 then writemsg(36, true) else
  begin
    writemsg(66, true);
    for bi := 0 to STCOUNT - 1 do
    begin
      for bj := 0 to SYMCOUNT - 1 do
      begin
        { read from memory }
        p0 := ai2tpaddr(bi, bj, 0);
        p1 := ai2tpaddr(bi, bj, 1);
        p2 := ai2tpaddr(bi, bj, 2);
        { decode }
        if tpblunpack(p0^, p1^, p2^) then 
        begin
          { write to screen}
            with tprec do
            begin
              write(addzero(bi, true));
              if trj <= 5
                then write('T', addzero(trj, false))
                else write('R', addzero(trj - 6, false));
              if trk <= 5
                then write('T', addzero(trk, false))
                else write('R', addzero(trk - 6, false));
              write(machine.symbols[bj + 1]);
              write(machine.symbols[sk + 1]);
              write(directions[dj]);
              write(directions[dk]);
              if trm <= 5
                then write('T', addzero(trm, false))
                else write('R', addzero(trm - 6, false));
              write(addzero(qm, true),' ');
            end;
        end else writemsg(84, false);
      end;
      writeln;
    end;
  end;
end;
