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