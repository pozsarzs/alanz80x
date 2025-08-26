{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | _dos.pas                                                                 | }
{ | Procedures and functions for DOS                                         | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ WAIT FOR A KEY }
{ procedure waitforkey;
  type
    TRegPack = record
                 AX, BX, CX, DX, BP, SI, DI, DS, ES, Flags: integer;
               end;
  var
    regs:      TRegPack;
  begin
    regs.AX := $0100;
    msdos(regs);
    writeln;
  end; }

{ CALCULATE TUPLE BLOCK ADDRESS FROM ARRAY INDEXES AND BYTE COUNT }
function ai2tpaddr(qn, sn, byte_count: integer): PByte;
begin
  ai2tpaddr := ptr(seg(machine.tuples^),
                   ofs(machine.tuples^) +
                   (qn * SYMCOUNT + sn) * TPBLSIZE + byte_count);
end;

{ CALCULATE TUPLE BLOCK ADDRESS FROM TUPLE NUMBER AND BYTE COUNT }
{ function tn2tpaddr(tuple_number, byte_count: integer): PByte;
  begin
    tn2tpaddr := ptr(seg(machine.tuples^),
                     ofs(machine.tuples^) + tuple_number * TPBLSIZE + byte_count);
  end; }

{ CALCULATE TUPLE BLOCK ADDRESS FROM BYTE NUMBER}
{ function bn2tpaddr(byte_number: integer): PByte;
  begin
    bn2tpaddr := ptr(seg(machine.tuples^),
                     ofs(machine.tuples^) + byte_number);
  end; }

{ QUIT PROCEDURE WITH MESSAGE }
procedure quit(message, exitcode: byte);
begin
  writemsg(message, true);
  halt(exitcode);
end;
