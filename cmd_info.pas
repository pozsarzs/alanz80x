{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_info.pas                                                             | }
{ | Command 'info'                                                           | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'info' }
procedure cmd_info;
var
  bi: byte;
begin
  if length(progname) = 0 then writemsg(46, true) else
  begin
    { - name }
    writemsg(48, false);
    writeln(progname);
    { - short description }
    writemsg(32, false);
    writeln(progdesc);
    { - set of symbol}
    cmd_symbol('');
    { - register contents }
    cmd_reg('');
    { - assigned files and devices }
    cmd_tape('','');
    { - optional commands from t36 file }
    if length(t36com[0]) <> 0 then
    begin
      writeln;
      writemsg(77, true);
      for bi := 0 to 15 do
        if length(t36com[bi]) > 0 then writeln(t36com[bi]);
    end;
  end;
end;
