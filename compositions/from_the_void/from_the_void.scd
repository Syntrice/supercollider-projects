// "From the Void"
// Made with Supercollider 3.13.0

/* 1) Firstly, configure and run the following setup code */

(
// --- Audio Device Settings ---
// please configure your audio device settings here, according to your setup

~audio_device = "ASIO : Focusrite USB ASIO";
~numOutputBusChannels = 9;
~numInputBusChannels = 2;

//~audio_device = "ASIO : MOTU Audio ASIO";
//~numOutputBusChannels = 14;
//~numInputBusChannels = 32;

// --- Global Parameters ---
// adjust these parameters and run this code block before playing the piece

~tempo = 56; // tempo
~signiture = 4; // time signiture
~stereoOut = false; // set to true if using a stereo system
~record = true; // set to true to enable recording. Interleaved surround sound and stereo mix files will be created.

// --- Setup Code ---

// Load the server side setup code - this file should be placed in the same folder as the current file
"from_the_void_setup.scd".loadRelative;

// Midi notes for melody 1 and melody 2.
~melody = #[
	[64,66,75,73,68,69,71,69,71,73,68,66,75,76], // 329.64 to 659.26 hz
	[49,51,59,57,52,54,56,54,56,57,52,51,59,61] // 138.59 to 277.18
];


// A dictionary containing all performance events
~events = Dictionary()

.add(\noise_mid_start -> {

	Pbindef(\noise_mid,
		\instrument, \noise_engine,
		\freq, Pexprand(320,660,inf),
		\band_width, Ndef(\noise_band_width),
		\dur, Pwhite(3,5,inf),
		\pan, Pwhite(0.0,2.0,inf),
		\amp, Pfunc({Ndef(\melody_amp).get(\val) * rrand(0.75,0.9)}),
		\atk, 8, \dec, 0, \sus, 1, \rel, 8,
		\out, ~bus_master,
	).play(t, quant: 1);

	\noise_mid_start.postln;
})

.add(\rumble_start -> {

	Pbindef(\rumble, // low frequency noise engine for LFE use mainly
		\instrument, \noise_engine,
		\freq, Pexprand(20,80,inf), // LFE range frequencies randomized
		\band_width, 40, // has a fair bit of ressonance
		\dur, Pwhite(8,13,inf), // rumbles slightly less often than mid noise
		\pan, Pwhite(0.0,2.0,inf), // non-LFE component pans across stereo field
		\amp, Pfunc({Ndef(\melody_amp).get(\val) * rrand(0.45,0.65)}), // quiet volume for now
		\subamp, Pfunc({Ndef(\lfe_amp).get(\val)}),
		\atk, 4, \dec, 0, \sus, 1, \rel, 4, // quite slow attack and release
		\legato, 0.5,
		\out, ~bus_master,
	).play(t, quant: 1);

	\rumble_start.postln;

})

.add(\tapping_hi_start -> {
	// low density

	~tapping_hi = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.15,0.7,rrand(4,6)),
				\freq, exprand(880,1760),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, 200,
				\amp, Pfunc({Ndef(\tapping_amp).get(\val) * rrand(0.80,1.20)}),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\tapping_hi_start.postln;
})

.add(\tapping_lo_start -> {

	~tapping_lo = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.2,0.9,rrand(3,5)),
				\freq, exprand(138,277),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, 200,
				\amp, Pfunc({Ndef(\tapping_amp).get(\val) * rrand(1.20,1.40)}),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\tapping_lo_start.postln;

})

.add(\melody_lo_start -> {
	Pbindef(\melody_lower,
		\instrument, \impulse,
		\midinote, Ptuple([Pseq(~melody[1],inf),Pseq(~melody[1],inf)-12],inf),
		\melody_index, Pseq((0..13),inf),
		\dur, 4,
		\pan, Pwhite(0.0,2.0,inf),
		\atk, 0.5,
		\rel, 8,
		\amp, Pfunc({Ndef(\melody_amp).get(\val) + 0.1}),
		\pamp, 2,
		\band_width, 10,
		\legato, 0.1,
		\out, ~bus_master,
		\collect, Pfunc({|ev| ~e_melody_lower = ev})
	).play(t, quant: [4, 0, 1.05]);

	\melody_lo_start.postln;

})

.add(\noise_hi_start -> {


	Pbindef(\noise_hi,
		\instrument, \noise_engine,
		\freq, Pexprand(660,1320,inf),
		\band_width, Ndef(\noise_band_width),
		\dur, Pwhite(3,5,inf),
		\pan, Pwhite(0.0,2.0,inf),
		\amp, Pfunc({Ndef(\melody_amp).get(\val) * rrand(0.75,0.9)}),
		\atk, 8, \dec, 0, \sus, 1, \rel, 8,
		\out, ~bus_master,
	).play(t, quant: 1);

	\noise_hi_start.postln;

})

.add(\crackles_hi_start -> {

	~crackles_hi = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.1,0.3,rrand(18,24)),
				\freq, exprand(3000,5000),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, 200,
				\atk, 0.005,
				\rel, 0.05,
				\amp, Pfunc({Ndef(\crackles_amp).get(\val) * rrand(0.80,1.20)}),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackles_hi_start.postln;

})

.add(\crackles_lo_start -> {

	~crackles_lo = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.15,0.45,rrand(18,24)),
				\freq, exprand(1900,2900),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, 200,
				\atk, 0.005,
				\rel, 0.05,
				\amp, Pfunc({Ndef(\crackles_amp).get(\val) * rrand(0.80,1.20)}),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackles_lo_start.postln;
})

.add(\tapping_hi_increase_density -> {

	~tapping_hi.stop;
	~tapping_hi = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.1,0.5,rrand(6,8)),
				\freq, exprand(880,1760),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, 200,
				\amp, Pfunc({Ndef(\tapping_amp).get(\val) * rrand(0.80,1.20)}),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(6,8),
		\method, \par,
	)).play(t, quant: 1);

	\tapping_hi_increase_density.postln;
})

.add(\noise_lower_atk_rel -> {

	Pbindef(\noise_mid, \atk, 1, \dec, 0, \sus, 1, \rel, 5);
	Pbindef(\noise_hi, \atk, 1, \dec, 0, \sus, 1, \rel, 5);

	\noise_lower_atk_rel.postln;
})

.add(\tapping_lo_increase_density -> {
	~tapping_lo.stop;
	~tapping_lo = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.15,0.7,rrand(6,8)),
				\freq, exprand(138,277),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, 200,
				\amp, Pfunc({Ndef(\tapping_amp).get(\val) * rrand(0.80,1.20)}),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(6,8),
		\method, \par,
	)).play(t, quant: 1);

	\tapping_lo_increase_density.postln;
})



.add(\melody_hi_start ->{
	Pbindef(\noise_mid).stop;

	Pbindef(\melody_upper,
		\instrument, \noise_engine,
		\midinote, Pfunc({~melody[0][~e_melody_lower[\melody_index]]}),
		\band_width, Ndef(\noise_band_width),
		\dur, 4,
		\pan, Pfunc({~e_melody_lower[\pan]+1}), // random pan across octophonic field
		\amp, Pfunc({Ndef(\melody_amp).get(\val) + 0.1}),
		\atk, 1, // slow attack,
		\dec, 0, // no decay
		\sus, 1,
		\rel, 5, // slow release,
		\out, ~bus_master,
	).play(t, quant: 4);

	\melody_hi_start.postln;
})

.add(\crackling_hi_increase_density -> {

	~crackles_hi.stop;
	~crackles_hi = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.05,0.25,rrand(18,24)),
				\freq, exprand(3000,5000),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, 200,
				\amp, Pfunc({Ndef(\crackles_amp).get(\val) * rrand(0.80,1.20)}),
				\atk, 0.005,
				\rel, 0.05,
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackling_hi_increase_density.postln;

})

.add(\crackling_lo_increase_density -> {

	~crackles_lo.stop;
	~crackles_lo = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.1,0.35,rrand(18,24)),
				\freq, exprand(1900,2900),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, 200,
				\amp, Pfunc({Ndef(\crackles_amp).get(\val) * rrand(0.80,1.20)}),
				\atk, 0.005,
				\rel, 0.05,
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackling_lo_increase_density.postln;
})

.add(\tapping_to_droplets_hi -> {
	~tapping_hi.stop;

	Pbindef(\droplets_hi,
		\instrument, \perc,
		\midinote, Pfunc({(~t_pitch.(~melody[0][~e_melody_lower[\melody_index]] -60, [1,4,8],1,12)+60+12)}),
		\dur, Pwhite(0.25, 0.5,inf),
		\pan, Pbrown(0.0,8.0,0.125,inf),
		\legato, 0.1,
		\amp, Pfunc({Ndef(\tapping_amp).get(\val) * rrand(0.80,1.20)}),
		\band_width, Ndef(\noise_band_width),
		\out, ~bus_reverb,
	).play(t, quant: 1);

	\tapping_to_droplets_hi.postln;
})

.add(\t_lo_start -> {

	Pbindef(\t_lo,
		\instrument, \noise_engine,
		\order, Pseq([-1,-1,1,1],inf),
		\midinote, Pfunc({ |ev| ~t_pitch.(~melody[1][~e_melody_lower[\melody_index]] -60, [1,4,8],ev[\order],12)+60}),
		\band_width, Ndef(\noise_band_width),
		\dur, Pseq([Rest(2),Pn(4,inf)],inf),
		\pan, Pfunc({~e_melody_lower[\pan] - 0.5}),
		\amp, Pfunc({Ndef(\melody_amp).get(\val) + 0.1}),
		\atk, 1,
		\dec, 0,
		\sus, 1,
		\rel, 5,
		\out, ~bus_master,
	).play(t, quant: 4);

	\t_lo_start.postln;

})

.add(\tapping_to_droplets_low -> {
	~tapping_lo.stop;

	Pbindef(\droplets_lo,
		\instrument, \perc,
		\midinote, Pfunc({(~t_pitch.(~melody[1][~e_melody_lower[\melody_index]] -60, [1,4,8],1,12)+60+12)}),
		\dur, Pwhite(0.25, 0.5,inf),
		\pan, Pbrown(0.0,8.0,0.125,inf),
		\legato, 0.1,
		\amp, Pfunc({Ndef(\tapping_amp).get(\val) * rrand(0.80,1.20)}),
		\band_width, Ndef(\noise_band_width),
		\out, ~bus_reverb,
	).play(t, quant: 1);

	\tapping_to_droplets_low.postln;
})

.add(\crackling_hi_increase_density2 -> {

	~crackles_hi.stop;

	~crackles_hi = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.05,0.15,rrand(20,36)),
				\freq, exprand(3000,5000),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, 200,
				\amp, Pfunc({Ndef(\crackles_amp).get(\val) * rrand(0.80,1.20)}),
				\atk, 0.005,
				\rel, 0.05,
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackling_hi_increase_density2.postln;
})

.add(\crackling_lo_increase_density2 -> {

	~crackles_lo.stop;
	~crackles_lo = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.05,0.25,rrand(20,26)),
				\freq, exprand(1900,2900),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, 200,
				\amp, Pfunc({Ndef(\crackles_amp).get(\val) * rrand(0.80,1.20)}),
				\atk, 0.005,
				\rel, 0.05,
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackling_lo_increase_density2.postln;
})

.add(\t_hi_start -> {
	Pbindef(\noise_hi).stop;

	Pbindef(\t_hi,
		\instrument, \noise_engine,
		\order, Pseq([-1,-1,1,1],inf),
		\midinote, Pfunc({ |ev| ~t_pitch.(~melody[0][~e_melody_lower[\melody_index]] -60, [1,4,8],ev[\order],12)+60}),
		\band_width, Ndef(\noise_band_width),
		\dur, Pseq([Rest(2),Pn(4,inf)],inf),
		\pan, Pfunc({~e_melody_lower[\pan] + 0.5}),
		\amp, Pfunc({Ndef(\melody_amp).get(\val) + 0.1}),
		\atk, 1,
		\dec, 0,
		\sus, 1,
		\rel, 5,
		\out, ~bus_master,
	).play(t, quant: 4);

	\t_hi_start.postln;

})

.add(\start_boom -> {
	Pbindef(\taps_boom,
		\instrument, \perc,
		\midinote, Ptuple([~melody[1][0]-24,~melody[1][0]-12]),
		\dur, 8,
		\pan, Pseq([Pwhite(0.0,2.0,1), 0],inf),
		\amp, Pfunc({Ndef(\lfe_amp).get(\val) - 0.1}),
		\rel, 4,
		\band_width, 100,
		\subamp, Pfunc({Ndef(\lfe_amp).get(\val)}),
		\legato, 0.2,
		\out, ~bus_reverb,
	).play(t, quant: 4);

	\start_boom.postln;
})

.add(\make_legato -> {
	Pbindef(\t_hi, \legato, 1.0);
	Pbindef(\t_lo, \legato, 1.0);
	Pbindef(\melody_lower, \legato, 1.0);
	Pbindef(\melody_upper, \legato, 1.0);
	\make_legato.postln;
})

.add(\crackles_lo_stop -> {
	~crackles_lo.stop;
	\crackles_lo_stop.postln;
})

.add(\crackles_hi_stop -> {
	~crackles_hi.stop;
	\crackles_hi_stop.postln;
})

.add(\melody_lo_stop -> {
	Pbindef(\melody_lower, \midinote, Rest());
	\melody_lo_stop.postln;
})

.add(\t_hi_stop -> {
	Pbindef(\t_hi).stop;
	\t_hi_stop.postln;
})

.add(\t_lo_stop -> {
	Pbindef(\t_lo).stop;
	\t_lo_stop.postln;
})

.add(\droplets_decrease_density_hi -> {
	Pbindef(\droplets_hi,
		\instrument, \perc,
		\midinote, Pfunc({(~t_pitch.(~melody[0][~e_melody_lower[\melody_index]] -60, [1,4,8],1,12)+60+12)}),
		\dur, Pwhite(0.4, 0.7,inf),
		\pan, Pbrown(0.0,8.0,0.125,inf),
		\rel, 0.5,
		\legato, 0.1,
		\amp, Pfunc({Ndef(\tapping_amp).get(\val) * rrand(0.80,1.20)}),
		\band_width, Ndef(\noise_band_width),
		\out, ~bus_reverb,
	).play(t, quant: 1);

	\droplets_decrease_density_hi.postln;
})

.add(\droplets_decrease_density_lo -> {
	Pbindef(\droplets_lo,
		\instrument, \perc,
		\midinote, Pfunc({(~t_pitch.(~melody[1][~e_melody_lower[\melody_index]] -60, [1,4,8],1,12)+60+12)}),
		\dur, Pwhite(0.4, 0.7,inf),
		\pan, Pbrown(0.0,8.0,0.125,inf),
		\legato, 0.1,
		\rel, 0.5,
		\amp, Pfunc({Ndef(\tapping_amp).get(\val) * rrand(0.80,1.20)}),
		\band_width, Ndef(\noise_band_width),
		\out, ~bus_reverb,
	).play(t, quant: 1);

	\droplets_decrease_density_lo.postln;
})


.add(\melody_hi_stop -> {
	Pbindef(\melody_upper).stop;
	\melody_hi_stop.postln;
	Pbindef(\melody_lower).stop;

})

.add(\rumble_stop -> {
	Pbindef(\rumble).stop;
	\rumble_stop.postln;
})

.add(\droplets_lo_stop -> {
	Pbindef(\droplets_hi).stop;
	\droplets_lo_stop.postln;
})

.add(\droplets_hi_stop -> {
	Pbindef(\droplets_lo).stop;
	\droplets_hi_stop.postln;
})

.add(\boom_stop -> {
	Pbindef(\taps_boom).stop;
	\boom_stop.postln;
});



// A routine which plays the performance events in sequence, with correct timings.

~piece = Routine({

	Ndef(\noise_band_width, {\val.kr(200)});
	Ndef(\melody_amp, {\val.kr(0.05)});
	Ndef(\tapping_amp, {\val.kr(0.025)});
	Ndef(\crackles_amp, {\val.kr(0.025)});
	Ndef(\lfe_amp, {\val.kr(0.25)});

	if (~record, {~startRecording.()});

	1.wait;

	"playing events".postln;

	~events[\noise_mid_start].();

	~parameterChange.(Ndef(\noise_band_width), Env([200,5,1],[135,45]),t,16);
	~parameterChange.(Ndef(\melody_amp), Env( [0.10, 0.15, 0.25, 0.3, 0.35, 0.45, 0.75, 0.35, 0.2, 0.125,0.05],[5,10,15,15,15,55,10,30,16,25]),t,1);
	~parameterChange.(Ndef(\lfe_amp),    Env( [0.10, 0.20, 0.30, 0.4, 0.45, 0.55, 0.75, 0.50, 0.45,0.35, 0.35],[5,10,15,15,15,55,10,30,16,25]),t,1);
	~parameterChange.(Ndef(\tapping_amp), Env([0.05, 0.075,0.2,  0.2, 0.25, 0.35, 0.55, 0.25, 0.15,0.075,0.05],[5,15,15,15,15,55,10,30,16,25]),t,1);
	~parameterChange.(Ndef(\crackles_amp), Env([0.05,0.075,0.15, 0.15,0.20, 0.30, 0.55, 0.15, 0.10,0.05, 0.05],[5,15,15,15,15,55,10,30,16,25]),t,1);

	4.wait;
	~events[\rumble_start].();
	4.wait;
	~events[\tapping_hi_start].();
	6.wait;
	~events[\tapping_lo_start].();
	4.wait;
	~events[\melody_lo_start].();
	12.wait;
	~events[\noise_hi_start].();
	2.wait;
	~events[\crackles_hi_start].();
	6.wait;
	~events[\crackles_lo_start].();
	4.wait;
	~events[\tapping_hi_increase_density].();
	4.wait;
	~events[\noise_lower_atk_rel].();
	4.wait;
	~events[\tapping_lo_increase_density].();
	8.wait;
	~events[\melody_hi_start].();
	8.wait;
	~events[\crackling_hi_increase_density].();
	2.wait;
	~events[\crackling_lo_increase_density].();
	8.wait;
	~events[\tapping_to_droplets_hi].();
	8.wait;
	~events[\t_lo_start].();
	6.wait;
	~events[\tapping_to_droplets_low].();
	8.wait;
	~events[\crackling_hi_increase_density2].();
	2.wait;
	~events[\crackling_lo_increase_density2].();
	2.wait;
	~events[\t_hi_start].();
	4.wait;
	~events[\start_boom].();
	~events[\rumble_stop].();
	6.wait;
	~events[\make_legato].();
	4.wait;
	~events[\crackles_hi_stop].();
	4.wait;
	~events[\crackles_lo_stop].();
	10.wait;
	~events[\droplets_decrease_density_hi].();
	25.wait;
	~events[\melody_lo_stop].();
	5.wait;
	~events[\droplets_decrease_density_lo].();
	10.wait;
	~events[\t_hi_stop].();
	5.wait;
	~events[\t_lo_stop].();
	10.wait;
	~events[\melody_hi_stop].();
	5.wait;
	~events[\droplets_hi_stop].();
	3.wait;
	~events[\droplets_lo_stop].();
	4.wait;
	~events[\boom_stop].();
	"finished playing events".postln;
	4.wait;
	if (~record, {~stopRecording.()});
});

~play_piece = {
	t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0,{t.beatsPerBar_(~signiture)});
	Pdef.removeAll;
	Pbindef.removeAll;
	Ndef.clear();
	~piece.reset;
	~piece.play(t, quant: 4);
};

)

/* 2) Secondly, run this function to begin performance of the work */
~play_piece.();

