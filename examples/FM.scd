(
SynthDef.new(\test, {
	arg freq = 440, rate = 100, magnitude = 2pi;
	var sig, phase;

	rate = SinOsc.kr(50,0,50,rate);
	phase = SinOsc.kr(rate,0,magnitude,freq);
	sig = SinOsc.ar(freq, phase) * 0.75;
	Out.ar(0, sig ! 2);
}).add;
)
x = Synth.new(\test)



x.set(\rate, 200)
x.set(\magnitude, 1pi)
