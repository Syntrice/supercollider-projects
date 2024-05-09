// "Autogenous"
// Made with Supercollider 3.13.0

/* 1) Firstly, the required Quarks "Bjorklun" and "MathLib" must be installed.
Run the below code block, then recompile the class library using "Language > Recompile Class Library"" in SC IDE. */

(
Quarks.install("Bjorklund");
Quarks.install("MathLib");
)

/* 2) Secondly, configure and run the following setup code */

(

// --- Audio Device Settings ---
// please configure your audio device settings here, according to your setup

~audio_device = "ASIO : Focusrite USB ASIO";

//~audio_device = "ASIO : MOTU Audio ASIO";

// --- Global Parameters ---
// adjust these parameters and run this code block before playing the piece

~tempo = 120; // tempo
~signiture = 3.5; // time signiture
~record = true; // set to true to enable recording

// These probalities control which transformation is applied to determine the next chord
~weights = [

	70, // m3 up (to major 7th chord)
	70, // m3 up (to minor 7th chord)
	10, // m3 down (to major 7th chord)
	10, // m3 down (to minor 7th chord)
	50, // p5 up (to major 7th chord)
	50, // p5 up (to minor 7th chord)
	10, // p5 down (to major 7th chord)
	10, // p5 down  (to minor 7th chord)
	20, // parallel major / minor 7th

].normalizeSum;

~starting_chord = \C;

// --- Setup Code ---

// Load the server side setup code - this file should be placed in the same folder as the current file
"autogenous_setup.scd".loadRelative;

// Dictionary mapping each chord used in the work to the corresponding pitch class sets
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

// Dictionary mapping the root note to the corresponding index in the pitch class sets
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

// A Markov set which maps the possible chord states to the weights defined above
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

// The starting chord to begin with
~chord_state = ~starting_chord;

// A dictionary containing all performance events
~events = Dictionary()

.add(\begin_pm -> {

	Pbindef(\pm,
		\instrument, \perc,
		\dur, Pwhite(0.5,2,inf),
		\freq, 1000,
		\rel, 0.1,
		\legato, 0.01,
		\pan, 0,
		\amp, Pwhite(0.06,0.175),
		\out, ~bus_reverb,
	).play(t, quant: 3.5);

	\begin_pm.postln;
})

.add(\begin_pl -> {

	Pbindef(\pl,
		\instrument, \perc,
		\dur, Pwhite(1,3,inf).round(0.5),
		\freq, 500,
		\rel, 0.1,
		\legato, 0.01,
		\pan, -0.5,
		\amp, Pwhite(0.06,0.175),
		\out, ~bus_reverb,
	).play(t, quant: 3.5);

	\begin_pl.postln;
})

.add(\begin_ph -> {
	Pbindef(\ph,
		\instrument, \perc,
		\dur, Pwhite(0.5,1.5,inf).round(0.5),
		\freq, 1500,
		\rel, 0.1,
		\legato, 0.01,
		\pan, 0.5,
		\amp, Pwhite(0.06,0.175),
		\out, ~bus_reverb,
	).play(t, quant: 3.5);


	\begin_ph.postln;
})

.add(\begin_ch -> {

	Pdef(\data, Pbind(
		\type, \rest,
		\dur, Pwhite(5,10),
		\scale, Pfunc({ |ev|
			~chord_state = m.next(~chord_state);

			("State: " ++ ~chord_state).postln;

			~chords[~chord_state];
		}),
		\bass, Pfunc({
			~roots[~chord_state];
		}),
	).collect({|ev| ~data_ev = ev; ~data_ev.postln;})
	).play(t, quant: [7, 0, 0.05]);

	Pbindef(\ch,
		\instrument, \sine,
		\dur, Pfunc({~data_ev[\dur]}),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, [0,1,2,3]-2,
		\atk, 4,
		\rel, 2.5,
		\amp, 0.08,
		\legato, 0.6,
		\out, ~bus_master,
	).play(t, quant: 7);

	\begin_ch.postln;
})

.add(\unify_pm -> {

	Pbindef(\pm).quant = 3.5;

	Pbindef(\pm,
		\dur, Pseq([
			Pbjorklund2(4,7,4,0),
			Pbjorklund2(6,7,4,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1],4),
			Pseq([0.1,0.175,0.1,0.175],4),
		],inf),
		\pan, 0.0,
	);

	Pbindef(\pm).reset;

	\unify_pm.postln;
})

.add(\unify_pl -> {

	Pbindef(\pl).quant = 7;

	Pbindef(\pl,
		\dur, Pseq([
			Pbjorklund2(4,14,2,0),
			Pbjorklund2(6,14,2,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1],2),
			Pseq([0.1,0.175,0.1,0.175],2),
		],inf),
		\pan, 0.5,
	);

	Pbindef(\pl).reset;

	\unify_pl.postln;
})

.add(\unify_ph -> {


	Pbindef(\ph).quant = 3.5;

	Pbindef(\ph,
		\dur, Pseq([
		Pbjorklund2(4,7,4,2),
		Pbjorklund2(6,7,4,2),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1],4),
			Pseq([0.1,0.175,0.1,0.175],4),
		],inf),
		\pan, -0.5,
	);

	Pbindef(\ph).reset();

	\unify_ph.postln;
})

.add(\unify_ch -> {
	\unify_ch.postln;

	Pbindef(\ch).stop;
	Pdef(\data).stop;

	Pdef(\data).reset();
	Pbindef(\ch).reset();

	Pdef(\data, Pbind(
		\type, \rest,
		\dur, 7,
		\scale, Pfunc({ |ev|
			~chord_state = m.next(~chord_state);

			("State: " ++ ~chord_state).postln;

			~chords[~chord_state];
		}),
		\bass, Pfunc({
			~roots[~chord_state];
		}),
	).collect({|ev| ~data_ev = ev; ~data_ev.postln;})
	).play(t, quant: [7, 0, 0.05] );

	Pbindef(\ch, \dur, 7).play(t, quant: 7);
})



.add(\begin_bass1 -> {
	Pbindef(\bass1,
		\instrument, \saw,
		\dur, Pseq([3,3,3,2,2,1],inf) / 2,
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pfunc({~data_ev[\bass]}),
		\amp, Pseq([0.125,0.085,0.085,0.125,0.085,0.125],inf) -0.015,
		\ctranspose, -24,
		\pan, Pseg([-0.75,0.75,-0.75],[7,7],repeats: inf),
		\rel, 0.5,
	).play(t, quant: 7);
	\begin_bass1.postln;
})

.add(\ch_loatkrel -> {
	Pbindef(\ch,
		\atk, 1,
		\rel, 2,
		\amp, 0.100,
		\legato, 0.4,
	);
	\ch_loatkrel.postln;

})

.add(\begin_bchordm -> {

	Pbindef(\bchordm,
		\instrument, \sine,
		\dur, Prand([0.5,1,1.5],inf),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pseq([0,2,1,3,2,4,3],inf),
		\amp, Pseq([0.2,0.125,0.2,0.125,0.2,0.125,0.125],inf) + 0.05,
		\pan, Pseq([-0.5,0.5],inf)
	).play(t, quant: 7);

	\begin_bchordm.postln;
})

.add(\begin_bchordl -> {

	Pbindef(\bchordl,
		\instrument, \sine,
		\dur, Prand([0.5,1,1.5],inf),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pseq([0,2,1,3,2,4,3],inf) -3,
		\amp, Pseq([0.2,0.125,0.2,0.125,0.2,0.125,0.125],inf) + 0.05,
		\pan, Pseq([-0.5,0.5],inf)
	).play(t, quant: 7);

	\begin_bchordl.postln;
})

.add(\bchordm_regular -> {

	Pbindef(\bchordm).quant = 3.5;

	Pbindef(\bchordm,
		\dur, 1/2,
	);

	Pbindef(\bchordm).reset();

	\bchordm_regular.postln;
})

.add(\bchordl_regular -> {

	Pbindef(\bchordl).quant = 3.5;

	Pbindef(\bchordl,
		\dur, 1,
	);

	Pbindef(\bchordl).reset();

	\bchordl_regular.postln;
})

.add(\bchordm_contour -> {

	Pbindef(\bchordm).quant = 3.5;

	Pbindef(\bchordm,
		\degree, Pseq([0,2,1,3,2,4,3],inf) + Pseq([Pn(0,14),Pn(1,14),Pn(2,14),Pn(3,14)],inf),
	);

	Pbindef(\bchordm).reset();

	\bchordm_contour.postln;
})

.add(\pm_change1 -> {
	Pbindef(\pm).quant = 3.5;

	Pbindef(\pm,
		\dur, Pseq([
			Pbjorklund2(5,7,4,0),
			Pbjorklund2(7,7,4,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1],4),
			Pseq([0.1,0.175,0.1,0.175,0.175],4),
		],inf);
	);

	Pbindef(\pm).reset;

	\pm_change1.postln;
})

.add(\ph_change1 -> {
	Pbindef(\ph).quant = 3.5;

	Pbindef(\ph,
		\dur, Pseq([
		Pbjorklund2(5,7,4,2),
		Pbjorklund2(6,7,4,2),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1],4),
			Pseq([0.1,0.175,0.1,0.175,0.175],4),
	],inf),
		\pan, 0.5,
	);

	Pbindef(\ph).reset;
	\ph_change1.postln;
})

.add(\pl_change1 -> {
	Pbindef(\pl).quant = 7;

	Pbindef(\pl,
		\dur, Pseq([
			Pbjorklund2(8,14,2,0),
			Pbjorklund2(10,14,2,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1,0.175,0.1,0.175],2),
			Pseq([0.1,0.175,0.1,0.175,0.175,0.1,0.175,0.1],2),
		],inf),
		\pan, -0.5,
	);

	Pbindef(\pl).reset;
	\pl_change1.postln;
})

.add(\begin_pll -> {

	Pbindef(\pll,
		\instrument, \perc,
		\dur, Pseq([
			Pbjorklund2(8,14,inf,4),
			Pbjorklund2(10,14,inf,4),
		],inf) / 2,

		\freq, 200,
		\rel, 0.5,
		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1,0.175,0.1,0.175],2),
			Pseq([0.1,0.175,0.1,0.175,0.175,0.1,0.175,0.1],2),
		],inf) * 1.5,
		\band_width, 5,
		\pan, Pseq([1,-1],inf),
		\out, ~bus_reverb,
		\legato, 0.1,
	).play(t, quant: 7);


	\begin_pll.postln;
})

.add(\begin_drum -> {

	Pbindef(\drum,
		\instrument, \perc,
		\dur, 1/2,
		\freq, 2000,
		\rel, Pseq([0.3,0.125],inf),
		\band_width, 1000,
		\amp, Pseq([0.1,0.05],inf),
		\out, ~bus_reverb,
		\pan, Pseq([-0.25,0.25],inf),
		\legato, 0.1,
	).play(t, quant: 3.5);

	\begin_drum.postln;
})

.add(\change_drum -> {

	Pbindef(\drum).quant = 3.5;

	Pbindef(\drum,
		\instrument, \perc,
		\rel, Pseq([Pseq([0.3,0.125],7),0.125],inf),
		\amp, Pseq([Pseq([0.1,0.05],7),0.05],inf),
		\pan, Pseq([-0.25,0.25],inf),
	);

	Pbindef(\drum).reset;

	\change_drum.postln;
})

.add(\begin_bchordh -> {

	Pbindef(\bchordh,
		\instrument, \sine,
		\dur, 1/2,
		\scale, Pfunc({~data_ev[\scale]}),
		\atk, 0.01, \rel, 0.5,
		\degree, Pxrand([0,1,2,3],inf) + 8,
		\amp, Pseq([0.09,0.065,0.065],inf),
		\pan, Pseg([-0.5,0.5,-0.5],[7,7],repeats: inf),
	).play(t, quant: 3.5);

	\begin_bchordh.postln;
})

.add(\begin_bass2 -> {

	Pbindef(\bass2,
		\instrument, \saw,
		\dur, Pseq([Rest(2),5],inf),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pfunc({~data_ev[\bass]}),
		\amp, 0.15,
		\ctranspose, -12,
		\pan, Pseq([0,0.75,0,-0.75],inf),
		\pwidth, 0.8,
		\rel, 0.5,
		\atk, 0.5
	).play(t, quant: 7);

	\begin_bass2.postln;
})

.add(\bchordh_faster -> {

	Pbindef(\bchordh).quant = 3.5;

	Pbindef(\bchordh,
		\instrument, \sine,
		\dur, 1/3,
	);

	Pbindef(\bchordh).reset();

	\bchordh_faster.postln;
})

.add(\bchordh_faster2 -> {

	Pbindef(\bchordh).quant = 3.5;

	Pbindef(\bchordh,
		\instrument, \sine,
		\dur, 1/4,
	);

	Pbindef(\bchordh).reset();

	\bchordh_faster2.postln;
})

.add(\bchordh_slower -> {

	Pbindef(\bchordh).quant = 3.5;

	Pbindef(\bchordh,
		\instrument, \sine,
		\dur, 1/3,
	);

	Pbindef(\bchordh).reset();

	\bchordh_slower.postln;
})

.add(\bchordh_slower2 -> {

	Pbindef(\bchordh).quant = 3.5;

	Pbindef(\bchordh,
		\instrument, \sine,
		\dur, 1/2,
	);

	Pbindef(\bchordh).reset();

	\bchordh_slower2.postln;
})

.add(\begin_melup -> {

	Pbindef(\melup,
		\instrument, \saw,
		\dur, Pseq([Rest(4),3],inf),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pfunc({~data_ev[\bass]}),
		\amp, 0.09,
		\pwidth, 0.8,
		\ctranspose, 12,
		\cutoff, 2000,
		\pan, Pseq([0,-0.75,0,0.75],inf),
		\rel, 2,
		\atk, 0.5,
	).play(t, quant: 7);

	\begin_melup.postln;
})

.add(\begin_bass3 -> {

	Pbindef(\bass3,
		\instrument, \saw,
		\dur, 7,
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pfunc({~data_ev[\bass]}),
		\amp, 0.085,
		\ctranspose, -36,
		\pwidth, 0.8,
		\rel, 0.5,
		\atk, 0.5
	).play(t, quant: 7);

	\begin_bass3.postln;
})

.add(\pm_change2 -> {
	Pbindef(\pm).quant = 3.5;

	Pbindef(\pm,
		\dur, Pseq([
			Pbjorklund2(6,7,4,0),
			Pbjorklund2(7,7,4,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1,0.175],4),
			Pseq([0.1,0.175,0.1,0.175,0.175,0.1],4),
		],inf),
	);

	Pbindef(\pm).reset;

	\pm_change2.postln;
})

.add(\ph_change2 -> {
	Pbindef(\ph).quant = 3.5;

	Pbindef(\ph,
		\dur, Pseq([
		Pbjorklund2(6,7,4,2),
		Pbjorklund2(7,7,4,2),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1],4),
			Pseq([0.1,0.175,0.1,0.175,0.175],4),
		],inf),
		\pan, -0.5,
	);

	Pbindef(\ph).reset;
	\ph_change2.postln;
})

.add(\pl_change2 -> {
	Pbindef(\pl).quant = 7;

	Pbindef(\pl,
		\dur, Pseq([
			Pbjorklund2(9,14,2,0),
			Pbjorklund2(11,14,2,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1,0.175,0.1,0.175,0.1],2),
			Pseq([0.1,0.175,0.1,0.175,0.175,0.1,0.175,0.1,0.175],2),
		],inf),
		\pan, 0.5,
	);

	Pbindef(\pl).reset;
	\pl_change2.postln;
})

.add(\pm_change3 -> {
	Pbindef(\pm).quant = 3.5;

	Pbindef(\pm,
		\dur, Pseq([
			Pbjorklund2(3,7,4,0),
			Pbjorklund2(4,7,4,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.1],4),
			Pseq([0.1,0.175,0.175],4),
		],inf);
	);

	Pbindef(\pm).reset;

	\pm_change3.postln;
})

.add(\ph_change3 -> {
	Pbindef(\ph).quant = 3.5;

	Pbindef(\ph,
		\dur, Pbjorklund2(3,7,inf,2) / 2,
		\amp, Pseq([0.175,0.1,0.1,0.15,0.1,0.1],inf)
	);

	Pbindef(\ph,
		\dur, Pseq([
		Pbjorklund2(3,7,4,2),
		Pbjorklund2(4,7,4,2),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.1],4),
			Pseq([0.1,0.175,0.175],4),
		],inf),
		\pan, 0.5,
	);

	Pbindef(\ph).reset;
	\ph_change3.postln;
})

.add(\pl_change3 -> {
	Pbindef(\pl).quant = 7;

	Pbindef(\pl,
		\dur, Pbjorklund2(6,14,inf,1) / 2,
		\amp, Pseq([0.175,0.1,0.1,0.15,0.1,0.15,0.1,0.1],inf)
	);

	Pbindef(\pl,
		\dur, Pseq([
			Pbjorklund2(6,14,2,0),
			Pbjorklund2(7,14,2,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1,0.175],2),
			Pseq([0.1,0.175,0.1,0.175,0.175,0.1],2),
		],inf),
		\pan, -0.5,
	);

	Pbindef(\pl).reset;
	\pl_change3.postln;
})

.add(\bchordm_nonreg -> {

	Pbindef(\bchordm).quant = 3.5;

	Pbindef(\bchordm,
		\instrument, \sine,
		\dur, Pbjorklund2(8,14,inf,1),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pseq([0,2,1,3,2,4,3],inf) + Pseq([Pn(0,14),Pn(1,14),Pn(2,14),Pn(3,14)],inf),
		\amp, Pseq([0.2,0.125,0.2,0.125,0.2,0.125,0.125],inf),
		\pan, Pseq([-0.5,0.5],inf)
	);

	Pbindef(\bchordm).reset();

	\bchordm_nonreg.postln;
})


.add(\bchordl_nonreg -> {

	Pbindef(\bchordm).quant = 3.5;

	Pbindef(\bchordm,
		\instrument, \sine,
		\dur, Pbjorklund2(8,14,inf,4),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pseq([0,2,1,3,2,4,3],inf) + Pseq([Pn(0,14),Pn(1,14),Pn(2,14),Pn(3,14)],inf),
		\amp, Pseq([0.2,0.125,0.2,0.125,0.2,0.125,0.125],inf),
		\pan, Pseq([-0.5,0.5],inf)
	);

	Pbindef(\bchordm).reset();

	\bchordl_nonreg.postln;
})

.add(\stop_bchordh -> {
	t.play({Pbindef(\bchordh).stop}, quant: 3.5);
	\stop_fast_bc.postln;
})

.add(\stop_ph -> {
	t.play({Pbindef(\ph).stop}, quant: 3.5);
	\stop_ph.postln;
})

.add(\stop_pm -> {
	t.play({Pbindef(\pm).stop}, quant: 3.5);
	\stop_pm.postln;
})

.add(\stop_pl -> {
	t.play({Pbindef(\pl).stop}, quant: 3.5);
	\stop_pl.postln;
})

.add(\stop_drum -> {
	t.play({Pbindef(\drum).stop}, quant: 3.5);
	\stop_drum.postln;
})

.add(\stop_bass1 -> {
	t.play({Pbindef(\bass1).stop}, quant: 3.5);

	\stop_bass1.postln;
})

.add(\stop_bass2 -> {
	t.play({Pbindef(\bass2).stop}, quant: 3.5);

	\stop_bass2.postln;
})

.add(\stop_bchordl -> {
	t.play({Pbindef(\bchordl).stop}, quant: 3.5);

	\stop_bchordl.postln;
})

.add(\stop_melup -> {
	t.play({Pbindef(\melup).stop}, quant: 3.5);

	\stop_melup.postln;
})

.add(\stop_ch -> {

	t.play({Pbindef(\ch).stop}, quant: 3.5);

})

.add(\stop_pll -> {

	t.play({Pbindef(\pll).stop}, quant: 3.5);

})


.add(\stop_bchordm -> {

	t.play({Pbindef(\bchordm).stop}, quant: 3.5);


	\stop_bchordm.postln;
})

.add(\data_stop -> {
	t.play({Pdef(\data).stop}, quant: 3.5);

})

.add(\stop_bass3 -> {
	t.play({Pdef(\bass3).stop}, quant: 3.5);

})

;

// A routine which plays the performance events in sequence, with correct timings.
~piece = Routine({
	"playing".postln;
	~events[\begin_pm].fork;
	(3.5 * 2).wait;
	~events[\begin_pl].fork;
	(3.5 * 2).wait;
	~events[\begin_ph].fork;
	((3.5 * 4) - 0.5).wait;
	~events[\begin_ch].fork; //sightly lower amp
	((3.5 * 2) + 0.5).wait;
	~events[\unify_pm].fork;
	(3.5 * 2).wait;
	~events[\unify_pl].fork;
	(3.5 * 2).wait;
	~events[\unify_ph].fork;
	(3.5 * 2).wait;
	~events[\unify_ch].fork;
	(3.5 * 8).wait;
	~events[\begin_bass1].fork; // phrase (8 bar) // slightly lower amp
	~events[\ch_loatkrel].fork;
	(3.5 * 8).wait;
	~events[\begin_bchordm].fork; // phrase (8 bar)
	(3.5 * 4).wait;
	~events[\begin_bchordl].fork;
	(3.5 * 4).wait;
	~events[\bchordm_regular].fork; // phrase (8 bar)
	(3.5 * 2).wait;
	~events[\ph_change1].fork;
	(3.5  * 2).wait;
	~events[\pm_change1].fork;
	(3.5 * 2).wait;
	~events[\pl_change1].fork;
	(3.5 * 2).wait;
	~events[\bchordl_regular].fork; // phrase (8 bar)
	~events[\bchordm_contour].fork;
	(3.5 * 4).wait;
	~events[\begin_pll].fork;
	(3.5 * 4).wait;
	~events[\begin_bchordh].fork; // phrase (8 bar)
	(3.5 * 4).wait;
	~events[\begin_bass2].fork;
	~events[\begin_melup].fork;
	(3.5 * 4).wait;
	~events[\begin_drum].fork; // phrase (8 bar)
	(3.5 * 4).wait;
	~events[\bchordh_faster].fork;
	(3.5 * 4).wait;
	~events[\change_drum].fork; // phrase (8 bar)
	(3.5  * 2).wait;
	~events[\ph_change2].fork;
	(3.5  * 2).wait;
	~events[\bchordh_faster2].fork;
	~events[\pm_change2].fork;
	(3.5 * 2).wait;
	~events[\pl_change2].fork;
	(3.5 * 2).wait;
	~events[\begin_bass3].fork; // phrase
	(3.5 * 8).wait;
	~events[\bchordh_slower].fork; // phrase
	(3.5 * 2).wait;
	~events[\ph_change3].fork;
	(3.5  * 2).wait;
	~events[\pm_change3].fork;
	(3.5 * 2).wait;
	~events[\pl_change3].fork;
	(3.5 * 2).wait;
	~events[\bchordh_slower2].fork;
	~events[\stop_ph].fork; // phrase
	(3.5 * 2).wait;
	~events[\stop_pm].fork;
	(3.5 * 2).wait;
	~events[\stop_pl].fork;
	(3.5 * 2).wait;
	~events[\stop_drum].fork;
	~events[\stop_bchordh].fork;
	(3.5 * 2).wait;
	~events[\bchordm_nonreg].fork; // phrase
	(3.5 * 2).wait;
	~events[\bchordl_nonreg].fork;
	(3.5 * 2).wait;
	// do something here
	(3.5 * 2).wait;
	~events[\stop_pll].fork;
	(3.5 * 2).wait;
	~events[\stop_bass1].fork; // phrase
	(3.5 * 4).wait;
	~events[\stop_bass3].fork;
	~events[\stop_melup].fork;
	(3.5 * 8).wait;
	~events[\stop_bchordl].fork;
	~events[\stop_bass2].fork;
	(3.5 * 8).wait;
	~events[\stop_ch].fork; // phrase
	(3.5 * 8).wait;
	~events[\stop_bchordm].fork;
	~events[\data_stop].fork;
	(3.5 * 2).wait;
	if (~record, {~stopRecording.()});
});

~play_piece = {
	t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
	Pdef.removeAll;
	Pbindef.removeAll;
	~data_ev = nil;
	~piece.reset;
	if (~record, {~startRecording.()});
	~piece.play(t, quant: [7,-0.1]);
};

)

/* 3) Thirdly, run this function to begin performance of the work */
~play_piece.();