{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
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
overlay procedure cmd_prog(p1, p2: TSplitted);
var
  bi, bj:   byte;
  ip1, ip2: integer;                                     { function parameters }
  ec:       integer;
  err:      byte;                                                 { error code }
const
  P12MIN =  0;                                             { valid range of p1 }
  P12MAX =  126;
begin
  err := 0;
  { check parameters }
  if length(p1) > 0 then
  begin
    if parcomp(p1, ip1, err, P12MIN, P12MAX) then;
  end else ip1 := 0;
  if length(p2) > 0 then
  begin
    if parcomp(p2, ip2, err, P12MIN, P12MAX) then;
  end else ip2 := ip1;
  if err = 0 then
  begin
    if length(progname) = 0 then err := 46 else
    begin
      if ip1 > ip2 then
      begin
        ec := ip2;
        ip2 := ip1;
        ip1 := ec;
      end;
      writemsg(76, true);
      for bi := ip1 to ip2 do
      begin
        write(addzero(bi, 3), ': ');                                      { qi }
        for bj := 0 to SYMCOUNT - 1 do
        begin
          { read from memory and decode }
          tpblunpack(bi, bj);
          { write to screen}
          if length(machine.symbols) > bj then
          with tprec do
          begin
            if trk > 5                                                   { trk }
              then write(DC[2], trk - 6)
              else write(DC[1], trk);
            if sj > 0                                                     { sj }
              then write(machine.symbols[sj])
              else write(' ');
            if sk > 0                                                     { sk }
              then write(machine.symbols[sk])
              else write(' ');
            write(HMD[dj + 1]);                                           { dj }
            write(HMD[dk + 1]);                                           { dk }
            if trm > 5                                                   { trm }
              then write(DC[2], trm - 6)
              else write(DC[1], trm);
            write(addzero(qm, 3),' ');                                    { qm }
          end;
        end;
        writeln;
      end;
    end;
  end;
  { error message }
  if err > 0 then writemsg(err, true);
end;
