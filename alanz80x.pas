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
{SX- $U+}

{ TYPES, VARIABLES, CONSTANTS, LABELS }
{$I declare.pas }

{ LOAD MESSAGES FROM FILE }
function loadmsg(filename: TFilename; count: integer): boolean;
var
  bi: byte;
  f: text;                                                      { message file }
  i, j: integer;
  s: TStr255;
begin
  fillchar(messages, sizeof(messages), ' ');
  i := 0;
  j := 1;
  assign(f, filename);
  {$I-}
  reset(f);
  {$I+}
  if ioresult <> 0 then begin write('x') ;loadmsg := false end else
  begin
    repeat
      readln(f, s);
      if j >= count then
        for bi := 1 to length(s) do
          if (i < sizeof(messages) - 1) and (i < MAXINT) then
          begin
            msglst := j;
            if (s[bi] <> #10) and (s[bi] <> #13) and (s[bi] <> #39) then
            begin
              messages[i] := s[bi];
              i := i + 1;
              messages[i] := messages[0];
            end;
          end;
      j := j + 1;
    until eof(f);
    msgfst := count;
    msglst := msglst;
    close(f);
    loadmsg := true;
  end;
end;

{ WRITE A MESSAGE TO SCREEN }
procedure writemsg(count: byte; linefeed: boolean);
var
  bi: byte;                                            { initial signal number }
  p:  integer;                                             { position in array }
label
  900;
begin
  if (count < msgfst) or (count > msglst) then
    if not loadmsg(MSGFILE, count) then
    begin
      writeln(MSGERR, MSGFILE);
      goto 900;
    end;
  bi := msgfst - 1 ;
  for p := 0 to sizeof(MESSAGES) - 1 do
  begin
    if MESSAGES[p] = MESSAGES[0] then bi := bi + 1;
    if (bi = count) and (MESSAGES[p] <> MESSAGES[0]) then write(MESSAGES[p]);
    if (bi > count) or (bi = MAXBYTE) then goto 900;
  end;
 900: { return }
  if linefeed then writeln;
end;

{ OS INDEPENDENT FUNCTION }
{ I _cpm.pas} { CP/M on Z80 }
{$I _dos.pas} { DOS on i86 }

{ INSERT ZERO BEFORE NUMBER }
function addzero(value: integer; digit: byte): TFiveDigit;
var
  result: TFiveDigit;
begin
  str(value:0, result);
  while length(result) < digit do result := '0' + result;
  addzero := result;
end;

{ DECODE TUPLE BLOCK AND UNPACK TO A RECORD TYPE VARIABLE }
procedure tpblunpack(bi, bj: byte);
var
  po0, po1, po2: PByte;

  { DECODE HEAD MOVING }
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
    sj := bj + 1;
    sk := (po0^ and $0f) * 4 + (po1^ and $c0) div 64;
    dj := decdir(0, (po1^ and $38) div 8);
    dk := decdir(1, (po1^ and $38) div 8);
    trm := (po1^ and $07) * 2 + (po2^ and $80) div 128;
    qm := po2^ and $7f;
  end;
  { check unpack }
  { writeln('Memory -> variable tprec (only 4 tuples):');
    if bj < 4 then
      with tprec do
        writeln(po0^, ' ', po1^, ' ', po2^, '-',
                trk, ' ', sj, ' ', sk, ' ', dj, ' ', dk, ' ', trm, ' ', qm); }
end;

{ ENCODE RECORD TYPE VARIABLE AND PACK TO TUPLE BLOCK }
procedure tpblpack(bi, bj: byte);
var
  po0, po1, po2: PByte;

  { ENCODE HEAD MOVING }
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
    po0^ := (trk * 16) + ((sk and $3c) div  4);
    po1^ := ((trm and $0e) div 2) + (decdir(dj, dk) * 8) + ((sk and $03) * 64);
    po2^ := (qm and $7f) + ((trm and $01) * 128);
  end;
  { check pack }
  { writeln('Variable tprec -> memory (only 4 tuples):');
    if bj < 4 then
      with tprec do
        writeln(trk, ' ', sj, ' ', sk, ' ', dj, ' ', dk, ' ', trm, ' ', qm, '-',
                po0^, ' ', po1^, ' ', po2^); }
end;

{ CONVERT COMMAND PARAMETER AND CHECK RANGE }
function parcomp(var p: TSplitted; var i: integer; var e: byte;
                 min, max: integer): boolean;
var
  ec: integer;
begin
  i := 0;
  ec := 0;
  val(p, i, ec);
  if ec <> 0 then e := 33 else
    if (i < min) or (i > max) then e := 34 else e := 0;
  parcomp := (e = 0);
end;

{ SYNCRONIZE REGISTER CONTENTS (VALUE -> DATA) }
procedure syncregs;
var
  bi, bj: byte;
begin
  for bi := 1 to 5 do
    machine.registers[bi].value := machine.tapes[bi].position;
  for bi := 0 to 9 do
  begin
    if (bi = 0) or ((bi >= 7) and (bi <= 9))
      then machine.registers[bi].data := chr(machine.registers[bi].value)
      else str(machine.registers[bi].value, machine.registers[bi].data);
    machine.registers[bi].data :=  machine.registers[bi].data + SYMBOLSET[2];
    for bj := length(machine.registers[bi].data) + 1 to 6 do
      machine.registers[bi].data :=  machine.registers[bi].data + SYMBOLSET[1];
  end;
end;

{$i cmd_rese.pas}

{ PARSING COMMANDS }
function parsingcommand(command: TStr255): boolean;
var
  bi, bj: byte;
  o:      boolean;
  s:      TStr255;
label
  200, 210, 220, 230;

{ procedures and function in overlay file }
{$i cmd_echo.pas}
{$i cmd_brea.pas}
{$i cmd_help.pas}
{$i cmd_intr.pas}
{$i cmd_limi.pas}
{$i cmd_load.pas}
{$i cmd_prog.pas}
{$i cmd_rest.pas}
{$i cmd_run.pas}
{$i cmd_trac.pas}

{ procedures and function in main binary file }
{$i cmd_symb.pas}
{$i cmd_reg.pas}
{$i cmd_tape.pas}
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
    for bi := 1 to MAXBYTE do
    begin
      if bi = length(command) then goto 200;
      if command[bi] <> #32 then o := false;
      if (command[bi] = #32) and o then command[bi] :='@';
      if command[bi] = #32 then o := true;
    end;
   200: { end of command string }
    s := '';
    for bi := 1 to length(command) do
      if command[bi] <> '@' then s := s + command[bi];
    command := s;
    { - split command to 8 slices }
    for bi := 0 to 7 do
      splitted[bi] := '';
    for bj := 1 to length(command) do
      if (command[bj] = #32) and (command[bj - 1] <> #92)
        then goto 210
        else splitted[0] := splitted[0] + command[bj];
   210: { found '\ ' characters }
    for bi:= 1 to 7 do
    begin
      for bj := bj + 1 to length(command) do
        if (command[bj] = #32) and (command[bj - 1] <> #92)
          then goto 220
          else splitted[bi] := splitted[bi] + command[bj];
   220: { found '\ ' characters }
    end;
    { parse command }
    o := false;
    if splitted[0][1] <> COMMENT then
    begin
      for bi := 0 to COMMARRSIZE do
        if splitted[0] = COMMANDS[bi] then
        begin
          o := true;
          goto 230;
        end;
     230: { found a valid command }
      if o then
      begin
        case bi of
           0: cmd_break(splitted[1]);
           1: cmd_echo(splitted[1]);
           2: cmd_help(splitted[1]);
           3: cmd_info;
           4: cmd_intr(splitted[1]);
           5: cmd_limit(splitted[1]);
           6: cmd_load(splitted[1]);
           7: cmd_prog(splitted[1], splitted[2]);
           8: parsingcommand := true;
           9: cmd_reg(splitted[1]);
          10: cmd_reset(true);
          11: cmd_restore(true);
          12: cmd_run(false);
          13: cmd_run(true);
          14: cmd_symbol(splitted[1]);
          15: cmd_tape(splitted[1], splitted[2]);
          16: cmd_trace(splitted[1]);
        end;
      end else writemsg(26, true);
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
  if not loadmsg(MSGFILE, 1) then
  begin
    writeln(MSGERR, MSGFILE);
    quit(1, 0);
  end;
  { allocate memory for tuples }
  getmem(machine.tuples, TPBLCOUNT * TPBLSIZE);
  if machine.tuples = nil then quit(2, 93);
  { cold reset }
  cmd_reset(false);
  { main operation }
  repeat
    write(PROMPT);
    readln(command);
    q := parsingcommand(command);
    { run commands from t36 file }
    if flag_runt36cmd then
    begin
      for bi := 0 to comline - 1  do
        if (length(t36com[bi]) > 0) and (t36com[bi][1] <> #0) then
          if parsingcommand(t36com[bi]) then goto 900;
      flag_runt36cmd := false;
    end;
  until q = true;
 900: { end of program }
  freemem(machine.tuples, TPBLCOUNT * TPBLSIZE);
  quit(0, 0);
end.
