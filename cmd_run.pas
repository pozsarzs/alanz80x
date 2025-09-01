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
  bi:      byte;
  err:     byte;                                                  { error code }
  ec:      integer;
  verbose: boolean;
label
  stop, error, found;

{ LOAD ALL TAPES FROM FILE WITH OPTIONAL ECHO TO STD OUT DEVICE }
function loadalltapes: byte;
var
  bi:        byte;
  dev, tape: text;
begin
  loadalltapes := 0;
  for bi := 1 to 5 do
  begin
    assign(tape, machine.tapes[bi].filename);
    {$I-}
    reset(tape);
    {$I+}
    if ioresult <> 0 then loadalltapes := bi else
    begin
      readln(tape, machine.tapes[bi].data);
      if echo then writeln(dev, 't',bi,': ', machine.tapes[bi].data);
      close(tape);
    end;      
    if loadalltapes > 0 then exit;
  end;
end;

{ SAVE ALL TAPES TO FILE WITH OPTIONAL ECHO TO STD OUT DEVICE }
function savealltapes: byte;
var
  bi:         byte;
  dev, tape:  text;
begin
  savealltapes := 0;
  assign(dev, machine.tapes[0].filename);
  for bi := 1 to 5 do
  begin
    assign(tape, machine.tapes[bi].filename);
    {$I-}
    rewrite(tape);
    {$I+}
    if ioresult <> 0 then savealltapes := bi else
    begin
      writeln(tape, machine.tapes[bi].data);
      if echo then writeln(dev, 't',bi,': ', machine.tapes[bi].data);
      close(tape);
    end;      
    if savealltapes > 0 then exit;
  end;
end;

begin
  verbose := trace or p1;
  writemsg(90, true);
  { load all tapes }
  err := loadalltapes;
  writemsg(51, false);
  writeln(err,' (' + machine.tapes[err].filename + ')');
  err := 0; 
  writemsg(79, true);
  { start machine }
  if verbose then writeln;
  if verbose then writemsg(81, true);
  setreg(6, 0);
  repeat
    setreg(6, getreg(6) + 1);


{ Note: ACC; 1TP; 2TP; 3TP; 4TP; STP; PSC; BLR }
{    if verbose then
      write(machine.progcount:5, '   ', addzero(machine.tapepos), '   ',
            addzero(machine.aqi), '   ') else write('#');


    machine.asj := machine.tape[machine.tapepos + 99]; 
    if verbose then write(machine.asj, '   ');
    for bi := 0 to 39 do
      if machine.rules[machine.aqi, bi].sj = machine.asj then goto found;
    err := 56;
    goto error;}

 found:

{    machine.tape[machine.tapepos + 99] := machine.rules[machine.aqi, bi].sk;
    if verbose then write(machine.tape[machine.tapepos + 99], '  ');
    case machine.rules[machine.aqi, bi].D of
      'R': machine.tapepos := machine.tapepos + 1;
      'L': machine.tapepos := machine.tapepos - 1;
    end;
    if verbose then write(machine.rules[machine.aqi, bi].D, '  ');
    machine.aqi := machine.rules[machine.aqi, bi].qm;
    if verbose then writeln(addzero(machine.aqi)); }


    { - check program set limit}   
    if getreg(6) = sl then
    begin
      writemsg(83, true);
      goto stop;
    end;
    { - check breakpoint }   
    if tprec.aqi = qb then
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
  until (tprec.aqi = 127) or (getreg(6) = 32767);
  writeln;
  goto stop;
error:
  { machine is stopped }
  writemsg(err, true);
stop:
  writemsg(80, true);
end;
