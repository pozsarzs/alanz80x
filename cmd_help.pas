{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_help.pas                                                             | }
{ | Command 'help'                                                           | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'help' }
overlay procedure cmd_help(p1: TSplitted);
var
  bi:  byte;
  err: byte;                                                      { error code }
begin
  err := 26;
  { show description about all or selected command(s) }
  for bi := 0 to COMMARRSIZE do
    if (length(p1) = 0) or (COMMANDS[bi] = p1) then
    begin 
      err := 0; 
      writemsg(bi + 1, true);
    end;    
  { error message }
  if err > 0 then writemsg(err, true);
end;
