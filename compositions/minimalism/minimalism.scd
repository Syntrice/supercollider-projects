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
Pbindef(\m,
	\instrument, \perc,
	\dur, 1,
	\freq, Pseq([2000,1000,1000,1000],inf),
	\amp, Pseq([0.2,0.1,0.1,0.1],inf),
	\legato, 0.1,
);



Pbindef(\r1,
	\instrument, \perc,
	\dur, Pbjorklund2(5,8),
	\freq, 500,
	\rel, 0.1,
	\out, ~bus_reverb,
	\legato, 0.1,
);



Pbindef(\r2,
	\instrument, \perc,
	\dur, Pbjorklund2(5,8,inf,1),
	\freq, 800,
	\out, ~bus_reverb,
	\legato, 0.1,
);



Pbindef(\r3,
	\instrument, \perc,
	\dur, Pbjorklund2(5,8,inf,2),
	\freq, 1500,
	\out, ~bus_reverb,
	\legato, 0.1,
);

Pbindef(\r4,
	\instrument, \perc,
	\dur, Pbjorklund2(5,8,inf,3) / 2,
	\freq, 2500,
	\out, ~bus_reverb,
	\legato, 0.1,
);
)

(
~tempo = 120;
~signiture = 4;
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
)

// Start

Pdef(\r1).play(t, quant: 8);
Pdef(\r2).play(t, quant: 8);
Pdef(\r3).play(t, quant: 8);
Pdef(\r4).play(t, quant: 8);


(
Pbindef(\b11,
	\instrument, \saw,
	\dur, Pbjorklund2(5,8,inf,3) / 4,
	\scale, Pfunc({~data_ev[\scale]}),
	\degree, Pfunc({~data_ev[\bass]}),
	\ctranspose, -12
)
)

(
Pdef(\data).play(t, quant: [8,0,0.05]);
Pdef(\b11).play(t, quant: 8);
)

// wait 4 bars

(
Pbindef(\p11,
	\instrument, \sine,
	\dur, Pbjorklund2(5,8,inf,4) / 4,
	\scale, Pfunc({~data_ev[\scale]}),
	\degree, Pseq([0,2,1,3,2,4,3],inf),
	\ctranspose, 0
)
)

Pdef(\p11).play(t, quant: 8);

// wait 4 bars

(
Pbindef(\b22,
	\instrument, \saw,
	\dur, Pseq([6,Rest(2)],inf),
	\scale, Pfunc({~data_ev[\scale]}),
	\degree, Pfunc({~data_ev[\bass]}),
	\ctranspose, -24,
	\atk, 1,
	\rel, 1,
	\amp, 0.2,
)
)

Pdef(\b22).play(t, quant: 8);

// wait 4 bars

(
Pbindef(\p22,
	\instrument, \sine,
	\dur, Pbjorklund2(5,8,inf,5) / 8,
	\scale, Pfunc({~data_ev[\scale]}),
	\degree, Pxrand([0,2,1,3,2,4,3],inf),
	\ctranspose, 12
)
)

Pdef(\p22).play(t, quant: 8);

// Wait 8 bars or so

(
Pbindef(\p33,
	\instrument, \saw,
	\dur, Pseq([Rest(4),4],inf),
	\scale, Pfunc({~data_ev[\scale]}),
	\degree, Pfunc({~data_ev[\bass]}),
	\ctranspose, 12,
	\atk, 1,
	\rel, 1,
	\amp, 0.2,
)
)

Pdef(\p33).play(t, quant: 8);

// Change of rhythm

Pbindef(\p11, \dur, Pbjorklund2(5,8,inf,4) / 2);
Pbindef(\r1, \dur, Pbjorklund2(5,8,inf,4));
Pbindef(\r2, \dur, Pbjorklund2(5,8,inf,4));
Pbindef(\r3, \dur, Pbjorklund2(5,8,inf,4));
Pbindef(\r4, \dur, Pbjorklund2(5,8,inf,4));
Pbindef(\p22, \degree, Pseq([[0,3],[1,4],[0,1],[2,3]],inf));
Pbindef(\b11, \dur, Pbjorklund2(5,8,inf,4));

Pbindef(\p11, \dur, 2, \degree, Pseq([[0,1],[1,2],[2,3]],inf), \atk, 0.5, \rel, 0.5);

Pbindef(\p22, \dur, 2, \atk, 0.5, \rel, 0.5);

Pbindef(\b11, \dur, 1, \atk, 0.5, \rel, 0.5);

// Gradually stop
Pbindef(\r1).stop;
Pbindef(\r2).stop;
Pbindef(\r3).stop;
Pbindef(\r4).stop;

