Server.killAll;

s.boot;

~sinFreq[0];  // check the values
~sinFreq;

(
Server.default.waitForBoot({

	// Window.closeAll;
	// trying to see if I can have two windows open at once.
	// I may need to have the window variables different, as I believe they are Environment variables
	// So, this app can open at the same time as the Generator_Final_5, BUT, as  many of the variables are named the same, and not all objects are set to the same ranges, we encounter problems between the two.

	w = Window.new("Tone-Board", Rect(5, 418, 500, 200))  // does not seem to work for the width and height
	.front;
	w.alwaysOnTop = true;

	w.onClose = {s.freeAll; "Done!".postln; "".postln};
	CmdPeriod.doOnce({w.close});

	~baseFund = 120.00;
	~topFund = (~baseFund*(4.pow(2)));
	// ~sinFreq = ~baseFund;
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
	l = DragSource(w, Rect(150, 200, 180, 300))
	.align_(\center)

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




	// rig up the array!!
	~bUp = Array.fill(8, { |i| // this is the button index
		Button.new()
		.states_([["240", Color.black, Color.rand]])
		.mouseOverAction_({~helpView.string = "Mouse over whatever button is playing, and it should turn off once the cursor leaves!";
		})
		.mouseDownAction_({
			~sin2[i] = 2*~sinFreq[i];
			~synthArr[i+16] = Synth(
				\env_help,
				[
					"sinFreq",
					(~sin2[i])/*.postln*/
				],
			).register;
			("Sound playing is "++~sin2[i]++"Hz").postln;
		})

		.mouseLeaveAction_({
			if(~synthArr[i+16].isPlaying,{ ~synthArr[i+16].release(~releaseTime);});
		})   // this is the action working when I have pressed Spacebar when the button is active


		.mouseUpAction_({
			~synthArr[i+16].release(~releaseTime);
		})

		.beginDragAction_({~bUp[i].string.asFloat})   // THIS IS ALL I NEEDED TO DO!!!!!

		// setting the release value below works! Otherwise, it's a default value which is kinda long
		.action_({
			~sin2[i] = 2*~sinFreq[i];
			if(
				~synthArr[i+16].isPlaying,
				{("Sound played was "++~sin2[i]++"Hz").postln; ~synthArr[i+16].release(~releaseTime);},
				{~synthArr[i+16] = Synth(\env_help,
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

	~bFund = Array.fill(8, { |i| // this is the button index
	// ~bFund = Array.fill(8, { |view| // this is the button index
		Button()
		.states_([["120", Color.black, Color.rand]])
		.mouseOverAction_({~helpView.string = "Mouse over whatever button is playing, and it should turn off once the cursor leaves!";
			// View.currentDrag.postln; // will post only if the help button is on, and after the drag has been dropped, when the currentDrag value is nil. May have to make another dragSink to test this?
		})
		.mouseDownAction_({ |view|
			//trying to figure out if this is the right way to go about getting/setting this value
			("The string at the button just pressed is "++~bFund[i].string).postln;

			~synthArr[i+8] = Synth(         // just put the [i] on the y's... think it fucked it up
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
			if(~synthArr[i+8].isPlaying,{ ~synthArr[i+8].release(~releaseTime);});
		})   // this is the action working when I have pressed Spacebar when the button is active


		.mouseUpAction_({ |view|
			~synthArr[i+8].release(~releaseTime);
		})

		.action_({
			// trying to get the Synths instantiated for the middle row
			if(
				~synthArr[i+8].isPlaying, {("Sound played was "++~sinFreq[i]++"Hz").postln; ~synthArr[i+8].release(~releaseTime)}, {~synthArr[i+8] = Synth(
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





	~bDown = Array.fill(8, { |i| // this is the button index
		Button()
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

	~synthArr = Array.fill(24, { |i| // this is the button index
		// The way my code works, currently, there must be a value at [i] initially or we get "Deactivated nil"
		i = 0
		// now they all start with 0, instead of nothing!
	});

	// might be able to figure out how to just have the ~sinFreq array, and not an array for each octave?
	~sinFreq = Array.fill(8, { |i| // this is the button index
		// The way my code works, currently, there must be a value at [i] initially or we get "Deactivated nil"
		i = 120
		// now they all start with 0, instead of nothing!
	});

	~sin2 = Array.fill(8, { |i| // this is the button index
		// The way my code works, currently, there must be a value at [i] initially or we get "Deactivated nil"
		i = 240
		// now they all start with 0, instead of nothing!
	});
	~sin1_2 = Array.fill(8, { |i| // this is the button index
		// The way my code works, currently, there must be a value at [i] initially or we get "Deactivated nil"
		i = 60
		// now they all start with 0, instead of nothing!
	});



	w.layout = VLayout(HLayout(HLayout(*~helpButton),HLayout(*~helpView),HLayout(*l),HLayout(*j)),HLayout(*~numberBoxFund),HLayout(*d),HLayout(*c),HLayout(*e),HLayout(*~bUp),HLayout(*~bFund),HLayout(*~bDown));
	// This should work, once I hone it


	// the SynthDef works just fine down here, out of the clutter
	// needed to put sinFreq up in with the arguments for this SynthDef!!! now it works!
	SynthDef(\env_help, { | sinFreq, out, gate = 0.1, amp = 0.5, release = 0.1|
		var env = Env.adsr(0.02, release, amp);
		var gen = [SinOsc.ar(freq: sinFreq, phase: 0.0, mul: 0.5) * EnvGen.kr(env, gate, doneAction: Done.freeSelf), SinOsc.ar(freq: sinFreq, phase: 0.0, mul: 0.5) * EnvGen.kr(env, gate, doneAction: Done.freeSelf)];

		Out.ar(out, gen)
	}).add;  // taking this .add away makes this not work at all.


})
;
)

~noteFundArr[1];   // doesn't know what's up???

~majScale.size;