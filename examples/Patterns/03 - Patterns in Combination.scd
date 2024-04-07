// Patterns within list patterns
// Patterns can be embedded inside other patterns. The inner pattern will be completed until no values remain, then the outer pattern will continue

(
p = Pbind(
	\degree, Pseq([
		Pbrown(1,5,1, { rrand(4,8)}),
		Pbrown(5,10,1, { rrand(4,8)}),
		Pbrown(10,15,1, { rrand(4,8)}),
	], inf),
	\dur, 0.125,
).play;
)

// You can also enclose event patterns inside list pattenrs, as a way of spawning event patterns.

(
p = Pxrand([
	Pbind(
		\degree, Pseq([0,1,2,3],1),
		\dur, 0.5,
	),
	Pbind(
		\degree, Pseq([0,1,2,3],1),
		\dur, 0.125,
	),
	Pbind(
		\degree, Pseq([7,5],2),
		\dur, Pseq([0.7],2),
		\legato, 0.1,
	),
], inf).play;
)


