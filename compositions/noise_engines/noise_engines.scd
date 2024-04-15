// Server Setup
(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
Server.default.reboot;"D:/Development/Supercollider/wind_modeling.scd"
)

// Tempo Arguments
(
~tempo = 60;
~signiture = 4;
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
)

// Piece

(
Pbindef(\pattern1,
	\instrument, \noise_engine,
	\dur, Pwhite(1,3, inf),
	\freq, Pexprand(220,880, inf),
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 6,
	\rel, 6,
	\amp, Pwhite(0.3,0.75),
	\band_width, 100,
)
)

Pbindef(\pattern1).play(t, quant:4);

~modulatePattern.(\pattern1, \band_width, Env([100,50],[20]), t);

(
~modulatePattern.(\pattern1, \rel, Env([6,3],[20]), t);
~modulatePattern.(\pattern1, \atk, Env([6,3],[20]), t);
)

~modulatePattern.(\pattern1, \band_width, Env([50,20],[20]), t);

(
Pbindef(\pattern2,
	\instrument, \noise_engine,
	\dur, Pwhite(3,4, inf),
	\freq, Pexprand(40,120, inf),
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 3,
	\rel, 3,
	\amp, Pwhite(0.3,0.75),
	\band_width, 100,
)
)

Pbindef(\pattern2).play(t, quant:4);

(
~bindFunc.(\pattern1, \band_width, {LFNoise1.kr(3.reciprocal).range(10,30)});
~bindFunc.(\pattern1, \dtune, {LFNoise1.kr(3.reciprocal).range(0.01,0.05)});
)

(
Pbindef(\pattern1, \dur, Pwhite(2,3,inf));
)

(
Pbindef(\pattern1a,
	\instrument, \noise_engine,
	\dur, Pwhite(1,3, inf),
	\freq, Pexprand(120,240, inf),
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 2,
	\rel, 3,
	\amp, Pwhite(0.3,0.75),
	\band_width, 15,
)
)

Pbindef(\pattern1a).play;
~modulatePattern.(\pattern1a, \band_width, Env([100,50],[20]), t);
~modulatePattern.(\pattern1a, \band_width, Env([100,15],[10]), t);

Pbindef(\pattern1, \dur, 1);
Pbindef(\pattern1, \atk, 0.5);

Pbindef(\pattern1, \atk, 0.5);
Pbindef(\pattern1, \freq, nil );
Pbindef(\pattern1, \degree, Prand([[0,1,4],[0,3,2],[6,4,7],[2,4,3]], inf));

~modulatePattern.(\pattern1a, \band_width, Env([100,50],[20]), t);


(
Pbindef(\pattern3,
	\instrument, \noise_engine,
	\dur, 4,
	\degree, Pxrand([0,2,4,6,8],inf),
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 2,
	\rel, 3,
	\amp, Pwhite(0.3,0.75),
	\band_width, 5,
)
)
Pbindef(\pattern3).play(t, quant:4);

(
Pbindef(\pattern4,
	\instrument, \noise_engine,
	\dur, 1/3,
	\degree, Pxrand([0,2,4,6,8],inf),
	\ctranspose, 12,
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 0.05,
	\rel, 0.01,
	\amp, Pwhite(0.3,0.5),
	\band_width, 20,
)
)
Pbindef(\pattern4).play(t, quant:4);

~tempoChange.(Env([60,90],[10]), t);

Pbindef(\pattern4, \band_width, 70);


Pbindef(\pattern1, \dur, 2, inf);


Pbindef(\pattern4).play(t, quant:4);


// Tapping:

~reverbBus = Bus.audio(s, 2);
Synth(\reverb, [\in, ~reverbBus, \mix, 0.33, \room, 0.7]);
Synth(\tap, [\out, ~reverbBus, \atk, 0.001, \rel, 0.5, \freq, 600]);

(
p = Pspawn(
	Pbind(
		\pattern, Pfunc{
			Pbind( \instrument, \tap,
				\dur, Pwhite(0.05,0.8,8),
				\freq, Pexprand(400,800,inf),
				\atk, 0.004,
				\rel, Pwhite(0.25,0.5),
				\amp, Pwhite(0.5,1),
				\pan, Pwhite(-0.8,0.8),
				\out, ~reverbBus,
			);
		},
		\delta, Pwhite(8,10, inf),
		\method, \par,
	)
)
)
