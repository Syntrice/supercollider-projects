/**

Yet to be named minimalism composition is a work which is based upon the three octatonic collections,
and the chords which can be made up of the collection. The work incoporates a Markov chain which determines the chord to play next based on probability.

Currently, there is a customizable chance that a chord will progress onto a chord in the same octatonic progression, or move by dominant motion to a chord in an adjacent collection.

Currently, future ideas including more Markov controlled parameters, more specific voicing of chords, or experimenting with neo-riemannian theory further.

For example, another set of states could be used for rhythmic identity, or chord voicing, or arpeggitaion. Or any other possibility really.

**/


// Dictionary of all the chords used in the piece
(
~chords = Dictionary[
	\C -> [0,4,7,11], //C
	\Cm -> [0,3,7,10], //C
	\Ds -> [2,3,7,10], //D#
	\Dsm -> [1,3,6,10], //D#
	\Fs -> [5,6,10,13], //F#
	\Fsm -> [4,6,9,13], //F#
	\A -> [4,8,9,13], // A
	\Am -> [4,9,7,12], // A

	\Cs -> [0,1,5,8], // C#
	\Csm -> [1,4,8,11], // C#
	\E -> [3,4,8,11], // E
	\Em -> [2,4,7,11], // E
	\G -> [2,6,7,11], // G
	\Gm -> [2,5,7,10], // G
	\As -> [2,5,9,10], // A#
	\Asm -> [1,5,8,10], // A#

	\D -> [1,2,6,9], // D
	\Dm -> [0,2,5,9], // D
	\F -> [0,4,5,9], // F
	\Fm -> [0,3,5,8], // F
	\Gs -> [0,3,7,8], // G#
	\Gsm -> [3,6,8,11], // G#
	\B -> [3,6,10,11], // B
	\Bm -> [2,6,9,11], // B
];
)

(
~roots = Dictionary[
	\C -> 0, //C
	\Cm -> 0, //C
	\Ds -> 1, //D#
	\Dsm -> 1, //D#
	\Fs -> 1, //F#
	\Fsm -> 1, //F#
	\A -> 2, // A
	\Am -> 1, // A

	\Cs -> 1, // C#
	\Csm -> 0, // C#
	\E -> 1, // E
	\Em -> 1, // E
	\G -> 2, // G
	\Gm -> 2, // G
	\As -> 3, // A#
	\Asm -> 3, // A#

	\D -> 1, // D
	\Dm -> 1, // D
	\F -> 2, // F
	\Fm -> 2, // F
	\Gs -> 3, // G#
	\Gsm -> 2, // G#
	\B -> 3, // B
	\Bm -> 3, // B
];
)

(
// A Markov setup to determine probability of moving between octatonic collections

~weights = [
	70, // hexatonic forward major
	70, // hexatonic forward minor
	20, // hexatonic backward major
	20, // hexatonic backward minor
	50, // dominant major
	50, // dominant minor
	25, // subdominant major
	25, // subdominant minor
	30  // parallel
].normalizeSum;

m = MarkovSet([
	[\C, [\Ds, \Dsm, \A, \Am, \G, \Gm, \F, \Fm, \Cm], ~weights],
	[\Cm, [\Ds, \Dsm, \A, \Am, \G, \Gm, \F, \Fm, \C], ~weights],

	[\Ds, [\Fs, \Fsm, \C, \Cm, \A, \Am, \Gs, \Gsm, \Dsm], ~weights],
	[\Dsm, [\Fs, \Fsm, \C, \Cm, \A, \Am, \Gs, \Gsm, \Ds], ~weights],

	[\Fs, [\A, \Am, \Ds, \Dsm, \Cs, \Csm, \B, \Bm, \Fsm], ~weights],
	[\Fsm, [\A, \Am, \Ds, \Dsm, \Cs, \Csm, \B, \Bm, \Fs], ~weights],

	[\A, [\C, \Cm, \Fs, \Fsm, \E, \Em, \D, \Dm, \Am], ~weights],
	[\Am, [\C, \Cm, \Fs, \Fsm, \E, \Em, \D, \Dm, \A], ~weights],

	[\Cs, [\E, \Em, \As, \Asm, \Gs, \Gsm, \Fs, \Fsm, \Csm], ~weights],
	[\Csm, [\E, \Em, \As, \Asm, \Gs, \Gsm, \Fs, \Fsm, \Cs], ~weights],

	[\E, [\G, \Gm, \Cs, \Csm, \B, \Bm, \A, \Am, \Em], ~weights],
	[\Em, [\G, \Gm, \Cs, \Csm, \B, \Bm, \A, \Am, \E], ~weights],

	[\G, [\As, \Asm, \E, \Em, \D, \Dm, \C, \Cm, \Gm], ~weights],
	[\Gm, [\As, \Asm, \E, \Em, \D, \Dm, \C, \Cm, \G], ~weights],

	[\As, [\Cs, \Csm, \As, \Asm, \F, \Fm, \Ds, \Dsm, \Asm], ~weights],
	[\Asm, [\Cs, \Csm, \As, \Asm, \F, \Fm, \Ds, \Dsm, \As], ~weights],

	[\D, [\F, \Fm, \B, \Bm, \A, \Am, \G, \Gm, \Dm], ~weights],
	[\Dm, [\F, \Fm, \B, \Bm, \A, \Am, \G, \Gm, \D], ~weights],

	[\F, [\Gs, \Gsm, \D, \Dm, \C, \Cm, \As, \Asm, \Fm], ~weights],
	[\Fm, [\Gs, \Gsm, \D, \Dm, \C, \Cm, \As, \Asm, \F], ~weights],

	[\Gs, [\B, \Bm, \F, \Fm, \Ds, \Dsm, \Cs, \Csm, \Gsm], ~weights],
	[\Gsm, [\B, \Bm, \F, \Fm, \Ds, \Dsm, \Cs, \Csm, \Gs], ~weights],

	[\B, [\D, \Dm, \Gs, \Gsm, \Fs, \Fsm, \E, \Em, \Bm], ~weights],
	[\Bm, [\D, \Dm, \Gs, \Gsm, \Fs, \Fsm, \E, \Em, \B], ~weights],
]);
)


// Setup a data Pdef that will iterate through the markov chain to set chords
(
~state = \C.postln;

Pdef(\data, Pbind(
	\type, \rest,
	\dur, 8,
	\scale, Pfunc({
		~state = m.next(~state);

		// Chose either the major or minor chord - doesn't affect Markov chain
		("State: " ++ ~state).postln;
		("PCS: " ++ ~chords[~state]).postln;

		~chords[~state];
	}),
	\bass, Pfunc({
		~roots[~state];
	});
).collect({ |ev| ~data_ev = ev;}));
)

(
~tempo = 120;
~signiture = 8;
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});

r = Routine({

	Pbindef(\r1,
	\instrument, \perc,
	\dur, Pwhite(1,3,inf),
	\freq, 500,
	\rel, 0.1,
	\out, ~bus_reverb,
	\legato, 0.1,
	).play(t, quant: 8);

	16.wait;

	Pbindef(\r2,
	\instrument, \perc,
	\dur, Pwhite(0.5,2,inf).round(0.5),
	\freq, 1000,
	\rel, 0.1,
	\out, ~bus_reverb,
	\legato, 0.1,
	).play(t, quant: 8);

	16.wait;

	Pbindef(\r3,
	\instrument, \perc,
	\dur, Pwhite(0.5,1,inf).round(0.5),
	\freq, 1500,
	\rel, 0.1,
	\out, ~bus_reverb,
	\legato, 0.1,
	).play(t, quant: 8);


});
)

(
Pbindef(\r1,
	\instrument, \perc,
	\dur, Pwhite(1,3,inf),
	\freq, 500,
	\rel, 0.1,
	\out, ~bus_reverb,
	\legato, 0.1,
	).play(t, quant: 8);
)

// wait 2 bars

(
Pbindef(\r2,
	\instrument, \perc,
	\dur, Pwhite(0.5,2,inf).round(0.5),
	\freq, 1000,
	\rel, 0.1,
	\out, ~bus_reverb,
	\legato, 0.1,
	).play(t, quant: 8);
)

// wait 2 bars

(
Pbindef(\r3,
	\instrument, \perc,
	\dur, Pwhite(0.5,1,inf).round(0.5),
	\freq, 1500,
	\rel, 0.1,
	\out, ~bus_reverb,
	\legato, 0.1,
	).play(t, quant: 8);
)

// wait 2 bars

(
t.playNextBar({
	Pbindef(\r1, \dur, Pbjorklund2(5,8,inf,0));
	Pbindef(\r2, \dur, Pbjorklund2(5,8,inf,1));
	Pbindef(\r3, \dur, Pbjorklund2(5,8,inf,2) /2);
};
);
)

// wait 2

(
Pdef(\data).play(t, quant: [8,0,0.05]);
Pbindef(\bass1,
	\instrument, \saw,
	\dur, Pseq([5.5,2.5],inf),
	\scale, Pfunc({~data_ev[\scale]}),
	\degree, Pfunc({~data_ev[\bass]}),
	\ctranspose, -24,
	\rel, 0.5,
).play(t, quant: 8)
)

// wait 6

(
Pbindef(\melody1,
	\instrument, \sine,
	\dur, Pbjorklund2(7,12,inf,1),
	\scale, Pfunc({~data_ev[\scale]}),
	\degree, Pseq([0,2,1,3,2,4,2],inf),
).play(t, quant: 8)
)

// wait 4

Pbindef(\melody1, \dur, Pbjorklund2(8,12,inf,1));

(
Pbindef(\r4,
	\instrument, \perc,
	\dur, Pbjorklund2(5,8,inf,4),
	\freq, 200,
	\rel, 0.5,
	\amp, 0.3,
	\out, ~bus_reverb,
	\legato, 0.1,
	).play(t, quant: 8);
)

// wait 4

Pbindef(\melody1, \dur, Pbjorklund2(9,11,inf,1));

// wait 4

(
Pbindef(\melody2,
	\instrument, \sine,
	\dur, Pseq([1/2,1/2,1/2,1/2,1/2,1/2,1/2,Rest(1/2)],inf),
	\scale, Pfunc({~data_ev[\scale]}),
	\degree, Pseq([0,1,2,3,2,1,4],inf),
	\ctranpose, 12,
).play(t, quant: 8)
)

// wait 4

(
Pbindef(\r5,
	\instrument, \perc,
	\dur, 1/2,
	\freq, 2000,
	\rel, 0.5,
	\band_width, 1000,
	\amp, Pseq([0.4,0.2],inf),
	\out, ~bus_reverb,
	\legato, 0.1,
	).play(t, quant: 8);
)

// wait 4
Pbindef(\melody2, \dur, Pseq([1/4,1/4,1/4,1/4,1/4,1/4,1/4,Rest(1/2)],inf))

// wait 4

(
Pbindef(\bass2,
	\instrument, \saw,
	\dur, Pseq([Rest(2),6],inf),
	\scale, Pfunc({~data_ev[\scale]}),
	\degree, Pfunc({~data_ev[\bass]}),
	\ctranspose, -12,
	\atk, 1,
	\rel, 1,
	\amp, 0.1,
).play(t, quant: 8);
)

(
Pbindef(\bass3,
	\instrument, \saw,
	\dur, Pseq([Rest(4),4],inf),
	\scale, Pfunc({~data_ev[\scale]}),
	\degree, Pfunc({~data_ev[\bass]}),
	\ctranspose, 12,
	\atk, 1,
	\rel, 1,
	\amp, 0.3,
).play(t, quant: 8);
)

// wait 4

// Percussion stop
Pbindef(\melody2, \dur, Pseq([1/2,1/2,1/2,1/2,1/2,1/2,1/2,Rest(1/2)],inf));
Pbindef(\r1).stop;
Pbindef(\r2).stop;
Pbindef(\r3).stop;
Pbindef(\r4).stop;

// wait 4
Pbindef(\r5).stop;
Pbindef(\bass1).stop;
Pbindef(\bass2).stop;
Pbindef(\bass3).stop;
Pbindef(\melody1).stop;

