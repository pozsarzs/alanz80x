{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | alanz80x.pas                                                             | }
{ | Main program (Turbo Pascal 3.0 CP/M and DOS)                             | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

program alanz80x;

{ TYPES, VARIABLES AND CONSTANTS }
{$I declare.pas }

{ INSERT ZERO BEFORE NUMBER }
function addzero(value: integer; threedigit: boolean): TThreeDigit;
var
  result: TThreeDigit;
begin
  str(value:0, result);
  if length(result) = 1 then result := '0' + result;
  if threedigit then
    if length(result) = 2 then result := '0' + result;
  addzero := result;
end;

{ CALCULATE TUPLE BLOCK ADDRESS FROM ARRAY INDEXES AND BYTE COUNT }
function ai2tpaddr(qn, sn, byte_count: integer): PByte;
begin
  ai2tpaddr := ptr(seg(machine.tuples^),
                   ofs(machine.tuples^) +
                   (qn * SYMCOUNT + qn) * TPBLSIZE + byte_count);
end;

{ CALCULATE TUPLE BLOCK ADDRESS FROM TUPLE NUMBER AND BYTE COUNT }
function tn2tpaddr(tuple_number, byte_count: integer): PByte;
begin
  tn2tpaddr := ptr(seg(machine.tuples^),
                   ofs(machine.tuples^) + tuple_number * TPBLSIZE + byte_count);
end;

{ CALCULATE TUPLE BLOCK ADDRESS FROM BYTE NUMBER}
function bn2tpaddr(byte_number: integer): PByte;
begin
  bn2tpaddr := ptr(seg(machine.tuples^),
                   ofs(machine.tuples^) + byte_number);
end;

{ DECODE TUPLE BLOCK AND UNPACK TO A RECORD TYPE VARIABLE }
function tpblunpack(b0, b1, b2: byte): boolean;

{
|bit|0|variable|bit|1|variable|bit|2|variable|bit|
|---|-|--------|---|-|--------|---|-|--------|---|
| 7 | |trk     | 3 | |sk      | 1 | |trm     | 0 |
| 6 | |trk     | 2 | |sk      | 0 | |qm      | 6 |
| 5 | |trk     | 1 | |dj/dk   | 2 | |qm      | 5 |
| 4 | |trk     | 0 | |dj/dk   | 1 | |qm      | 4 |
| 3 | |sk      | 5 | |dj/dk   | 0 | |qm      | 3 |
| 2 | |sk      | 4 | |trm     | 3 | |qm      | 2 |
| 1 | |sk      | 3 | |trm     | 2 | |qm      | 1 |
| 0 | |sk      | 2 | |trm     | 1 | |qm      | 0 |
}

begin
    with tprec do
    begin
      qi:=0;
      trj:=0;
      trk:=0;
      sj:=0;
      sk:=0;
      dj:=0;
      dk:=0;
      trm:=0;
      qm:=0;
    end;
    tpblunpack := true;
end;

{ ENCODE RECORD TYPE VARIABLE AND PACK TO TUPLE BLOCK }
{function tpblpack(b0, b1, b2: byte): boolean;

function tpblread(state, symnum: byte): boolean;
var
  bi: byte;
  tpblock: array[0..2] of byte;
  tpmem: PByte;
begin
  if (state > 126) or (symnum > 39) then tpdecode := false else
  begin
    for bi := 0 to 2 do
    begin

    
    end;
    with tprec do
    begin
      trk := (tpblock[1] and $f0) div 16;
    
 
      qm := tpblock[3] and $7f;
    end;
    tpdecode := true;
  end;
end;
}

{ WRITE A MESSAGE TO SCREEN }
procedure writemsg(count: byte; linefeed: boolean);
var
  isn: byte;                                           { initial signal number }
  p:   integer;                                            { position in array }
label
  lf;
begin
  bi := 0;
  for p := 0 to sizeof(MESSAGES) - 1 do
  begin
    if MESSAGES[p] = MESSAGES[0] then bi := bi + 1;
    if (bi = count) and (MESSAGES[p] <> MESSAGES[0]) then write(MESSAGES[p]);
    if (bi > count) or (bi = 255) then goto lf;
  end;
 lf:
  if linefeed then writeln;
end;

{ OS INDEPENDENT FUNCTION }
{$I _dos.pas}

{ LOAD MESSAGES FROM FILE }
function loadmsg(filename: TFilename): boolean;
var
  c: char;
  f: file of char;                                              { message file }
  i: integer;
begin
  for i := 0 to sizeof(messages) - 1 do messages[i] := ' ';
  i := 0;
  assign(f, filename);
  {$I-}
  reset(f);
  {$I+}
  if ioresult <> 0 then loadmsg := false else
  begin
    repeat
      read(f, c);
      if (c <> #10) and (c <> #13) then
      begin
        messages[i] := c;
        i := i + 1;
        messages[i] := messages[0];
      end;
    until eof(f) or (i = sizeof(messages) - 1);
    close(f);
    loadmsg := true;
  end;
end;

{$i cmd_rese.pas}

{ PARSING COMMANDS }
function parsingcommand(command: TCommand): boolean;
var
  bi, bj: byte;
  s:      string[255];
  o:      boolean;
label
  break1, break2, break3, break4;

{$i cmd_brea.pas}
{$i cmd_help.pas}
{$i cmd_limi.pas}
{$i cmd_prog.pas}
{$i cmd_trac.pas}

begin
  parsingcommand := false;
  if (length(command) > 0) then
  begin
    { - remove space and tab from start of line }
    while (command[1] = #32) or (command[1] = #9) do
      delete(command, 1, 1);
    { - remove space and tab from end of line }
    while (command[length(command)] = #32) or (command[length(command)] = #9) do
      delete(command, length(command), 1);
    { - remove extra space and tab from line }
    for bi := 1 to 255 do
    begin
      if bi = length(command) then goto break1;
      if command[bi] <> #32 then o := false;
      if (command[bi] = #32) and o then command[bi] :='@';
      if command[bi] = #32 then o := true;
    end;
  break1:
    s := '';
    for bi := 1 to length(command) do
      if command[bi] <> '@' then s := s + command[bi];
    command := s;
    { - split command to 8 slices }
    for bi := 0 to 7 do
      splitted[bi] := '';
    for bj := 1 to length(command) do
      if (command[bj] = #32) and (command[bj - 1] <> #92)
        then goto break2
        else splitted[0] := splitted[0] + command[bj];
  break2:
    for bi:= 1 to 7 do
    begin
      for bj := bj + 1 to length(command) do
        if (command[bj] = #32) and (command[bj - 1] <> #92)
          then goto break3
          else splitted[bi] := splitted[bi] + command[bj];
    break3:
    end;
    { parse command }
    o := false;
    if splitted[0][1] <> COMMENT then
    begin
      for bi := 0 to COMMARRSIZE do
        if splitted[0] = COMMANDS[bi] then
        begin
          o := true;
          goto break4;
        end;
    break4:
      if o then
      begin
        case bi of
           0: cmd_break(splitted[1]);
           1: cmd_help(splitted[1]);
{           2: cmd_info; }
           3: cmd_limit(splitted[1]);
{           4: cmd_load(splitted[1]); }
           5: cmd_prog;
           6: parsingcommand := true;
{           7: cmd_reg(splitted[1]); }
           8: cmd_reset(true);
{           9: cmd_restore(true); }
{          10: cmd_run(false, splitted[1]); }
{          11: cmd_run(true, splitted[1]); }
{          12: cmd_symbol(splitted[1]); }
{          13: cmd_tape(splitted[1]); }
          14: cmd_trace(splitted[1]);
        end;
      end else writemsg(1, true);
    end;
  end;
end;


begin
  { show program information }
  writeln(HEADER1);
  writeln(HEADER2);
  for bi := 1 to length(HEADER2) do write('-');
  writeln;
  { load messages }
  if not loadmsg(MSGFILE) then
  begin
    writeln(MSGERR, MSGFILE);
    quit(1, 0);
  end;
  { reset machine }
  cmd_reset(false);
  trace := false;
  { allocate memory for tuples }
  getmem(machine.tuples, TPBLCOUNT * TPBLSIZE);
  if machine.tuples = nil then quit(2, 83);
  fillchar(machine.tuples^, TPBLCOUNT * TPBLSIZE, 0);
  { main operation }
  repeat
    write(PROMPT); readln(command);
    q := parsingcommand(command);
  until q = true;
  freemem(machine.tuples, TPBLCOUNT * TPBLSIZE);
  quit(0, 0);
end.
