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
overlay procedure cmd_prog(p1, p2: TSplitted);
var
  bi, bj:        byte;
  ip1, ip2:      integer;                                { function parameters }
  ec:            integer;
  po0, po1, po2: PByte;
  err: byte;                                                      { error code }
const
  datacarriers:  string[3] = 'TR';
  directions:    string[3] = 'LSR';
begin
  err := 0;
  { check parameters }
  if length(p2) > 0 then
  begin
    val(p2, ip2, ec);
    if ec <> 0 then err := 24;
  end else ip2 := STCOUNT - 1;
  if (ip2 < 0) or (ip2 > 126) then err := 24;
  if length(p1) > 0 then
  begin
    val(p1, ip1, ec);
    if ec <> 0 then err := 24;
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
        for bj := 0 to SYMCOUNT - 1 do
        begin
          { read from memory }
          po0 := ai2tpaddr(bi, bj, 0);
          po1 := ai2tpaddr(bi, bj, 1);
          po2 := ai2tpaddr(bi, bj, 2);
          { decode }
          if tpblunpack(po0^, po1^, po2^) then
          begin
            { write to screen}
{            if machine.symbols[tprec.sj + 1] <> #0 then }
              with tprec do
              begin
                write(addzero(bi, true));
                if trj <= 5
                  then write(datacarriers[1], addzero(trj, false))
                  else write(datacarriers[2], addzero(trj - 6, false));
                if trk <= 5
                  then write(datacarriers[1], addzero(trk, false))
                  else write(datacarriers[2], addzero(trk - 6, false));
                write(machine.symbols[sj + 1]);
                write(machine.symbols[sk + 1]);
                write(directions[dj + 1]);
                write(directions[dk + 1]);
                if trm <= 5
                  then write(datacarriers[1], addzero(trm, false))
                  else write(datacarriers[2], addzero(trm - 6, false));
                write(addzero(qm, true),' ');
              end;
          end else writemsg(84, false);
        end;
        writeln;
      end;
    end;
  end else
    { error message }
    writemsg(err, true);
end;
