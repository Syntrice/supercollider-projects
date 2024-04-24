// Tempo Arguments
(
~tempo = 60;
~signiture = 4;
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
)

// Start recording (a single 4-channel file will be saved in the default recordings directory):
s.record(numChannels: 9);

// Stop recording
s.stopRecording;

(
~melody = #[
	[64,66,75,73,68,69,71,69,71,73,68,66,75,76],
	[49,51,59,57,52,54,56,54,56,57,52,51,59,61]
];
)

// Piece:

//









(
Pdef(\noise_mid,
	Pbind(
		\instrument, \noise_engine,
		\freq, Pexprand(440,880,inf),
		\dur, Pwhite(3,5,inf),
		\amp, Pwhite(0.02,0.2,inf),
		\pan, Pwhite(0.0,2.0,inf),
		\atk, 4,
		\dec, 0,
		\sus, 1,
		\rel, 4,
		\band_width, 200,
		\out, ~bus_master,
	);
)
)

Pdef(\noise_mid).play;

(
Pdef(\noise_low,
	Pbind(
		\instrument, \noise_engine,
		\freq, Pexprand(40,80,inf),
		\dur, Pwhite(8,16,inf),
		\amp, Pwhite(0.02,0.2,inf),
		\pan, Pwhite(0.0,2.0,inf),
		\atk, 4,
		\dec, 0,
		\sus, 1,
		\rel, 4,
		\band_width, 40,
		\out, ~bus_master,
		\legato, 0.5,
	);
)
)

Pdef(\noise_low).play;

(
Pdef(\taps_hi,
	Pbind(
		\instrument, \perc,
		\freq, Pseq([Pdup(8,Pexprand(880,1760,1)), Rest()],inf),
		\dur, Pseq([Pwhite(0.25,0.5,8),Pwhite(5,8,1)],inf),
		\pan, Pseq([Pdup(8,Pwhite(0.0,2.0,1)) + Pwhite(-0.1,0.1), 0],inf),
		\legato, 0.1,
		\amp, Pwhite(0.1,0.2),
		\band_width, 200,
		\out, ~bus_reverb,
	);
)
)

Pdef(\taps_hi).play;

(
Pdef(\taps_low,
	Pbind(
		\instrument, \perc,
		\freq, Pseq([Pdup(8,Pexprand(110,330,1)), Rest()],inf),
		\dur, Pseq([Pwhite(0.25,0.5,8),Pwhite(5,8,1)],inf),
		\pan, Pseq([Pdup(8,Pwhite(0.0,2.0,1)) + Pwhite(-0.1,0.1), 0],inf),
		\legato, 0.1,
		\amp, Pwhite(0.05,0.15),
		\band_width, 200,
		\out, ~bus_reverb,
	);
)
)

Pdef(\taps_low).play;

(
Pdef(\impulse,
	Pbind(
		\instrument, \impulse,
		\midinote, Ptuple([Place([~melody[1],Rest()],inf),Place([~melody[1],Rest()],inf)-12]),
		\dur, Pseq([2,Pwhite(8,12,1)],inf),
		\pan, Pwhite(0.0,2.0,inf),
		\atk, 2,
		\rel, 8,
		\pamp, 2,
		\band_width, 10,
		\out, ~bus_master,
	).collect({ |ev| ~e_impulse = ev;}));
)

Pdef(\impulse).play;

// gradually modulate to this (low bandwidth)
(
Pdef(\noise_mid,
	Pbind(
		\instrument, \noise_engine,
		\freq, Pexprand(440,880,inf),
		\dur, Pwhite(3,5,inf),
		\amp, Pwhite(0.02,0.2,inf),
		\pan, Pwhite(0.0,2.0,inf),
		\atk, 4,
		\rel, 4,
		\band_width, 100,
		\out, ~bus_master,
	);
)
)

(
Pdef(\crackles,
	Pbind(
		\instrument, \perc,
		\freq, Pseq([Pdup(32,Pexprand(3000,5000,1)), Rest()],inf),
		\dur, Pseq([Pwhite(0.05,0.3,32),Pwhite(3,5,1)],inf),
		\pan, Pseq([Pdup(32,Pwhite(0.0,2.0,1)) + Pwhite(-0.1,0.1), 0],inf),
		\legato, 0.1,
		\atk, 0.01,
		\rel, 0.1,
		\amp, Pwhite(0.01,0.05),
		\band_width, 200,
		\out, ~bus_reverb,
	);
)
)

Pdef(\crackles).play;

(
Pdef(\taps_hi,
	Pbind(
		\instrument, \perc,
		\freq, Pseq([Pexprand(880,1760,1), Rest()],inf),
		\dur, Pseq([Pwhite(0.25,0.5,8),Pwhite(5,8,1)],inf),
		\pan, Pseq([Pdup(8,Pwhite(0.0,2.0,1)) + Pwhite(-0.1,0.1), 0],inf),
		\legato, 0.1,
		\amp, Pwhite(0.1,0.2),
		\band_width, 20,
		\out, ~bus_reverb,
	);
)
)

(
Pdef(\taps_low,
	Pbind(
		\instrument, \perc,
		\freq, Pseq([Pexprand(110,330,1), Rest()],inf),
		\dur, Pseq([Pwhite(0.25,0.5,8),Pwhite(5,8,1)],inf),
		\pan, Pseq([Pdup(8,Pwhite(0.0,2.0,1)) + Pwhite(-0.1,0.1), 0],inf),
		\legato, 0.1,
		\amp, Pwhite(0.05,0.15),
		\band_width, 20,
		\out, ~bus_reverb,
	);
)
)

(
Pdef(\taps_boom,
	Pbind(
		\instrument, \perc,
		\freq, Pseq([Pexprand(40,110,1), Rest()],inf),
		\dur, 2,
		\pan, Pseq([Pwhite(0.0,2.0,1), 0],inf),
		\amp, 0.1,
		\rel, 4,
		\band_width, 100,
		\subamp, 0.1,
		\out, ~bus_master,
	);
)
)

Pdef(\taps_boom).play;


Pdef(\t1,
	Pbind(
		\instrument, \noise_engine,
		\dur, Pseq([Rest(2),Pn(4,~melody[1].size)]),
		\pan, Pfunc({~e_m1[\pan]+0.5}),
		\midinote, Pfunc({ |ev| ~t_pitch.(~e_m1[\midinote] - 60, [1,4,8], ev[\order], 12)+60}),
		\rel, 2,
		\atk, 2,
		\band_width, 20,
		\out, ~bus_master,
	);
);



(
(
Pdef(\m1,
	Pbind(
		\instrument, \noise_engine,
		\dur, 4,
		\pan, Pwhite(0.0,2.0,inf),
		\midinote, Pseq(~melody[0],1),
		\rel, 2,
		\atk, 2,
		\band_width, 20,
		\out, ~bus_master,
	).collect({ |ev| ~e_m1 = ev;}));
);

(
Pdef(\m2,
	Pbind(
		\instrument, \noise_engine,
		\dur, 4,
		\pan, Pfunc({~e_m1[\pan]+1}),
		\midinote, Pseq(~melody[1],1),
		\rel, 2,
		\band_width, 20,
		\out, ~bus_master,
	).collect({ |ev| ~e_m2 = ev;}));
);


Pdef(\t2,
	Pbind(
		\instrument, \noise_engine,
		\dur, Pseq([Rest(2),Pn(4,~melody[1].size)]),
		\pan, Pfunc({~e_m2[\pan]-0.5}),
		\order, Pseq([-1,-1,1,1],inf),
		\midinote, Pfunc({ |ev| ~t_pitch.(~e_m2[\midinote] - 60, [1,4,8], ev[\order], 12)+60}),
		\rel, 2,
		\atk, 2,
		\band_width, 20,
		\out, ~bus_master,
	);
);
)
