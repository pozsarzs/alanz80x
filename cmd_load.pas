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
{overlay} procedure cmd_load(p1: TSplitted);
var
  bi, bj:         byte;
  err:            byte;                                           { error code }
  ec, i:          integer;
  lab, seg:       byte;
  line:           byte;
  qi:             integer;
  s, ss, sss:     string[255];
  stat_mandatory: byte;                      { status byte of mandatory labels }
  stat_segment:   byte;                      { status byte of program segments }
  t36file:        text;
const
  LSEGMENTS:      array[0..3] of string[4] = ('PROG', 'CARD', 'TAPE', 'COMM');
  LLABELS:        array[0..9] of string[4] = ('NAME', 'DESC', 'SYMB', 'ECHO',
                                              'TAP1', 'TAP2', 'TAP3', 'TAP4',
                                              'STCK', 'INIT');
  LBEGIN =        'BEGIN';
  LEND =          'END';
label
  error;

{ bit   stat_segment        stat_mandatory
  ----------------------------------------
  D0    'PROG BEGIN' found  'NAME' found
  D1    'PROG END' found    'DESC' found
  D2    'CARD BEGIN' found  'SYMB' found
  D3    'CARD END' found    'TAP1' found
  D4    'TAPE BEGIN' found  'TAP2' found
  D5    'TAPE END' found    'TAP3' found
  D6    'COMM BEGIN' found  'TAP4' found
  D7    'COMM END' found    'STCK' found               }

  { SET ERROR CODE AND WRITE ERROR MESSAGE }
  procedure errmsg(b: byte);
  begin
    err := b;
    writemsg(b, true);
  end;

  { STORE TAPE DATA }
  procedure storetapedata(l: byte; s: TSplitted);
  var
    bi : byte;
  begin
    with machine do
    begin
      if s[5] + s[6] = AM[1] + AM[3] then tapes[l - 3].accessmode := 0 else
        if s[5] + s[6] = AM[1] + AM[2] then tapes[l - 3].accessmode := 1 else
          if s[5] + s[6] = AM[2] + AM[3] then tapes[l - 3].accessmode := 2 else
            tapes[l - 3].accessmode := 3;
      tapes[l - 3].filename := '';
      for bi := 7 to length(s) do
        if (s[bi] <> #32) and (s[bi] <> #9) then
          tapes[lab - 3].filename := tapes[lab - 3].filename + s[bi];
    end;
  end;

begin
  err := 0;
  stat_mandatory := 0;
  stat_segment := 0;
  { check parameters }
  if length(p1) = 0 then err := 33 else
  begin
    assign(t36file, p1);
    {$I-}
      reset(t36file);
    {$I+}
    if ioresult <> 0 then err := 47 else
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
          sss := s;
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
          for bi := 0 to 8 do
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
                   progname := '';
                   for bi := 5 to length(s) do
                       progname := progname + s[bi];
                 end;
              1: { DESC found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $02;
                    progdesc := '';
                   for bi := 5 to length(s) do
                     progdesc := progdesc + s[bi];
                 end;
              2: { SYMB found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $04;
                   machine.symbols := SYMBOLSET[1] +  SYMBOLSET[2];
                   for bi := 5 to length(s) do
                     if (s[bi] <> SYMBOLSET[1]) and (s[bi] <> SYMBOLSET[2])
                       then machine.symbols := machine.symbols + s[bi];               
                 end;
              3: { ECHO found }
                 if stat_segment = $1d then
                 begin
                   { - in the opened segment TAPE }
                   storetapedata(lab, s);
                 end;
              4: { TAP1 found }
                 if stat_segment = $1d then
                 begin
                   { - in the opened segment TAPE }
                   stat_mandatory := stat_mandatory or $08;
                   storetapedata(lab, s);
                 end;
              5: { TAP2 found }
                 if stat_segment = $1d then
                 begin
                   { - in the opened segment TAPE }
                   stat_mandatory := stat_mandatory or $10;
                   storetapedata(lab, s);
                 end;
              6: { TAP3 found }
                 if stat_segment = $1d then
                 begin
                   { - in the opened segment TAPE }
                   stat_mandatory := stat_mandatory or $20;
                   storetapedata(lab, s);
                 end;
              7: { TAP4 found }
                 if stat_segment = $1d then
                 begin
                   { - in the opened segment TAPE }
                   stat_mandatory := stat_mandatory or $40;
                   storetapedata(lab, s);
                 end;
              8: { STCK found }
                 if stat_segment = $1d then
                 begin
                   { - in the opened segment TAPE }
                   stat_mandatory := stat_mandatory or $80;
                   storetapedata(lab, s);
                 end;
              9: { INIT found }
                 if stat_segment = $1d then
                 begin
                   { - in the opened segment TAPE }
                   ss := '';
                   for bi := 5 to length(s) do
                     ss := ss + s[bi];
                   val(ss, i, ec);
                   { - error messages }
                   if ec > 0 then err := 1 else
                     if (i > 0) or (i < 5) then err := 2;
                   if err > 0 then goto error else flag_it := i;
                 end;
            end;
          end;
          { load program }
          if (s[1] + s[2] = 'ST') and (stat_segment = $05) then
          begin
            { STnnn found in the opened segment PROG and CARD }
            { - remove all spaces and tabulators }
            ss := '';
            for bi := 1 to length(s) do
              if (s[bi] <> #32) and (s[bi] <> #9) then ss := ss + s[bi];
            { qi }
            val(ss[3] + ss[4]+ ss[5], qi, ec);
            { - check value }
            if ec > 0 then err := 58 else
              if qi > 126 then err := 59;
            if err > 0 then goto error;
            delete(ss, 1, 5);
            bi := 0;
            while (length(ss) >= (bi * 10 + 10)) and (bi < 127) do
            begin
              { trk }
              err := 0;
              val(ss[bi * 10 + 2], i, ec);
              if ec > 0 then err := 111 else
                if ss[bi * 10 + 1] = DC[1] then tprec.trk := i else
                  if ss[bi * 10 + 1] = DC[2] then tprec.trk := i + 6 else err := 110;
              { sj }
              tprec.sj := bi + 1;
              { sk }
              tprec.sk := 255;
              for bj := 1 to length(machine.symbols) do
                if ss[bi * 10 + 3] = machine.symbols[bj] then tprec.sk := bj;
              { - check value }
              if tprec.sk = 255 then err := 64;
              if err > 0 then goto error;
              { dj }
              tprec.dj := 255;
              for bj := 1 to 3 do
                if ss[bi * 10 + 4] = HMD[bj] then tprec.dj := bj - 1;
              { - check value }
              if tprec.dj = 255 then err := 60;
              if err > 0 then goto error;
              { dk }
              tprec.dk := 255;
              for bj := 1 to 3 do
                if ss[bi * 10 + 5] = HMD[bj] then tprec.dk := bj - 1;
              { - check value }
              if tprec.dk = 255 then err := 61;
              if err > 0 then goto error;
              { trm }
              err := 0;
              val(ss[bi * 10 + 7], i, ec);
              if ec > 0 then err := 113 else
                if ss[bi * 10 + 6] = DC[1] then tprec.trm := i else
                  if ss[bi * 10 + 6] = DC[2] then tprec.trm := i + 6 else err := 112;
              { - check value }
              if (i < 0) or (i > 15) then err := 62;
              if err > 0 then goto error;
              { qm }
              val(ss[bi * 10 + 8] + ss[bi * 10 + 9] + ss[bi * 10 + 10], i, ec);
              { - check value }
              if ec > 0 then err := 61 else
                if (i < 0) or (i > 126) then err := 62;
              if err > 0 then goto error;
              tprec.qm := i;
              { store one tuple to the memory } 
              tpblpack(qi, bi);
              bi := bi + 1;
            end;
          end;
          { load command line commands }
          if (stat_segment and $41 = $41) then
            if (s <> LSEGMENTS[3] + LBEGIN) and
               (s <> LSEGMENTS[3] + LEND) and
               (s <> LSEGMENTS[0] + LEND) then
            begin
              t36com[comline] := sss;
              comline := comline + 1;
              { set flag }
              flag_runt36cmd := true;
            end;
        end;
      until (eof(t36file)) or (line = 255);
    error:
      close(t36file);
      { error messages }
      { - bad or missing values }
      if err > 0 then writemsg(err, true);
      { - missing mandatory tags }
      if (stat_segment and $01) <> $01 then errmsg(65);
      if (stat_segment and $02) <> $02 then errmsg(66);
      if (stat_segment and $04) <> $04 then errmsg(67);
      if (stat_segment and $08) <> $08 then errmsg(68);
      if (stat_mandatory and $01) <> $01 then errmsg(71);
      if (stat_mandatory and $02) <> $02 then errmsg(72);
      if (stat_mandatory and $04) <> $04 then errmsg(73);
      if (stat_mandatory and $08) <> $08 then errmsg(74);
      if (stat_mandatory and $10) <> $10 then errmsg(118);
      if (stat_mandatory and $20) <> $20 then errmsg(119);
      if (stat_mandatory and $40) <> $40 then errmsg(120);
      if (stat_mandatory and $80) <> $80 then errmsg(121);
      { - missing optional END tags }
      if (stat_segment and $10) = $10 then
        if (stat_segment and $20) <> $20 then errmsg(69);
      if (stat_segment and $40) = $40 then
        if (stat_segment and $80) <> $80 then errmsg(70);
      if err > 0 then cmd_reset(false);
    end;
  end;
  { - file open errors }
  case err of
    33: writemsg(err, true);
    47: begin writemsg(err, false); writeln(p1 + '.'); end;
  else
    begin
      writemsg(31, true);
      { convert commands to lowercase }
      for bi := 0 to 15 do
        if length(t36com[bi]) > 0 then
          for bj := 1 to length(t36com[bi]) do
            if (ord(t36com[bi][bj]) >= 65) and (ord(t36com[bi][bj]) <= 90) then
            t36com[bi][bj] := chr(ord(t36com[bi][bj]) + 32);
    end;
  end;
end;
