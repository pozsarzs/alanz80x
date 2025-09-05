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
{overlay} procedure cmd_run(p1: boolean);
var
  bi:        byte;
  err:       byte;                                                { error code }
  ec:        integer;
  verbose:   boolean;
  inputtape: byte;
label
  stop, error, found;

  { LOAD ALL TAPES FROM FILE WITH OPTIONAL ECHO TO STD OUT DEVICE }
  function loadalltapes: boolean;
  var
    bi:        byte;
    dev, tape: text;
  label
    err;
  begin
    loadalltapes := true;
    assign(dev, machine.tapes[0].filename);
    for bi := 1 to 5 do
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
          if flag_echo then writeln(dev, 't',bi,': ', machine.tapes[bi].data);
          close(tape);
        end;
      end;
  end;

  { SAVE ALL TAPES TO FILE WITH OPTIONAL ECHO TO STD OUT DEVICE }
  function savealltapes: boolean;
  var
    bi:        byte;
    dev, tape: text;
  label
    err;
  begin
    savealltapes := true;
    assign(dev, machine.tapes[0].filename);
    for bi := 1 to 5 do
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
      repeat
        { increment PSC by 1 }
        machine.registers[6].value := machine.registers[6].value + 1;
        syncregs;
        { read one symbol from input tape or register}

{..}

        if verbose then
        begin
          write(addzero(machine.registers[6].value, 5):5, ':  ');         { SC }
          with tprec do
          begin
            write(addzero(aqi, 3):3, '  ');                               { qi }
            if atrj > 5                                                  { trj }
              then write(DC[2], atrj - 6)
              else write(DC[1], atrj);
            write('  ');
            if trk > 5                                                   { trk }
              then write(DC[2], trk - 6)
              else write(DC[1], trk);
            write('  ');
            write(machine.symbols[sj],'   ');                             { sj }
            write(machine.symbols[sk],'   ');                             { sk }
            write(HMD[dj + 1],'   ');                                     { dj }
            write(HMD[dk + 1],'   ');                                     { dk }
            if trm > 5                                                   { trm }
              then write(DC[2], trm - 6)
              else write(DC[1], trm);
            write('  ');
            writeln(addzero(qm, 3):3);                                    { qm }
          end;
        end else write('#');

{..}

       found:

{..}

        { - check program set limit}
        if machine.registers[6].value = flag_sl then
        begin
          writemsg(83, true);
          goto stop;
        end;
        { - check breakpoint }
        if tprec.aqi = flag_qb then
        begin
          writemsg(89, true);
          writemsg(88, true);
          waitforkey;
        end;
        { - step-by-step running mode }
        if p1 then
        begin
          writemsg(88, true);
          waitforkey;
        end;
{!}     goto stop;
      until (tprec.aqi = 127) or (machine.registers[6].value = 32767);
      writeln;
      goto stop;
     error:
      { machine is stopped }
      writemsg(err, true);
     stop:
      writemsg(80, true);
    end;
  end;
  { error message }
  if err > 0 then writemsg(err, true)
end;  
