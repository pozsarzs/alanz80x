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

label
  quitprog;
  
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

{ DECODE TUPLE BLOCK AND UNPACK TO A RECORD TYPE VARIABLE }
procedure tpblunpack(bi, bj: byte);
var
  po0, po1, po2: PByte;

  { decode head moving }
  function decdir(dn, i: byte): byte;
  begin
    if dn = 0 then
    begin
      { dj }
      if i < 3 then decdir := 0 else
        if i > 5 then decdir := 1 else
         decdir := 2;
    end else
    begin
      { dk }
      if (i + 3) mod 3 = 0 then decdir := 0 else
        if (i + 2) mod 3 = 0 then decdir := 2 else
          if (i + 1) mod 3 = 0 then decdir := 1 else
    end
  end;

begin
  { set address }
  po0 := ai2tpaddr(bi, bj, 0);
  po1 := ai2tpaddr(bi, bj, 1);
  po2 := ai2tpaddr(bi, bj, 2);
  { read from memory and unpack bytes }
  with tprec do
  begin
    trk := (po0^ and $f0) div 16;
    sj := bj;
    sk := (po0^ and $0f) * 2 + (po1^ and $c0) div 64;
    dj := decdir(0, (po1^ and $38) div 8);
    dk := decdir(1, (po1^ and $38) div 8);
    trm := (po1^ and $17) * 2 + (po2^ and $40) div 128;
    qm := po2^ and $7f;
  end;
end;

{ ENCODE RECORD TYPE VARIABLE AND PACK TO TUPLE BLOCK }
procedure tpblpack(bi, bj: byte);
var
  po0, po1, po2: PByte;

  { endcode head moving }
  function decdir(dj, dk: byte): byte;
  var
   bi: byte;
  const
    r: array[0..7] of byte = (0, 2, 1, 20, 22, 21, 10, 12);
  begin
    decdir := 8;
    for bi := 0 to 7 do
      if r[bi] = 10 * dj + dk then decdir := bi;
  end;    

begin
  { set address }
  po0 := ai2tpaddr(bi, bj, 0);
  po1 := ai2tpaddr(bi, bj, 1);
  po2 := ai2tpaddr(bi, bj, 2);
  { pack bytes and write to memory }
  with tprec do
  begin
    p0^ := (trk * 16) + ((sk and $3c) div  4);
    p1^ := ((trm and $0e) div 2) + (decdir(dj, dk) * 8) + ((sk and $03) * 64);
    p2^ := (qm and $7f) + ((trm and $01) * 128);
  end;
end;

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
{$i cmd_load.pas}
{$i cmd_help.pas}
{$i cmd_limi.pas}
{$i cmd_prog.pas}
{$i cmd_reg.pas}
{$i cmd_rest.pas}
{$i cmd_run.pas}
{$i cmd_symb.pas}
{$i cmd_tape.pas}
{$i cmd_trac.pas}

{$i cmd_info.pas}

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
           2: cmd_info;
           3: cmd_limit(splitted[1]);
           4: cmd_load(splitted[1]);
           5: cmd_prog(splitted[1], splitted[2]);
           6: parsingcommand := true;
           7: cmd_reg(splitted[1]);
           8: cmd_reset(true);
           9: cmd_restore(true);
          10: cmd_run(false, splitted[1]);
          11: cmd_run(true, splitted[1]);
          12: cmd_symbol(splitted[1]);
          13: cmd_tape(splitted[1], splitted[2]);
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
  { allocate memory for tuples }
  getmem(machine.tuples, TPBLCOUNT * TPBLSIZE);
  if machine.tuples = nil then quit(2, 83);
  { reset machine }
  cmd_reset(false);
  trace := false;
  { main operation }
  repeat
    write(PROMPT); readln(command);
    q := parsingcommand(command);
    { run commands from t36 file }
    if runt36com then
    begin
      for bi := 0 to 15 do
        if (length(machine.t36com[bi]) > 0) and (machine.t36com[bi][1] <> #0) then
          if parsingcommand(machine.t36com[bi]) then goto quitprog;
      runt36com := false;
    end;
  until q = true;
 quitprog:
  freemem(machine.tuples, TPBLCOUNT * TPBLSIZE);
  quit(0, 0);
end.
