{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_load.pas                                                             | }
{ | 'LOAD' command                                                           | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'load' }
overlay procedure cmd_load(p1: TSplitted);
var
  bi, bj:         byte;
  comline:        byte;
  err:            byte;                                           { error code }
  ec, i:          integer;
  lab, seg:       byte;
  line:           byte;
  qi:             integer;
  s, ss:          string[255];
  stat_mandatory: byte;                      { status byte of mandatory labels }
  stat_segment:   byte;                      { status byte of program segments }
  t36file:        text;
const
  LSEGMENTS:      array[0..3] of string[4] = ('PROG', 'CARD', 'TAPE', 'COMM');
  LLABELS:        array[0..4] of string[4] = ('NAME', 'DESC', 'SYMB', 'STAT',
                  'SPOS');
  LBEGIN =        'BEGIN';
  LEND =          'END';
label
  error;

{
    bit   stat_segment          stat_mandatory (in PROG)
    ----------------------------------------------------
    D0    'PROG BEGIN' found    'NAME' found
    D1    'PROG END' found      'DESC' found
    D2    'CARD BEGIN' found    'SYMB' found
    D3    'CARD END' found      'STAT' found
    D4    'TAPE BEGIN' found
    D5    'TAPE END' found
    D6    'COMM BEGIN' found
    D7    'COMM END' found
}

{ SET ERROR CODE AND WRITE ERROR MESSAGE }
procedure errmsg(b: byte);
begin
  err := b;
  writemsg(b, true);
end;

begin
  err := 0;
  stat_mandatory := 0;
  stat_segment := 0;
  { check parameters }
  if length(p1) = 0 then err := 7 else
  begin
    assign(t36file, p1);
    {$I-}
      reset(t36file);
    {$I+}
    if ioresult <> 0 then err := 21 else
    begin
      cmd_reset(false);
      { read text file content }
      line := 0;
      comline := 0;
      repeat
        readln(t36file, s);
        line := line + 1;
        { - remove space and tabulator from start of line }
        while (s[1] = #32) or (s[1] = #9) do delete(s, 1, 1);
        { - remove space and tabulator from end of line }
        while (s[length(s)] = #32) or (s[1] = #9) do delete(s, length(s), 1);
        { - convert to uppercase and truncate to 40 }
        for bi := 1 to length(s) do s[bi] := upcase(s[bi]);
        { - check comment sign }
        if (s[1] <> COMMENT) and (length(s) > 0) then
        begin
          { search segment }
          seg := 255;
          for bi := 0 to 3 do
            if s[1] + s[2] + s[3] + s[4] = LSEGMENTS[bi] then seg := bi;
          { - remove space and tabulator after label }
          while (s[5] = #32) or (s[5] = #9) do delete(s, 5, 1);
          if seg < 255 then
          begin
            { - segment is valid }
            case seg of
              0: { PROG found }
                 begin
                   { - PROG BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_segment := stat_segment or $01;
                   { - PROG END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_segment := stat_segment or $02;
                 end;
              1: { CARD found }
                 begin
                   { - CARD BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_segment := stat_segment or $04;
                   { - CARD END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_segment := stat_segment or $08;
                 end;
              2: { TAPE found }
                 begin
                   { - TAPE BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_segment := stat_segment or $10;
                   { - TAPE END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_segment := stat_segment or $20;
                 end;
              3: { COMM found }
                 begin
                   { - COMM BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_segment := stat_segment or $40;
                   { - COMM END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_segment := stat_segment or $80;
                 end;
            end;
          end;
          { search label }
          lab := 255;
          for bi := 0 to 4 do
            if s[1] + s[2] + s[3] + s[4] = LLABELS[bi] then lab := bi;
          if lab < 255 then
          begin
            { - label is valid }
            case lab of
              0: { NAME found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $01;
                   for bi := 5 to length(s) do
                       machine.progname := machine.progname + s[bi];
                 end;
              1: { DESC found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $02;
                   for bi := 5 to length(s) do
                     machine.progdesc := machine.progdesc + s[bi];
                 end;
              2: { SYMB found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $04;
                   for bi := 5 to length(s) do
                    machine.symbols := machine.symbols + s[bi];
                 end;
              3: { STAT found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $08;
                   ss := '';
                   for bi := 5 to length(s) do
                     ss := ss + s[bi];
                   val(ss, i, ec);
                   { - error messages }
                   if ec > 0 then err := 1 else
                     if i > 49 then err := 2;
                   if err > 0 then goto error else
                   begin
                     { - minimum value is two: q00 and q01 }
                     if i < 2 then machine.states := 2;
                     machine.states := i;
                   end;
                 end;
              4: { SPOS found }
                 if stat_segment = $11 then
                 begin
                   { - in the opened segment PROG and TAPE }
                   ss := '';
                   for bi := 5 to length(s) do
                     ss := ss + s[bi];
                   val(ss, i, ec);
                   { - error messages }
                   if ec > 0 then err := 3;
                   if err > 0 then goto error else
                   begin
{                     if (i < 50) or (i > 200)
                       then err := 4
                       else machine.tapepos := i;}
                   end;
                 end;
            end;
          end;
          { load program }
          if (s[1] + s[2] = 'ST') and (stat_segment = $05) then
          begin
            { STnn found in the opened segment PROG and CARD }
            { - remove all spaces and tabulators }
            ss := '';
            for bi := 1 to length(s) do
              if (s[bi] <> #32) and (s[bi] <> #9) then ss := ss + s[bi];
            { qi }
            val(ss[3] + ss[4], qi, ec);
            { - check value }
            if ec > 0 then err := 32 else
              if qi > 49 then err := 33;
            if err > 0 then goto error;
            delete(ss, 1, 4);
            bi := 0;
            while (length(ss) >= (bi * 5 + 5)) and (bi < 51) do
            begin
              { sj }
{              machine.rules[qi, bi].sj := ss[bi * 5 + 1];}
              { - check value }
              ec := 1;
{              for bj := 1 to length(machine.symbols) do
                if machine.rules[qi, bi].sj = machine.symbols[bj] then ec := 0;}
              if ec > 0 then err := 37;
              if err > 0 then goto error;
              { sk }
{              machine.rules[qi, bi].sk := ss[bi * 5 + 2];}
              { - check value }
              ec := 1;
{              for bj := 1 to length(machine.symbols) do
                if machine.rules[qi, bi].sk = machine.symbols[bj] then ec := 0;}
              if ec > 0 then err := 38;
              if err > 0 then goto error;
              { D }
{              machine.rules[qi, bi].D := ss[bi * 5 + 3];}
              { - check value }
              ec := 1;
{              for bj := 1 to length(HMD) do
                if machine.rules[qi, bi].D = HMD[bj] then ec := 0;}
              if ec > 0 then err := 34;
              if err > 0 then goto error;
              { qm }
              val(ss[bi * 5 + 4] + ss[bi * 5 + 5], i, ec);
              { - check value }
              if ec > 0 then err := 35 else
                if (i < 0) or (i > 49) then err := 36;
              if err > 0 then goto error;
{              machine.rules[qi, bi].qm := i;}
              bi := bi + 1;
            end;
          end;
          { load command line commands }
          if (stat_segment and $41 = $41) then
            if (s <> LSEGMENTS[3] + LBEGIN) and
               (s <> LSEGMENTS[3] + LEND) and
               (s <> LSEGMENTS[0] + LEND) then
            begin
              machine.t36com[comline] := s;
              comline := comline + 1;
            end;
        end;
      until (eof(t36file)) or (line = 255);
    error:
      close(t36file);
      { error messages }
      { - bad or missing values }
{      if err > 0 then writeln(MESSAGE[err]);}
      { - missing mandatory tags }
      if (stat_segment and $01) <> $01 then errmsg(39);
      if (stat_segment and $02) <> $02 then errmsg(40);
      if (stat_segment and $04) <> $04 then errmsg(41);
      if (stat_segment and $08) <> $08 then errmsg(42);
      if (stat_mandatory and $01) <> $01 then errmsg(45);
      if (stat_mandatory and $02) <> $02 then errmsg(46);
      if (stat_mandatory and $04) <> $04 then errmsg(47);
      if (stat_mandatory and $08) <> $08 then errmsg(48);
      { - missing optional END tags }
      if (stat_segment and $10) = $10 then
        if (stat_segment and $20) <> $20 then errmsg(43);
      if (stat_segment and $40) = $40 then
        if (stat_segment and $80) <> $80 then errmsg(44);
      if err > 0 then cmd_reset(false);
    end;
  end;
  { - file open errors }
{  case err of
     7: writeln(MESSAGE[err]);
    21: writeln(MESSAGE[err] + p1 + '.');
  else
    begin
       create backup
      tapeposbak := machine.tapepos;
      tapebak := machine.tape;
      machine.aqi := 1;
      writeln(MESSAGE[5]);
       convert commands to lowercase
      for bi := 0 to 15 do
        if length(t36com[bi]) > 0 then
          for bj := 1 to length(t36com[bi]) do
            if (ord(t36com[bi][bj]) >= 65) and (ord(t36com[bi][bj]) <= 90) then
            t36com[bi][bj] := chr(ord(t36com[bi][bj]) + 32);
       run commands
      for bi := 0 to 15 do
        if (length(t36com[bi]) > 0) and (t36com[bi][1] <> #0) then
          if parsingcommand(t36com[bi]) then halt;
    end;
  end;}
end;
