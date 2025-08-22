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
procedure cmd_tape(p1: TSplitted);
var
  bi:  byte;
  ec:  integer;
  err: byte;                                                      { error code }
  ip1: integer;                                           { function parameter }

  { write selected register content }
  procedure writetaperec(n: byte);
  begin
    writemsg(n + 94, false);
    write(machine.tapes[n].filename:13, ' (');
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
    { show selected }
    val(p1, ip1, ec);
    if ec <> 0 then err := 23 else
      if (ip1 < 0) or (ip1 > 5) then err := 24 else
      begin
        writemsg(85, true);
        writetaperec(ip1);
      end;
  end;
  { error message }
  if err > 0 then writemsg(err, true);
end;
