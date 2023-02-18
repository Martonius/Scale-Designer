Server.killAll;

s.boot;

~octaveRatio.postln;  // ???

(
Server.default.waitForBoot({

	// Window.closeAll;
	// trying to see if I can have two windows open at once.
	// I may need to have the window variables different, as I believe they are Environment variables
	// So, this app can open at the same time as the Generator_Final_5, BUT, as  many of the variables are named the same, and not all objects are set to the same ranges, we encounter problems between the two.

	w = Window.new("Generator_and_Tone-Board", Rect(40, 75, 740, 550))  // does not seem to work for the width and height
	.front
	// .maxWidth_(600)   // try using Decorator_Flow-Layout instead???
	;
	// w.alwaysOnTop = true;

	w.onClose = {s.freeAll; "Done!".postln; "".postln};
	CmdPeriod.doOnce({w.close});

	//////////////////////////////////////////
	// ADDING THE TONE GENERATOR HERE, AND THERE WILL BE PLENTY OF REDUNDANCIES

	// I must create room for all the additional objects here in the layout

	Knob.defaultMode = \vert; // makes it so each knob doesn't have to be set individually
	//Knob.canFocus = false; // this doesn't seem to want to work as a global setting



	// NEED ALL THE VARIABLES UP HERE, TO DECREASE THE REDUNDANCY AND ORGANIZE STUFF
	~baseFund = 120;   // was 110
	~topFund = (~baseFund*4.pow(2));
	// ~octaveRatio = (10.34408.pow(2));   // this was once working correctly, somehow.
	~octaveRatio = (2.5099999*(10.pow(2)));  // now this is what seems to work correctly
	// correct this whenever it's not working, and figure out why it's not always calculating correctly
	~twelveTETsT = (~octaveRatio/12);
	~nineteenTETmT = (~octaveRatio/19);


	~buttNum = 12;   // originally 8, got it working and scalable
	~nTeT = (~octaveRatio/~buttNum);    // this should scale the slider output to the number of buttons
	// already have an ~nTet down below?

	// adding the variables here, from the Tone Board code below
	~sinFreq;
	~sin1_2;
	~sin2;
	~releaseTime = 0.1;
	~noteFundArr;


	~allFreqs;

	// 1.05946 is supposedly the 12-TeT ratio, on Wikipedia it's (approximately 1.059463) and calculated, it's 1.059463094
	//~twelveTet = 1.059463094359295;   // any note ratio could be substituted here for other Equal temperaments
	~divET = 12.0;
	~nTet = (2.pow(1/~divET));
	~nTet1 = ~nTet - 1;  // i had somehow erased this and made it not function
	~nTet2 = (~nTet1 * 2.059463094359295) + 1.0;  // pretty sure this is how we would get the ratio for a tone up, rather than a semitone
	/*~majScale = [~nTet2,~nTet2,~nTet,~nTet2,~nTet2,~nTet2,~nTet,~nTet2,~nTet2,~nTet,~nTet2,~nTet2,~nTet2,~nTet,~nTet2,~nTet2,~nTet,~nTet2,~nTet2,~nTet2,~nTet,~nTet2,~nTet2,~nTet,~nTet2,~nTet2,~nTet2,~nTet,~nTet];*/

	// trying the wrapAt method, and it WORKS!!!!!
	~majScale = [~nTet2,~nTet2,~nTet,~nTet2,~nTet2,~nTet2,~nTet,~nTet];

	// With this set up... I believe I can institute more buttons... or forget about the above and below octave buttons

	// somehow, my "a" row is screwed up?!!



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
	~numberBoxFund_Gen = NumberBox(w, Rect(20,90,75,30))
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
	~multLabel2 = StaticText(w, Rect(315,95,55,20))
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
	~phaseLabel2 = StaticText(w, Rect(385,95,92,20))
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
	.value_(~numberBoxFund_Gen.value/2)
	.clipLo_(~baseFund/2)
	.clipHi_(~topFund/2)
	.font_(Font("Monaco", 16))
	.decimals_(3)
	.scroll = 0 // disables scrolling
	;
	~freqLabel3 = StaticText(w, Rect(97,60,120,20))
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
	~multLabel3 = StaticText(w, Rect(315,60,55,20))
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
	~phaseLabel3 = StaticText(w, Rect(385,60,92,20))
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
	.value_(~numberBoxFund_Gen.value*2)
	.clipLo_(~baseFund*2)
	.clipHi_(~topFund*2)
	.font_(Font("Monaco", 16))
	.decimals_(3)
	.scroll = 0 // disables scrolling
	;
	~freqLabel1 = StaticText(w, Rect(97,130,120,20))
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
	~multLabel1 = StaticText(w, Rect(315,130,55,20)) // may be able to use the same object in the  layout a few times, if nothing changes besides the location?
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
	~phaseLabel1 = StaticText(w, Rect(385,130,92,20))
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
	// .ctrl_scale_(~nineteenTETmT)    // should match 19-TeT when holding the CTRL key and scrolling?
	// .alt_scale_(~nineteenTETmT/100) // note quite cents, but smaller!!
	//~twelveTETsT = (~octaveRatio/12);
	//~nineteenTETmT = (~octaveRatio/19);

	// n-TeT
	.ctrl_scale_(~nTeT)    // should match 19-TeT when holding the CTRL key and scrolling?
	.alt_scale_(~nTeT/100) // note quite cents, but smaller!!
	// it wasn't working, because I had nTeT spelled incorrectly :0


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
		~numberBoxFund_Gen.value_(obj.value.linexp(0,1,~baseFund,~topFund));
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



	// END OF TONE GENERATOR CODE






	/*w.bounds.postln;
	w.bounds;
	w.bounds(\height).postln;
	w.bounds.height.postln; // THAT'S THE TICKET!!!!*/


	// Just moved these up from the bottom!
	// ~helpButton = Button(w, Rect((w.bounds+100),12,12,12))
	// ~helpButton = Button(w, Rect(w.bounds.left-90,0,50,w.bounds.height/20))
	~helpButton = Button(w, Rect(10,2,30,500))
	.states_([["help", Color.black],["help:", Color.black, Color.gray]])
	// .maxWidth_(50)  // doesn't seem to help???
	.action_({|value|
		if(value.value == 0, {w.acceptsMouseOver_(false); ~helpView.string="";},
			{w.acceptsMouseOver_(true);
				~helpView.string = "Mouse over the number boxes/Views to see their description. Click and mouse up and down to change the values in it";
	})})
	.mouseOverAction_({~helpView.string = "Mouse over the number boxes/Views to see their description. Click and mouse up and down to change the values in it";
	})
	;
	// ~helpView = StaticText(w, Rect(w.bounds.left-290,0,50,w.bounds.height/20))
	~helpView = StaticText(w, Rect(50,2,30,30))
	.string_("")
	.minWidth_(350)  // just changed, to see if it changes where the freq readout is, and it does!
	.stringColor_(Color.black)
	;
	// trying this helpView shit from Operator


	k = KeyPlayer(\rd);

	// KeyPlayer button
	j = Button(w, Rect(100, 2, 180, 30))
	.states_([["KeyPlayer On when Activated"]])
	// .mouseOverAction_({~helpView.string = "Drag a frequency to the buttons for the\nbase frequency to change."})
	.mouseOverAction_({~helpView.string = "Drag a frequency to the buttons, then press/activate this button again for the frequencies to change."})
	.action_({ ~allFreqs = ~sin1_2++~sinFreq++~sin2;
		~allFreqs.postln;
	})
	;
	// ends the direct j button methods
	j.keyDownAction_({ |view, char, mod, uni|
		KeyPlayer(\rd).keyAction(char, mod, uni, which: \down);

		// ~noteFreq = ~sinFreq[0];
		// changing the above, so we start with the lowest tone
		~noteFreq = ~sin1_2[0];
		// may need to concat 3 arrays to get here with the button frequencies?


		/*~sinFreq;
		~sin1_2;
		~sin2;*/

		// "zxcvbnmasdfghjqwertyu12345678".do

		// different for the ~allFreqs
		"zxcvbnm,asdfghjkqwertyui".do
		// might have to figure out how to set frequencies for the number row as well?
		{
			|char, i|
			var noteFund = (freq: ~noteFreq, dur: 0, sustain: 0.5);


			// Environmental variety... may not work correctly
			// ~noteFund = (freq: ~noteFreq, dur: 0, sustain: 0.5);

			// the line above illustrates what we can still do when shrinking the scope of a variable
			// ~noteFreq = ~noteFreq * (~majScale[i].postln);

			// try to fill the noteFundArr with these frequencies?
			// ~noteFundArr[i] = ~noteFreq;
			// ("The ~noteFundArr is filled as such: "++~noteFundArr[0]).postln;
			// ~noteFundArr[i] = noteFund[\freq];
			// not sure that's doing anything, but I have ~allFreqs going


			// ~noteFreq = ~noteFreq * (~majScale[i]);
			// trying the wrapAt method, and it WORKS!!!
			// ~noteFreq = ~noteFreq * (~majScale.wrapAt[i]);

			// trying the ~allFreqs now
			/*~noteFreq = ~allFreqs[i];*/
			// this kinda works, but there were more notes in the majScale thing
			// trying a change?
			~noteFreq = ~allFreqs[i+1];
			// the above somehow works better, otherwise the notes were shifted one index

			k.put(char, { (noteFund[\freq]).postln; noteFund.play });

			// k.put(char, { (noteFund[\freq]).asStringPrec(6).postln; noteFund.play });
			// the above works for all but the fundamental note, somehow???

			// k.put(char, { (noteFund[\freq]); noteFund.play });

			// Environmental variety
			// k.put(char, { (~noteFund[\freq]).postln; ~noteFund.play });

			// the line above illustrates how we can get/set a property of an object variable
			// l.string = (noteFund[\freq]).asInteger;  // perhaps cast as a different number type?
			// l.string = (noteFund[\freq]).asFloat(3);  // too many decimal points, I think
			// l.string = (noteFund[\freq]).asStringPrec(6)  // this is the way...maybe
			// l.string = (noteFund[\freq]).asCompileString  // this is the way...maybe
			// l.string = ~noteFreq.asStringPrec(6)  // this is the way...maybe
			// not sure if the above is doing what I want it to do
		};

	});

	j.keyUpAction_({ |view, char, mod, uni|
		KeyPlayer(\rd).keyAction(char, mod, uni, which: \up); // may need to add to the actions here, and change the sinFreq when this button is pressed to correspond with the new values
		// l.string = ~noteFreq.asStringPrec(6);  // this is the way...maybe?
	})
	;  // there was a problem here with not having the semicolon at the end. Always use one after a function, even the last one!!!


	// shows the frequency of the last played note, instead of posting to the Post Window
	/*l = DragSource(w, Rect(150, 200, 180, 300))*/
	l = DragSource()
	.align_(\center)
	// .visible_(false)  // taking away the bounds/coordinates and not having the object in the layout seems to do the same thing as making the visible false

	;


	~numberBoxFund = NumberBox(w, Rect(20, 20, 75, 30)).align_(\center)
	.value_(~baseFund)
	.clipLo_(~baseFund)
	.clipHi_(~topFund)
	.font_(Font("Monaco", 16))
	.decimals_(3)
	.action_({
		arg obj;
		//~slider.valueAction_(obj.value.explin(~baseFund,~topFund,0,1))
		c.object = obj.value;
		d.object = obj.value*2;
		e.object = obj.value/2;
	})
	.dragLabel_("stop dragging me") // doesn't seem to do much, unless I have ctrl pressed
	.ctrl_scale_(0.005)
	;



	// The following do not need the CMD/CTRL key pressed to initiate dragging.

	// a Float source   (octUp)
	d = DragSource(w, Rect(20, 50, 75, 30)).align_(\center)
	.canFocus_(false) // This works.
	;
	//b.object = ~numberBoxFund.value;
	d.object = ~baseFund*2;

	// a Float source   (Fund)
	c = DragSource(w, Rect(20, 80, 75, 30)).align_(\center)
	.canFocus_(false) // This works.
	;
	//b.object = ~numberBoxFund.value;
	c.object = ~baseFund;

	// a Float source    (octDown)
	e = DragSource(w, Rect(20, 110, 75, 30)).align_(\center)
	.canFocus_(false) // This works.
	;
	//b.object = ~numberBoxFund.value;
	e.object = ~baseFund/2;



	// Test area for sinking Dragged content
	~sinker = DragSink(w, Rect(((j.bounds.width*2.5)/1.5),10,100,40))
	.align_(\center)
	.visible = false  // removed object from view, but keeping for troubleshooting purposes

	// .canReceiveDragHandler_{ View.currentDrag.isKindOf(Number) || View.currentDrag.isKindOf(Point) }
	;  // only seems to be able to receive the drag on the edge of the box? May have somehting to do with its size?



	// See about making the button color PULSE at a fraction of the rate it's playing at, when it is playing


	// now trying to set up a variable, so I can create as many buttons for each row as I want
	// while the above won't work with the KeyPlayer, so much, it'll work for the buttons
	// rig up the array!!
	~bUp = Array.fill(~buttNum, { |i| // this is the button index
		Button.new()
		.states_([["240", Color.black, Color.rand]])
		.mouseOverAction_({~helpView.string = "Mouse over whatever button is playing, and it should turn off once the cursor leaves!";
		})
		.mouseDownAction_({
			~sin2[i] = 2*~sinFreq[i];
			~synthArr[i+(~buttNum*2)] = Synth(
				\env_help,
				[
					"sinFreq",
					(~sin2[i])/*.postln*/
				],
			).register;
			("Sound playing is "++~sin2[i]++"Hz").postln;
		})

		.mouseLeaveAction_({
			if(~synthArr[i+(~buttNum*2)].isPlaying,{ ~synthArr[i+(~buttNum*2)].release(~releaseTime);});
		})   // this is the action working when I have pressed Spacebar when the button is active


		.mouseUpAction_({
			~synthArr[i+(~buttNum*2)].release(~releaseTime);
		})

		.beginDragAction_({~bUp[i].string.asFloat})   // THIS IS ALL I NEEDED TO DO!!!!!

		// setting the release value below works! Otherwise, it's a default value which is kinda long
		.action_({
			~sin2[i] = 2*~sinFreq[i];
			if(
				~synthArr[i+(~buttNum*2)].isPlaying,
				{("Sound played was "++~sin2[i]++"Hz").postln; ~synthArr[i+(~buttNum*2)].release(~releaseTime);},
				{~synthArr[i+(~buttNum*2)] = Synth(\env_help,
					[
						"sinFreq",
						~sin2[i]/*.postln*/
					],
				).register;}

			)
		})
	})
	// think i just want to drag to the middle set of buttons...
	/*.receiveDragHandler_({ arg obj;
	~sinFreq = View.currentDrag;  // had .postln here, but not necessary if I am changing the button text
	obj.string = View.currentDrag;
	})*/
	;  // end of button methods






	/// middle row, Fundamental buttons

	~bFund = Array.fill(~buttNum, { |i| // this is the button index
		// ~bFund = Array.fill(8, { |view| // this is the button index
		Button()
		.states_([["120", Color.black, Color.rand]])
		.mouseOverAction_({~helpView.string = "Mouse over whatever button is playing, and it should turn off once the cursor leaves!";
			// View.currentDrag.postln; // will post only if the help button is on, and after the drag has been dropped, when the currentDrag value is nil. May have to make another dragSink to test this?
		})
		.mouseDownAction_({ |view|
			//trying to figure out if this is the right way to go about getting/setting this value
			("The string at the button just pressed is "++~bFund[i].string).postln;

			~synthArr[i+~buttNum] = Synth(         // just put the [i] on the y's... think it fucked it up
				// trying with the Synth Array, here
				\env_help,
				[
					\sinFreq,
					~sinFreq[i]/*.postln*/
				],
			).register;
			("Sound playing is "++~sinFreq[i]++"Hz").postln;
		})

		// need to figure out the beginDragAction
		/*.beginDragAction_({ |view|
		// View.currentDragString = ~bFund[i].currentDrag;
		// ~bFund[i].currentDrag = View.currentDragString;
		// make it do something, if necessary.
		})*/
		/*.beginDragAction_({ |item|


		})*/

		.mouseLeaveAction_({
			if(~synthArr[i+~buttNum].isPlaying,{ ~synthArr[i+~buttNum].release(~releaseTime);});
		})   // this is the action working when I have pressed Spacebar when the button is active


		.mouseUpAction_({ |view|
			~synthArr[i+~buttNum].release(~releaseTime);
		})

		.action_({
			// trying to get the Synths instantiated for the middle row
			if(
				~synthArr[i+~buttNum].isPlaying, {("Sound played was "++~sinFreq[i]++"Hz").postln; ~synthArr[i+~buttNum].release(~releaseTime)}, {~synthArr[i+~buttNum] = Synth(
					\env_help,
					[
						\sinFreq,
						~sinFreq[i]/*.postln*/
					],
				).register;}

			)
		})

		.beginDragAction_({~bFund[i].string.asFloat})   // THIS IS ALL I NEEDED TO DO!!!!!


		// Got the DragHandler working correctly!!!
		.receiveDragHandler_({ |view|    // No longer nil!!!!!

			// ~bFund[i].string = View.currentDrag.asInteger;  // with this, and |view| as the argument, I am actually getting the string to change now (may need a different "as" to get the decimal values that will show up)
			// Time to get this value changed for the frequency in the associated Synth, as well!!!
			~bFund[i].string = View.currentDrag;   // not asInteger

			~sinFreq[i] = ~bFund[i].string;

			// trying something (these work, now that 'view' is the argument)
			~bDown[i].string = ~sinFreq[i]/2.0;
			// nowe changes the string, and the frequency at that button
			~sin1_2[i] = ~bDown[i].string;

			~bUp[i].string = ~sinFreq[i]*2.0;
			// seems to change the string, but not the frequency at that button
			~sin2[i] = ~bUp[i].string;


			// try to get the focuse to change to the KeyPlayer button when a value is dragged!

			// having this here instantly changes the KeyPlay freqs when a freq value is dragged
			~noteFreq = ~sinFreq[0];




		})

	})
	;  // end of button methods

	/*View.mouseMoveAction_({
	//if(a.isPlaying,{ a.free;});  // was {a.release; 1.wait; a.free;} , but not working (it works with a.free;)
	a.release;
	});*/





	~bDown = Array.fill(~buttNum, { |i| // this is the button index
		Button()
		// may need to move towards making the initial state half that of the button above it?
		.states_([["60", Color.black, Color.rand]])
		.mouseOverAction_({~helpView.string = "Mouse over whatever button is playing, and it should turn off once the cursor leaves!";
		})
		.mouseDownAction_({ |view|
			~sin1_2[i] = ((~sinFreq[i])/2);
			~synthArr[i] = Synth(
				\env_help,
				[
					"sinFreq",
					~sin1_2[i]/*.postln*/
				],
			).register;
			("Sound playing is "++~sin1_2[i]++"Hz").postln;
		})

		.mouseLeaveAction_({
			if(~synthArr[i].isPlaying,{ ~synthArr[i].release(~releaseTime);});  // we don't just call .release, because it throws an error
		})   // this is the action working when I have pressed Spacebar when the button is active


		.mouseUpAction_({
			~synthArr[i].release(~releaseTime);
		})

		.beginDragAction_({~bDown[i].string.asFloat})   // THIS IS ALL I NEEDED TO DO!!!!!

		.action_({ |view|
			~sin1_2[i] = ((~sinFreq[i])/2);
			if(
				~synthArr[i].isPlaying, {("Sound played was "++~sin1_2[i]++"Hz").postln; ~synthArr[i].release(~releaseTime)}, {~synthArr[i] = Synth(
					\env_help,
					[
						"sinFreq",
						~sin1_2[i]/*.postln*/
					],
				).register;}

			)
		})
	})
	// think I just want to drag to the middle set of buttons...
	/*.receiveDragHandler_({ arg obj;
	~sinFreq = View.currentDrag;  // had .postln here, but not necessary if I am changing the button text
	obj.string = View.currentDrag;
	})*/
	;  // end of button methods








	// Synth and sinFreq arraya

	~synthArr = Array.fill((~buttNum*3), { |i| // this is the button index
		// The way my code works, currently, there must be a value at [i] initially or we get "Deactivated nil"
		i = 0
		// now they all start with 0, instead of nothing!
	});

	// might be able to figure out how to just have the ~sinFreq array, and not an array for each octave?
	~sinFreq = Array.fill(~buttNum, { |i| // this is the button index
		// The way my code works, currently, there must be a value at [i] initially or we get "Deactivated nil"
		i = 120
		// now they all start with 0, instead of nothing!
	});

	~sin2 = Array.fill(~buttNum, { |i| // this is the button index
		// The way my code works, currently, there must be a value at [i] initially or we get "Deactivated nil"
		i = 240
		// now they all start with 0, instead of nothing!
	});
	~sin1_2 = Array.fill(~buttNum, { |i| // this is the button index
		// The way my code works, currently, there must be a value at [i] initially or we get "Deactivated nil"
		i = 60
		// now they all start with 0, instead of nothing!
	});


	// Getting there with the LAYOUT!!!
	w.layout =
	VLayout(
		VLayout(*~slider),
		HLayout(
			VLayout(HLayout(*~numberBoxOctUp),HLayout(*~numberBoxFund_Gen),HLayout(*~numberBoxOctDown)),
			VLayout(HLayout(*~freqLabel1),HLayout(*~freqLabel2),HLayout(*~freqLabel3)),
			VLayout(HLayout(*~knobUpMult),HLayout(*~knobFundMult),HLayout(*~knobDownMult)),
			VLayout(HLayout(*~multLabel1),HLayout(*~multLabel2),HLayout(*~multLabel3)),
			VLayout(HLayout(*~knobUpPh),HLayout(*~knobFundPh),HLayout(*~knobDownPh)),
			VLayout(HLayout(*~phaseLabel1),HLayout(*~phaseLabel2),HLayout(*~phaseLabel3)),
			VLayout(HLayout(*~buttonOctUpOn),HLayout(*~buttonFundOn),HLayout(*~buttonOctDownOn)),	VLayout(HLayout(*~buttonOmniOn))),
		VLayout(HLayout(*~numberBoxFund),HLayout(*d),HLayout(*c),HLayout(*e),HLayout(*~bUp),HLayout(*~bFund),HLayout(*~bDown)),
		// VLayout(HLayout(*~helpButton),HLayout(*~helpView),HLayout(*l),HLayout(*j))
		VLayout(HLayout(*~helpButton),HLayout(*~helpView),HLayout(*j))
	);
	// This should work, once I hone it
	// Get rid of any redundant objects.

	/*
	~freqLabel2
	~multLabel
	~phaseLabel
	~freqLabel1
	~multLabel1
	~phaseLabel1
	~freqLabel3
	~multLabel2
	~phaseLabel2
	~numberBoxFund_Gen.value_(obj.value.linexp(0,1,~baseFund,~topFund));
	~numberBoxOctUp.value
	~numberBoxOctDown.value = (cf/2);
	~buttonOmniOn = Button(w, Rect(220,160,50,30))
	if (~buttonFundOn.value == 1 && ~buttonOctUpOn.value == 1 && ~buttonOctDownOn
	~knobDownPh
	~knobDownMult
	*/


	// the SynthDef works just fine down here, out of the clutter
	// needed to put sinFreq up in with the arguments for this SynthDef!!! now it works!
	SynthDef(\env_help, { | sinFreq, out, gate = 0.1, amp = 0.5, release = 0.1|
		var env = Env.adsr(0.02, release, amp);
		var gen = [SinOsc.ar(freq: sinFreq, phase: 0.0, mul: 0.5) * EnvGen.kr(env, gate, doneAction: Done.freeSelf), SinOsc.ar(freq: sinFreq, phase: 0.0, mul: 0.5) * EnvGen.kr(env, gate, doneAction: Done.freeSelf)];

		Out.ar(out, gen)
	}).add;  // taking this .add away makes this not work at all.

	// moved these suckers down from up in the Generator code
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


})
;
)