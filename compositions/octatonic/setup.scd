// Server Setup
(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
Server.default.reboot;"D:/Development/Supercollider/wind_modeling.scd"
)

(
SynthDef(\sine, {
	var send, ampEnv, temp, gen;

	// create ADSR envelope
	ampEnv = Env.adsr(
			\atk.ir(3),
			\dec.ir(3),
			\sus.ir(0.8),
			\rel.ir(5),
			\peak.ir(1)
	).ar(Done.freeSelf, \gate.kr(1));

	// create signal generators
	send = 0;
	4.do({
		arg i;
		temp = SinOsc.ar(
			\freq.kr(440) *
			LFNoise2.kr(1,\dtune.kr(0.01),1) //*
			//LFTri.kr(LFNoise2.kr(4,0.5,\vib_rate.kr(4)),0.0,\vib_mag.kr(0.01),1)
		);
		send = send + temp;
	});

	// apply envelope
	send = send * ampEnv * \amp.kr(1) * 0.5;

	// apply throb
	send = send * LFTri.kr(\throb_rate.kr(0),0.0,\throb_mag.kr(2),1);

	// splay across stereo field
	send = Pan2.ar(send, \pan.kr(0));

	// output
	Out.ar(\out.kr(0), send);
}).add;
)

(
SynthDef(\strings, {
	var send, ampEnv, temp, gen;

	// create ADSR envelope
	ampEnv = Env.adsr(
			\atk.ir(3),
			\dec.ir(3),
			\sus.ir(0.8),
			\rel.ir(5),
			\peak.ir(1)
	).ar(Done.freeSelf, \gate.kr(1));

	// create signal generators
	send = 0;
	4.do({
		arg i;
		temp = LFSaw.ar(\freq.kr(440) *
			LFNoise2.ar(1,\dtune.kr(0.01),1) //*
			//LFTri.kr(LFNoise2.kr(4,0.5,\vib_rate.kr(4)),0.0,\vib_mag.kr(0.01),1)
		);
		send = send + temp;
	});

	// apple envelope
	send = send * ampEnv * \amp.kr(1) * 0.5;

	// splay across stereo field
	send = Splay.ar(send);

	// filter signal
	send = LPF.ar(send, \cutoff.kr(2000));

	// output
	Out.ar(\out.kr(0), send);
}).add;
)