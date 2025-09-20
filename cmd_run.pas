{ +--------------------------------------------------------------------------+ }
{ | AlanZ80X v0.1 * Extended Turing machine                                  | }
{ | cmd_run.pas                                                              | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | Command 'run'                                                            | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'run' }
overlay procedure cmd_run(p1: boolean);
var
  c:       char;
  bj:      byte;
  dev:     text;
  err:     byte;                                                  { error code }
  int:     byte;                                            { interrupt number }
  verbose: boolean;                                          { verbose showing }
label
  200, 800;

  { LOAD ALL TAPES FROM FILE WITH OPTIONAL ECHO TO STD OUT DEVICE }
  function loadalltapes: boolean;
  var
    bi, bj: byte;
    tape:   text;
  begin
    loadalltapes := true;
    assign(dev, machine.tapes[0].filename);
    for bi := 1 to 5 do
    begin
      if machine.tapes[bi].accessmode < 2 then
      begin
        assign(tape, machine.tapes[bi].filename);
        {$I-}
        reset(tape);
        {$I+}
        if ioresult <> 0 then
        begin
          loadalltapes := false;
          writemsg(51, false);
          writeln(bi,' (' + machine.tapes[bi].filename + ')');
        end else
        begin
          readln(tape, machine.tapes[bi].data);
          { convert to uppercase }
          for bj := 1 to length(machine.tapes[bi].data) do
            machine.tapes[bi].data[bi] := upcase(machine.tapes[bi].data[bi]);
          { echo to standard output}
          if flag_echo then writeln(dev, 't',bi,': ', machine.tapes[bi].data);
          close(tape);
        end;
      end;
      for bj := length(machine.tapes[bi].data) + 1 to MAXBYTE do
        machine.tapes[bi].data := machine.tapes[bi].data + SYMBOLSET[1];
    end;
  end;

  { SAVE ALL TAPES TO FILE WITH OPTIONAL ECHO TO STD OUT DEVICE }
  function savealltapes: boolean;
  var
    bi:   byte;
    tape: text;
  begin
    savealltapes := true;
    assign(dev, machine.tapes[0].filename);
    for bi := 1 to 5 do
      if (machine.tapes[bi].accessmode = 1) or (machine.tapes[bi].accessmode = 2) then
      begin
        assign(tape, machine.tapes[bi].filename);
        {$I-}
        rewrite(tape);
        {$I+}
        if ioresult <> 0 then
        begin
          savealltapes := false;
          writemsg(51, false);
          writeln(bi,' (' + machine.tapes[bi].filename + ')');
        end else
        begin
          writeln(tape, machine.tapes[bi].data);
          { echo to standard output}
          if flag_echo then writeln(dev, 't',bi,': ', machine.tapes[bi].data);
          close(tape);
        end;
      end;
  end;

begin
  err := 0;
  verbose := flag_trace or p1;
  if length(progname) = 0 then err := 46 else
  begin
    writemsg(90, true);
    for bj := 1 to 5 do
      fillchar(machine.tapes[bj].data, sizeof(machine.tapes[bj].data), SYMBOLSET[1]);  
    { load all tapes }
    if loadalltapes then
    begin
      writemsg(79, true);
      { start machine }
      if verbose then writeln;
      if verbose then writemsg(81, true);
      { reset register PSC }
      machine.registers[6].value := 0;
      syncregs;
      tprec.atrj := flag_it;
      tprec.aqi := 0;
      { machine is started }
      repeat
        { main operation }
        with machine do
        begin
          if verbose then
            write(addzero(registers[6].value, 5):5, ':  ');               { r6 }
          { - increment PSC by 1 }
          registers[6].value := registers[6].value + 1;
          syncregs;
          { - read one symbol from tape or register }
          with tprec do
          begin
            sj := 0;
            case atrj of
              0: err := 122;                                              { t0 }
             12: sj := 1;                                                 { r7 }
            else
            begin
              if (atrj < 6)  then
              begin                                                    { t1..4 }
                for bj := 1 to length(machine.symbols) do
                  if tapes[atrj].data[tapes[atrj].position] = machine.symbols[bj]
                    then sj := bj;
              end else                                                 { r0..9 }
              begin
                for bj := 1 to length(machine.symbols) do
                  if registers[atrj - 6].data[registers[atrj - 6].position] = machine.symbols[bj]
                    then sj := bj;
              end;
              if sj = 0 then err := 63;
              end;
            end;
          end;
          if err > 0 then goto 800;
          { - load tuple }
          tpblunpack(tprec.aqi, tprec.sj - 1);
          { - show details of this step }
          if verbose then
          begin
            with tprec do
            begin
              write(addzero(aqi, 3):3, '  ');                             { qi }
              if atrj > 5
                then write(DC[2], atrj - 6)                              { arj }
                else write(DC[1], atrj);                                 { atj }
              write('  ');
              if trk > 5
                then write(DC[2], trk - 6)                                { rk }
                else write(DC[1], trk);                                   { tk }
              write('  ');
              write(symbols[sj],'   ');                                   { sj }
              write(symbols[sk],'   ');                                   { sk }
              write(HMD[dj + 1],'   ');                                   { dj }
              write(HMD[dk + 1],'   ');                                   { dk }
              if trm > 5
                then write(DC[2], trm - 6)                                { rm }
                else write(DC[1], trm);                                   { tm }
              write('  ');
              writeln(addzero(qm, 3):3);                                  { qm }
            end;
          end else write('#');
          { - write one symbol to tape or register }
          with tprec do
          begin
            case trk of
                 0: writeln(dev, symbols[sk]);                            { t0 }
              1..5: tapes[trk].data[tapes[trk].position] := symbols[sk];{ t1-5 }
                 6: registers[trk - 6].data[registers[trk - 6].position] :=
                      symbols[sk];                                        { r6 }
            end;
          end;
          { - set heads position }
          with tprec do
          begin
            { tape atrj }
            case atrj of
             0: ;                                                         { t0 }
             5: if tapes[atrj].position > 2 then                          { t5 }
                  tapes[atrj].position := tapes[atrj].position - 1;
             13: ;                                                        { r7 }
            else
              if (atrj < 6) then                                       { t1..4 }
              begin
                case dj of
                  0: if tapes[atrj].position > 2 then
                       tapes[atrj].position := tapes[atrj].position - 1;
                  2: if tapes[atrj].position < MAXBYTE then
                       tapes[atrj].position := tapes[atrj].position + 1;
                end;
              end else                                       { r0..6 and r8..9 }
              begin
                case dj of
                  0: if tapes[atrj - 6].position > 2 then
                       tapes[atrj - 6].position := tapes[atrj - 6].position - 1;
                  2: if tapes[atrj - 6].position < MAXBYTE then
                       tapes[atrj - 6].position := tapes[atrj - 6].position + 1;
                end;
              end;
            end;
            { tape trk }
            case trk of
             0: ;                                                         { t0 }
             5: if tapes[trk].position < MAXBYTE then
                  tapes[trk].position := tapes[trk].position + 1;         { t5 }
             12: ;                                                        { r7 }
            else
              if (trk < 6) then                                        { t1..4 }
              begin
                case dk of
                  0: if tapes[trk].position > 2 then
                       tapes[trk].position := tapes[trk].position - 1;
                  2: if tapes[trk].position < MAXBYTE then
                       tapes[trk].position := tapes[trk].position + 1;
                end;
              end else                                       { r0..6 and r8..9 }
              begin
                case dk of
                  0: if tapes[trk - 6].position > 2 then
                       tapes[trk - 6].position := tapes[trk - 6].position - 1;
                  2: if tapes[trk - 6].position < MAXBYTE then
                       tapes[trk - 6].position := tapes[trk - 6].position + 1;
                end;
              end;
            end;
          end;
          syncregs;
          { - set next input tape or register }
          tprec.atrj := tprec.trm;
          { - set next state }
          tprec.aqi := tprec.qm;
        end;
        { - save all tapes }
        if savealltapes then ;
        { - check program set limit}
        if machine.registers[6].value = flag_sl then
        begin
          if not flag_trace then writeln;
          writemsg(83, true);
          writemsg(88, true);
          c := keyread;
          if c = #27 then goto 200;
        end;
        { - check breakpoint }
        if (flag_qb < 127) and (tprec.aqi = flag_qb) then
        begin
          if not flag_trace then writeln;
          writemsg(89, true);
          writemsg(88, true);
          c := keyread;
          if c = #27 then goto 200;
        end;
        { - step-by-step running mode }
        if p1 then
        begin
          writemsg(88, true);
          c := keyread;
          if c = #27 then goto 200;
        end;
        { IRQ }
        if flag_intr then
          with machine do
          begin
            { - detecting }
            int := MAXBYTE;
            if keypress then c := keyread;
            for bi := 3 to length(symbols) do
              if c = symbols[bi] then int := bi;
            if int <> MAXBYTE then
            begin
              { - save machine context }
              with savedcontext do
              begin
                sqm := tprec.qm;
                strm := tprec.trm;
                for bi:= 0 to 5 do
                  sr[bi] := registers[bi].value;
              end;
              flag_runmode := true;
              { - load tuple from IRQ vector table }
              tpblunpack(126, int);
              { - return from interrupt }
              if (tprec.aqi = 127) and flag_runmode then
              begin
                { load saved machine context}
                with savedcontext do
                begin
                  tprec.qm := sqm;
                  tprec.trm := strm;
                  for bi:= 0 to 5 do
                    registers[bi].value := sr[bi];
                  syncregs;
              end;
              flag_runmode := false;
            end;
          end;
        end;
      until (tprec.aqi = 127) or (machine.registers[6].value = 32767);
      writeln;
     200: { machine is stopped }
      writemsg(80, true);
     800: { error message }
    end;
  end;
  if err > 0 then writemsg(err, true);
end;
