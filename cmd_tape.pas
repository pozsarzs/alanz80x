{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_tape.pas                                                             | }
{ | Command 'tape'                                                           | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'tape' }
procedure cmd_tape(p1, p2: TSplitted);
var
  bi:     byte;
  dn:     string[3];
  err:    byte;                                                   { error code }
  fn:     string[8];
  ip1:    integer;                                        { function parameter }
const
  P1MIN = 0;                                               { valid range of p1 }
  P1MAX = 5;

  { WRITE TAPE FILE NAME AND ACCESS MODE }
  procedure writetaperec(n: byte);
  begin
    if flag_it = n
      then write(' *    ')
      else write('      ');
    writemsg(n + 104, false);
    write(machine.tapes[n].filename:12, '    ');
    case machine.tapes[n].accessmode of
      0: write(AM[1] + AM[3]); { load only }
      1: write(AM[1] + AM[2]); { load and save }
      2: write(AM[2] + AM[3]); { save only }
    else
      write('NN'); { none }
    end;
    write('      ');
    writeln(machine.tapes[n].position:3);
  end;

begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { show all }
    writemsg(50, true);
    writemsg(91, true);
    for bi := P1MIN to P1MAX do writetaperec(bi);
  end else
  begin
    { check parameter p1 }
    if parcomp(p1, ip1, err, P1MIN, P1MAX) then
    begin
      if length(p2) = 0 then
      begin
        { show selected }
        writemsg(50, true);
        writemsg(91, true);
        writetaperec(ip1);
      end else
      begin
        { assign file to selected tape }
        fn := p2;
        for bi := 1 to length(fn) do fn[bi] := upcase(fn[bi]);
        if ip1 = 0 then
        begin
          dn := fn;
          machine.tapes[ip1].filename := dn + ':';
        end else machine.tapes[ip1].filename := fn + '.TAP';
        writemsg(50, false);
        writeln(machine.tapes[ip1].filename + '.');
      end;
    end;
  end;
  { error message }
  if err > 0 then writemsg(err, true);
end;
