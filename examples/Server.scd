s.boot;
s.plotTree;
s.meter;

// Nodes, Busses, Order of Execution

// Nodes -> [Synth, Group]


(
SynthDef.new(\blip, {
	arg out = 6, fund = 200, num_partial = 4, rate = 5;
	var freq, trig, sig, temp;
	rate = LFNoise1.kr(2,1,rate);
	sig = 0;
	freq = LFNoise0.kr(rate).exprange(fund,(fund * num_partial)).round(fund);
	temp = SinOsc.ar(freq) * 0.25;
	trig = Pulse.kr(rate);
	sig = sig + temp * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);
}).add;

SynthDef.new(\reverb, {
	arg in = 6, out = 0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig,0.5,0.8,0.2);
	Out.ar(out, sig);
}).add;
)

// Pass signals from y to x
y = Synth.new(\reverb, [\in, 6]);
x = Synth.new(\blip, [\out, 6]);

// Use bus object to let supercollider handle allocation of busses: much better method than above

~reverbBus = Bus.audio(s,2);
~reverbBus.index;

// Order of execution is also important: if a synth depends on another, that synth must be created first. Use S for target, and \addTotTail to place last.
y = Synth.new(\reverb, [\in, ~reverbBus], s, \addToTail);
x = Synth.new(\blip, [\out, ~reverbBus], s);

// or
x = Synth.new(\blip, [\out, ~reverbBus]);
y = Synth.new(\reverb, [\in, ~reverbBus], x, \addAfter);

// Groups:
// Grouping effects and sources is a good idea to make sure effects execute after sources

~srcgrp = Group.new;
~fxgrp = Group.after(~sourceGrp);

x = Synth.new(\blip, [\out, ~reverbBus], ~srcgrp);



y = Synth.new(\reverb, [\in, ~reverbBus], ~fxgrp);

// You can set arguments to entire synths inside a group
~srcgrp.set(\fund, exprand(60,400).round(30));
~srcgrp.set(
