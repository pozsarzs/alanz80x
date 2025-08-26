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
  
  { write selected register content }
  procedure writetaperec(n: byte);
  begin
    writemsg(n + 94, false);
    write(machine.tapes[n].filename:14, ' (');
    case machine.tapes[n].permission of
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
    writemsg(40, true);
    for bi := 0 to 5 do writetaperec(bi);
  end else
  begin
    { check parameter p1 }
    if parcomp(p1, ip1, err, P1MIN, P1MAX) then
    begin
      if length(p2) = 0 then
      begin
        { show selected }
        writemsg(85, true);
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
        end else
        begin
          machine.tapes[ip1].filename := fn + '.' + EXT[ip1] + '36';
        end;
        writemsg(40, false);
        writeln(machine.tapes[ip1].filename + '.');
      end;
    end;
  end;
  { error message }
  if err > 0 then writemsg(err, true);
end;
