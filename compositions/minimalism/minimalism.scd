(
~tempo = 120;
~signiture = 3.5;
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
)

(
~scale = [
	#[-8,-3, 0, 2, 4, 7, 14],
	#[-7,-4, 1, 2, 5, 7, 13],
	#[-9,-5, -1, 3, 4, 6, 12],
	#[-7,-3, 2, 7, 8, 12, 14],
	//#[-9,-2, 3, 4, 6, 10, 13],
]
)

(
Pdef(\p1,
	Pbind(
		\instrument, \sine,
		\dur, 1/2,
		\scale, Pstep(~scale, ~signiture * 4,inf),
		\degree, Pseq([0,2,1,4,3,6,5],inf),
	);
);
)

(
Pdef(\p2,
	Pbind(
		\instrument, \sine,
		\dur, 1/4,
		\scale, Pstep(~scale,~signiture * 4,inf),
		\degree, Pxrand([0,2,1,4,3,6,5],inf),
		\octave, 7,
	);
);
)

(
Pdef(\p3,
	Pbind(
		\instrument, \strings,
		\dur, 1/2,
		\scale, Pstep(~scale,~signiture * 4,inf),
		\degree, Pwrand([0,1,-1],[10,1,1].normalizeSum, inf),
		\amp, Pwrand([0.1,0.25],[5,1].normalizeSum,inf),
		\pan, Pseg([-1,1,-1],~signiture * 4,'lin',inf),
		\octave, 5,

	);
);
)

(
r = Routine({
	Pdef(\p1).play(t, quant: 3.5);
	(3.5 * 4 * 4).wait;
	Pdef(\p2).play(t, quant: 3.5);
	(3.5 * 4 * 4).wait;
	Pdef(\p3).play(t, quant: 3.5);
	});
)

(
Pdef(\p2,
	Pbind(
		\instrument, \sine,
		\dur, 1/4,
		\scale, Pstep(~scale,~signiture * 4,inf),
		\degree, Pxrand([[0,2],[1,4],[3,6,5]],inf),
		\octave, 7,
	);
);
)

(
Pdef(\p2,
	Pbind(
		\instrument, \sine,
		\dur, 1/4,
		\scale, Pstep(~scale,~signiture * 4,inf),
		\degree, [1,4,3],
		\octave, 7,
	);
);
)

(
Pdef(\p1,
	Pbind(
		\instrument, \sine,
		\dur, 1,
		\scale, Pstep(~scale, ~signiture * 4,inf),
		\degree, Pseq([0,2,1,4,3,6,5],inf),
	);
);
)

r.play(t);
