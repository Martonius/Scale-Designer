Server.killAll;

s.boot;

// Sin version
(
s.waitForBoot; // can be used inside brackets, and does not throw a message if the server is already running.

// when referencing the variables/arguments later, make sure to use the backslash (\) before the argument!!!!!!
// moved the SynthDefs to the bottom, inside the rest of this code

(
//StartThisShit :

// Window.closeAll;
// trying to see if I can have two windows open at once.
// I may need to have the window variables different, as I believe they are Environment variables
// Integrate this with the Tone_board_9-8!!

w = Window("gui", Rect(750,400,500,200))   // (left: 0, top: 0, width: 0, height: 0)
.front
.alwaysOnTop_(true);

w.onClose = {s.freeAll; "Done!".postln; "".postln};
CmdPeriod.doOnce({w.close});

Knob.defaultMode = \vert; // makes it so each knob doesn't have to be set individually
//Knob.canFocus = false; // this doesn't seem to want to work as a global setting


~baseFund = 120;   // was 110
~topFund = (~baseFund*4.pow(2));
~octaveRatio = (10.34408.pow(2));
~twelveTETsT = (~octaveRatio/12);
~nineteenTETmT = (~octaveRatio/19);




// It seems that the first object listed here gets the first tab slot/takes precedence first
~buttonFundOn = Button(w, Rect(220,90,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2,0.75,0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			x = Synth(
				\simpleSin,
				[
					\sinFreq,
					~slider.value.linexp(0,1,~baseFund,~topFund),
					\sinPh,
					~knobFundPh.value.linlin(0,1,0pi,2pi),
					// was ~knobFundPh.value.linexp(0,1,0,1).reciprocal
					\sinMult,
					~knobFundMult.value.linlin(0,1,0.25,0.75)
					// changing .reciprocal here changes what end we start at on the knob. No reciprocal, no flip.
				],
		).register},     // with isPlaying or isRunning, via NodeWatcher... and works with .register
		{x.free}
	);
});
~numberBoxFund = NumberBox(w, Rect(20,90,75,30))
.value_(~baseFund)
.clipLo_(~baseFund)
.clipHi_(~topFund)
.font_(Font("Monaco", 16))
.decimals_(3)
.action_({
	arg obj;
	~slider.valueAction_(obj.value.explin(~baseFund,~topFund,0,1))
});
~freqLabel2 = StaticText(w, Rect(97,95,120,20))
.string_("Hz - Fundamental")
.font_(Font("Monaco", 14))
.align_(\left)
;

~knobFundMult = Knob(w, Rect(280,90,30,30)) // was 180, 20
.canFocus_(false) // This works.
//.mouseOverAction_("You're on my Knob!!!'".postln)  // this is posting without being over the Knob...
//.mouseWheelAction_("You're on my Knob!!!'".postln)
// 10.wait // do not use within a method, as it may not work and throw an error?
.mouseWheelAction_({ | view, x, y, modifiers, xDelta, yDelta |
	if(
		yDelta == 15.0,
		{~knobFundMult.increment(10)}
	);
	if(
		yDelta == -15.0,
		{~knobFundMult.decrement(10)}
	);
})
.action_({
	arg obj;
	var qual;
	qual = obj.value.linlin(0,1,0.1,0.75); // trying without .reciprocal (didn't seem to help')
	// the values here don't seem to matter, because they're being changed when the argument values are changed by the button'
	if(
		x.isPlaying,     // or isRunning, via NodeWatcher... and works with .register
		{x.set(\sinMult, qual)}
	);
});
//~knob2.mode = \vert;
~multLabel = StaticText(w, Rect(315,95,55,20))
.string_("Mult")
.font_(Font("Monaco", 14))
.align_(\left)
;
~knobFundPh = Knob(w, Rect(350,90,30,30)) // was 180,
.canFocus_(false) // This works.
.mouseWheelAction_({ | view, x, y, modifiers, xDelta, yDelta |  // ({ | view, x, y, modifiers, xDelta, yDelta |
	if(
		yDelta == 15.0,
		{~knobFundPh.increment(10)}
	);
	if(
		yDelta == -15.0,
		{~knobFundPh.decrement(10)}
	);
	if(
		(modifiers & 131072 == 131072),     // whatever I need to put here to signify the Shift key
		{"you have pressed shift while scrolling".postln}
	);
})
//.shift_scale_(2)
.action_({
	arg obj;
	var qual;
	//qual = obj.value;
	qual = obj.value.linlin(0,1,0pi,2pi);   // this seems to work for the phase scaling!!!
	// was obj.value.linexp(0,1,0,1).reciprocal;
	if(
		x.isPlaying,
		{x.set(\sinPh, qual); qual.postln}
		// was (\sinPh, qual); (obj.value.linexp(0,1,0,1)).postln}
	);
});
//~knob1.mode = \vert;
~phaseLabel = StaticText(w, Rect(385,95,92,20))
.string_("Phase(rads)")
.font_(Font("Monaco", 14))
.align_(\left)
;



~buttonOctDownOn = Button(w, Rect(220,55,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2,0.75,0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			y = Synth(
				\simpleSinDown,
				[
					\sinFreqD,
					~numberBoxOctDown.value,
					\sinPhD,
					~knobDownPh.value.linlin(0,1,0pi,2pi),
					\sinMultD,
					~knobDownMult.value.linlin(0,1,0.1,0.75)
					// changing .reciprocal here changes what end we start at on the knob. No reciprocal, no flip.
				],
		).register},
		{y.free}
	);
})
;
~numberBoxOctDown = NumberBox(w, Rect(20,55,75,30))
.canFocus_(false) // This works.
.value_(~numberBoxFund.value/2)
.clipLo_(~baseFund/2)
.clipHi_(~topFund/2)
.font_(Font("Monaco", 16))
.decimals_(3)
.scroll = 0 // disables scrolling
;
~freqLabel1 = StaticText(w, Rect(97,60,120,20))
.string_("Hz - Octave Down")
.font_(Font("Monaco", 14))
.align_(\left)
;
~knobDownMult = Knob(w, Rect(280,55,30,30)) // was 180, 20
.canFocus_(false) // This works.
.mouseWheelAction_({ | view, x, y, modifiers, xDelta, yDelta |
	if(
		yDelta == 15.0,
		{~knobDownMult.increment(10)}
	);
	if(
		yDelta == -15.0,
		{~knobDownMult.decrement(10)}
	);
})
.action_({
	arg obj;
	var qual;
	qual = obj.value.linlin(0,1,0.1,0.75); // trying without .reciprocal (didn't seem to help')
	// the values here don't seem to matter, because they're being changed when the argument values are changed by the button'
	if(
		y.isPlaying,     // y is the Synth instance for this octave down
		{y.set(\sinMultD, qual)}
	);
});
//~knob2.mode = \vert;
~multLabel1 = StaticText(w, Rect(315,60,55,20))
.string_("Mult")
.font_(Font("Monaco", 14))
.align_(\left)
;
~knobDownPh = Knob(w, Rect(350,55,30,30)) // was 180,
.canFocus_(false) // This works.
.mouseWheelAction_({ | view, x, y, modifiers, xDelta, yDelta |
	if(
		yDelta == 15.0,
		{~knobDownPh.increment(10)}
	);
	if(
		yDelta == -15.0,
		{~knobDownPh.decrement(10)}
	);
})
.action_({
	arg obj;
	var qual;
	qual = obj.value.linlin(0,1,0pi,2pi);
	if(
		y.isPlaying,
		{y.set(\sinPhD, qual)}
	);
});
//~knob1.mode = \vert;
~phaseLabel1 = StaticText(w, Rect(385,60,92,20))
.string_("Phase(rads)")
.font_(Font("Monaco", 14))
.align_(\left)
;


~buttonOctUpOn = Button(w, Rect(220,125,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2,0.75,0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			z = Synth(
				\simpleSinUp,
				[
					\sinFreqU,
					~numberBoxOctUp.value,
					\sinPhU,
					~knobFundPh.value.linlin(0,1,0pi,2pi),
					\sinMultU,
					~knobFundMult.value.linlin(0,1,0.1,0.75)
					// changing .reciprocal here changes what end we start at on the knob. No reciprocal, no flip.
				],
		).register},
		{z.free}
	);
})
;
~numberBoxOctUp = NumberBox(w, Rect(20,125,75,30))
.canFocus_(false) // This works.
.value_(~numberBoxFund.value*2)
.clipLo_(~baseFund*2)
.clipHi_(~topFund*2)
.font_(Font("Monaco", 16))
.decimals_(3)
.scroll = 0 // disables scrolling
;
~freqLabel3 = StaticText(w, Rect(97,130,120,20))
.string_("Hz - Octave Up")
.font_(Font("Monaco", 14))
.align_(\left)
;
~knobUpMult = Knob(w, Rect(280,125,30,30)) // was 180, 20
.canFocus_(false) // This works.
.mouseWheelAction_({ | view, x, y, modifiers, xDelta, yDelta |
	if(
		yDelta == 15.0,
		{~knobUpMult.increment(10)}
	);
	if(
		yDelta == -15.0,
		{~knobUpMult.decrement(10)}
	);
})
.action_({
	arg obj;
	var qual;
	qual = obj.value.linlin(0,1,0.1,0.75);

	if(
		z.isPlaying,     // z is the Synth instance for this octave down
		{z.set(\sinMultU, qual)}
	);

});
~multLabel2 = StaticText(w, Rect(315,130,55,20))
.string_("Mult")
.font_(Font("Monaco", 14))
.align_(\left)
;

~knobUpPh = Knob(w, Rect(350,125,30,30)) // was 180,
.canFocus_(false) // This works. Want to make it a "Global" thing for Knobs
.mouseWheelAction_({ | view, x, y, modifiers, xDelta, yDelta |
	if(
		yDelta == 15.0,
		{~knobUpPh.increment(10)}
	);
	if(
		yDelta == -15.0,
		{~knobUpPh.decrement(10)}
	);
})
.action_({
	arg obj;
	var qual;
	qual = obj.value.linlin(0,1,0pi,2pi);
	if(
		x.isPlaying,
		{x.set(\sinPhU, qual)}
	);
});
~phaseLabel2 = StaticText(w, Rect(385,130,92,20))
.string_("Phase(rads)")
.font_(Font("Monaco", 14))
.align_(\left)
;



// see about changing the increment/decrement scales for one of the combo keys to exponential?
~slider = Slider(w, Rect(20,20,450,30))
.background_(Color(0.2,0.75,0.95))
//.step_(4/1000)    // saw it somewhere (40 steps total)  (using this changes the global step and messes up the nice steps for the numberBox)
.shift_scale_(~octaveRatio)    // I currently have the magic number for the octave.

// 12-TeT
//.ctrl_scale_(~twelveTETsT)    // matches 12-TeT quite well!
//.alt_scale_(~twelveTETsT/100) // trying for cents, and it seems to work!!

//19-TeT
.ctrl_scale_(~nineteenTETmT)    // should match 19-TeT
.alt_scale_(~nineteenTETmT/100) // note quite cents, but smaller!!
//~twelveTETsT = (~octaveRatio/12);
//~nineteenTETmT = (~octaveRatio/19);


.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0,1,~baseFund,~topFund);    // was originally combined in one line with next line
	//cf.postln;
	if(
		x.isPlaying,
		{
			x.set(\sinFreq, cf);
			//~slider.increment = (~slider.step.value*2);
		}
	);
	if(
		y.isPlaying,
		{y.set(\sinFreqD, cf/2)}
	);
	if(
		z.isPlaying,
		{z.set(\sinFreqU, cf*2)}
	);
	~numberBoxFund.value_(obj.value.linexp(0,1,~baseFund,~topFund));
	~numberBoxOctDown.value = (cf/2);
	~numberBoxOctUp.value = (cf*2);
})
/*.alt_scale_({
arg obj;
var cf;
cf = obj.value.linlin(0,1,200,1000);
(cf).pow(20)
})*/
;
//~slider.alt_scale.value;
//\cf;



// Omni button On
~buttonOmniOn = Button(w, Rect(220,160,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2,0.75,0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if (~buttonFundOn.value == 1 && ~buttonOctUpOn.value == 1 && ~buttonOctDownOn.value == 1, obj.value = 1, obj.value = 0);
	if(
		obj.value == 1,
		//{~buttonFundOn.value.postln},    // this works, and it's a start
		{
			if (~buttonFundOn.value == 1, {"The Fundamental tone should play...".postln}, {~buttonFundOn.valueAction = 1}    // valueAction make sure the object in question actually performs its function!
			);
			if (~buttonOctUpOn.value == 1, {"The Octave Up tone should be playing...".postln}, {~buttonOctUpOn.valueAction = 1}
			);
			if (~buttonOctDownOn.value == 1, {"The Octave Down tone should be playing...".postln}, {~buttonOctDownOn.valueAction = 1}
			);
		},
		if (~buttonFundOn.value == 0, {"The Fundamental tone should stop playing...".postln}, {~buttonFundOn.valueAction = 0}
		);
		if (~buttonOctUpOn.value == 0, {"The Octave Up tone should stop playing...".postln}, {~buttonOctUpOn.valueAction = 0}
		);
		if (~buttonOctDownOn.value == 0, {"The Octave Down tone should stop playing...".postln}, {~buttonOctDownOn.valueAction = 0}
		);
		//{x.free}
		// find a bit of code to quiet the click when turning on and off. Will probably need to be in the SynthDef code
	);
});

~lagTime = 0.75;   // this almost makes it sound like Portomento!

SynthDef.new(\simpleSin, {
	arg sinFreq, sinPh, sinMult;
	var sig;
	sig = [SinOsc.ar(sinFreq.lag(~lagTime), sinPh, sinMult), SinOsc.ar(sinFreq.lag(~lagTime), sinPh, sinMult)];
	// binaural beats can be achieved by adding a number of Hz to either sinFreq side!! (sinFreq+10)
	// the trick of having two frequencies in an array, for the freq argument doesn't seem to work here
	//sig = sig.lag(0.5);
	Out.ar(0!1, sig); // the 0!1 seems to make it stereo
}).add;  // taking this .add away makes this not work at all.
// may need to add more SynthDefs for the other octaves?
SynthDef.new(\simpleSinDown, {
	arg sinFreqD, sinPhD, sinMultD;
	var sig;
	sig = [SinOsc.ar(sinFreqD.lag(~lagTime), sinPhD, sinMultD), SinOsc.ar(sinFreqD.lag(~lagTime), sinPhD, sinMultD)];
	// binaural beats can be achieved by adding a number of Hz to either sinFreq side!! (sinFreq+10)
	Out.ar(0!1, sig); // the 0!1 seems to make it stereo
}).add;  // taking this .add away makes this not work at all.
SynthDef.new(\simpleSinUp, {
	arg sinFreqU, sinPhU, sinMultU;
	var sig;
	sig = [SinOsc.ar(sinFreqU.lag(~lagTime), sinPhU, sinMultU), SinOsc.ar(sinFreqU.lag(~lagTime), sinPhU, sinMultU)];
	// binaural beats can be achieved by adding a number of Hz to either sinFreq side!! (sinFreq+10)
	Out.ar(0!1, sig); // the 0!1 seems to make it stereo
}).add;  // taking this .add away makes this not work at all.

)
)


// add a board below, with momentary buttons, that will play a specified note, out of 8, in several octaves.


