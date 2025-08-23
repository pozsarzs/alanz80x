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
procedure cmd_prog(p1, p2: TSplitted);
var
  bi, bj:        byte;
  ip1, ip2:      integer;                                { function parameters }
  ec:            integer;
  err: byte;                                                      { error code }
begin
  err := 0;
  { check parameters }
  if length(p2) > 0 then
  begin
    val(p2, ip2, ec);
    if ec <> 0 then err := 23;
  end else ip2 := STCOUNT - 1;
  if (ip2 < 0) or (ip2 > 126) then err := 24;
  if length(p1) > 0 then
  begin
    val(p1, ip1, ec);
    if ec <> 0 then err := 23;
  end else ip1 := 0;
  if (ip1 < 0) or (ip1 > 126) then err := 24;
  if err = 0 then
  begin
    if length(machine.progname) <> 0 then err := 36 else
{    if length(machine.progname) = 0 then err := 36 else }
    begin
      if ip1 > ip2 then
      begin
        ec := ip2;
        ip2 := ip1;
        ip1 := ec;
      end;
      writemsg(66, true);
      for bi := ip1 to ip2 do
      begin
        write(addzero(bi, true), ': ');                                   { qi }
        for bj := 0 to SYMCOUNT - 1 do
        begin
          { read from memory and decode }
          tpblunpack(bi, bj);
          { write to screen}
{            if machine.symbols[tprec.sj + 1] <> #0 then }
          with tprec do
          begin
            if trk <= 5                                                  { trk }
              then write(DC[1], trk)
              else write(DC[2], trk - 6);
            write(machine.symbols[sj + 1]);                               { sj }
            write(machine.symbols[sk + 1]);                               { sk }
            write(HMD[dj + 1]);                                           { dj }
            write(HMD[dk + 1]);                                           { dk }
            if trm <= 5                                                  { trm }
              then write(DC[1], trm)
              else write(DC[2], trm - 6);
            write(addzero(qm, true),' ');                                 { qm }
          end;
        end;
        writeln;
      end;
    end;
  end else
    { error message }
    writemsg(err, true);
end;
