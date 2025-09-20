{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | _cpm.pas                                                                 | }
{ | Procedures and functions for CP/M                                        | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ READ A KEY FROM STANDARD INPUT }
function keyread: char;
begin
  if bdos($0b, 0) = $ff
    then keyread := chr(bdos($01, 0))
    else keyread := '';
end;

{ DETECT KEYPRESS }
function keypress: boolean;
begin
  if bdos($0b, 0) = $ff
    then keypress := true
    else keypress := false;
end;

{ CALCULATE TUPLE BLOCK ADDRESS FROM ARRAY INDEXES AND BYTE COUNT }
function ai2tpaddr(qn, sn, byte_count: integer): PByte;
begin
  ai2tpaddr := ptr(ord(machine.tuples) +
                   (qn * SYMCOUNT + sn) * TPBLSIZE + byte_count);
end;

{ CALCULATE TUPLE BLOCK ADDRESS FROM TUPLE NUMBER AND BYTE COUNT }
{ function tn2tpaddr(tuple_number, byte_count: integer): PByte;
  begin
    tn2tpaddr := ptr(machine.tuples^ +
                     tuple_number * TPBLSIZE + byte_count);
  end; }

{ CALCULATE TUPLE BLOCK ADDRESS FROM BYTE NUMBER}
{ function bn2tpaddr(byte_number: integer): PByte;
  begin
    bn2tpaddr := ptr(machine.tuples^ + byte_number);
  end; }

{ QUIT PROCEDURE WITH MESSAGE }
procedure quit(message, exitcode: byte);
begin
  if message > 0 then writemsg(message, true);
  halt;
end;
