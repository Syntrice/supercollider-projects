s.options.numAudioBusChannels;
s.options.numOutputBusChannels;
s.options.numInputBusChannels;

(
~master_b.free;
~master_b = Bus.audio(s, 8);
~master_s.free;
~master_s = Synth(\master, [\in, ~master_b], s);

SynthDef(\master, {
	arg in;
	var snd;
	snd = In.ar(in, 8);

	// decode to stereo

	snd = DecodeB2.ar(2, snd[0], snd[1], snd[2]);

	Out.ar(\out.kr(0), snd);
}
).add;

SynthDef(\test, {
	var snd;
	snd = SinOsc.ar(\freq.kr(440)) * \amp.kr(-6.dbamp);

	snd = PanB2.ar(snd, MouseX.kr(-1,1));

	Out.ar(\out.kr(0), snd);
}).add;
)

x = Synth(\test, [\out, ~master_b], s);

x.set(\freq, 440);
x.set(\pan, 0.0);