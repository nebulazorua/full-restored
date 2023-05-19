package meta.state.menus;

import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import gameObjects.userInterface.menu.Textbox;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import meta.MusicBeat.MusicBeatSubState;
using StringTools;

class BindSubstate extends MusicBeatSubState{
	var centralTextbox:Textbox;
    var bindTextbox:Textbox;
	var popupTitle:FlxText;
	var popupText:FlxText;
	var unbindText:FlxText;
    
	var expanseHorizontal:Float;
	var expanseVertical:Float;
	var defaultExpanseHorizontal:Float;
	var defaultExpanseVertical:Float;

	var forcedBind:Array<String> = [
		'UI_UP',
		'UI_DOWN',
		'UI_LEFT',
		'UI_RIGHT',
		'ACCEPT',
		'BACK'
	];

	var binds:Array<Array<String>> = [
		['Gameplay'],
		['Left', 'LEFT'],
		['Down', 'DOWN'],
		['Mechanic', 'SPACE'],
		['Up', 'UP'],
		['Right', 'RIGHT'],
		['Pause', 'PAUSE'],
		['UI'],
		['Up', 'UI_UP'],
		['Down', 'UI_DOWN'],
		['Left', 'UI_LEFT'],
		['Right', 'UI_RIGHT'],
		['Accept', 'ACCEPT'],
		['Back', 'BACK']
	];

	var bindID:Int = 0;
	var bindTexts:Array<Array<FlxText>> = []; // the actual bind buttons. used for input etc lol
	var internals:Array<String> = [];
	var displays:Array<String> = [];

    var curSelected:Int = 0;

    var rebinding:Bool = false;
    var scrollableCamera:FlxCamera; // smth i learnt from riconuts and tgt!! thanks riconuts and tgt!!
	// .. isnt ACTUALLY necessary for this but im gonna keep it because it makes positioning stuff a lil bit easier
	var overlayCamera:FlxCamera;

	var selector:FlxSprite;
	private function getStringKey(?arrayThingy:FlxKey=NONE):String
	{
		if (arrayThingy==null)return '---';
		if (arrayThingy==NONE)return '---';

		var keyString:String = '---';
		keyString = arrayThingy.toString();
		keyString = keyString.replace(" ", "");

		return keyString;
	}

    override function create(){
		var bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		bg.alpha = 0.5;

		centralTextbox = new Textbox(0, 0);
		centralTextbox.screenCenter();
		centralTextbox.scale.set(3, 3);
		centralTextbox.boxHeight = 0;
		centralTextbox.boxWidth = 0;
		expanseHorizontal = 20;
		expanseVertical = 16;

		bindTextbox = new Textbox(0, 0);
		bindTextbox.screenCenter();
		bindTextbox.scale.set(3, 3);
		bindTextbox.boxWidth = 14;
        bindTextbox.boxHeight = 6;
		bindTextbox.update(0);

		defaultExpanseVertical = expanseVertical;
		defaultExpanseHorizontal = expanseHorizontal;

		scrollableCamera = new FlxCamera();
		overlayCamera = new FlxCamera();
		overlayCamera.bgColor = FlxColor.BLACK;
		overlayCamera.bgColor.alpha = 127;
		overlayCamera.visible = false;

        scrollableCamera.x = centralTextbox.x;
        scrollableCamera.y = centralTextbox.y;
		scrollableCamera.bgColor.alpha = 0;

        FlxG.cameras.add(scrollableCamera, false); 
		FlxG.cameras.add(overlayCamera, false); 
		add(bg);
		add(centralTextbox);

        // NGL most of this is just stolen from TGT

		var centerX = centralTextbox.x - (centralTextbox.width / 2);
		var centerY = centralTextbox.y - (centralTextbox.height / 2);
		var width = expanseHorizontal * 9 * 3;
		var height = expanseVertical * 9 * 3;

		var daY:Float = 0;
		for (data in binds){
			var label = data[0];
			if(data.length>1){
				// bind
				var internal = data[1];
				var keys = Init.gameControls.get(internal)[0];
				var label:FlxText = new FlxText(4.5, daY, width, label, 12);
				label.setFormat(Paths.font("poketext.ttf"), 16, 0xFF000000, FlxTextAlign.LEFT);
				var text1:FlxText = new FlxText(0 + 150, daY, 150, getStringKey(keys[0]), 12);
				text1.setFormat(Paths.font("poketext.ttf"), 16, 0xFF000000, FlxTextAlign.CENTER);
				var text2:FlxText = new FlxText(0 + 350, daY, 150, getStringKey(keys[1]), 12);
				text2.setFormat(Paths.font("poketext.ttf"), 16, 0xFF000000, FlxTextAlign.CENTER);
				bindTexts.push([text1, text2]);
				internals.push(internal);
				displays.push(label.text);
				label.cameras = [scrollableCamera];
				text1.cameras = [scrollableCamera];
				text2.cameras = [scrollableCamera];
				add(label);
				add(text1);
				add(text2);
				daY += label.height;
			}else{
				var label:FlxText = new FlxText(0, daY, width, label, 12);
				label.setFormat(Paths.font("poketext.ttf"), 24, 0xFF000000, FlxTextAlign.CENTER);
				label.cameras = [scrollableCamera];
				daY += label.height;
				add(label);
			}
		}

		selector = new FlxSprite();
		selector.loadGraphic(Paths.image('UI/pixel/selector'));
		selector.scrollFactor.set();
		selector.scale.set(2, 2);
		selector.updateHitbox();
		selector.cameras = [scrollableCamera];
		add(selector);
		selector.x = bindTexts[0][0].x - 10;
		selector.y = bindTexts[0][0].y;

		var centerX = bindTextbox.x - (bindTextbox.width / 2);
		var centerY = bindTextbox.y - (bindTextbox.height / 2);
		popupTitle = new FlxText(centerX, centerY + 20, bindTextbox.width - (bindTextbox.boxInterval * 3), "Currently binding my penis", 16);
		popupTitle.setFormat(Paths.font("poketext.ttf"), 16, 0xFF000000, FlxTextAlign.CENTER);
		popupText = new FlxText(centerX, centerY + 20 + popupTitle.height, bindTextbox.width - (bindTextbox.boxInterval * 3), "Press key to bind\npress to unbind", 16);
		popupText.setFormat(Paths.font("poketext.ttf"), 16, 0xFF000000, FlxTextAlign.CENTER);
		unbindText = new FlxText(centerX, centerY + 140, bindTextbox.width - (bindTextbox.boxInterval * 3), "(Note that this action needs atleast one key bound)", 16);
		unbindText.setFormat(Paths.font("poketext.ttf"), 16, 0xFF000000, FlxTextAlign.CENTER);

		bindTextbox.cameras = [overlayCamera];
		popupTitle.cameras = [overlayCamera];
		popupText.cameras = [overlayCamera];
		unbindText.cameras = [overlayCamera];

		add(bindTextbox);
		add(popupTitle);
		add(popupText);
		add(unbindText);

    }

	function enterRebind(){
		rebinding = true;
		
		var internal = internals[curSelected];
		popupText.text = 'Press any key to bind, or press [BACKSPACE] to cancel.';
		var daKey:FlxKey = Init.gameControls.get(internal)[0][bindID];
		if (daKey != NONE)
			popupText.text += '\nPress [${getStringKey(daKey)}] to unbind.';

		popupTitle.text = "CURRENTLY BINDING " + displays[curSelected].toUpperCase();
		overlayCamera.visible = true;
		unbindText.visible = forcedBind.contains(internal);
	}
	
    override function update(elapsed:Float){
		if (Math.abs(centralTextbox.boxWidth - expanseHorizontal) < 0.05)
			centralTextbox.boxWidth = expanseHorizontal;
		else
			centralTextbox.boxWidth = FlxMath.lerp(centralTextbox.boxWidth, expanseHorizontal, 0.3 * (elapsed / (1 / 60)));

		if (Math.abs(centralTextbox.boxHeight - expanseVertical) < 0.05)
			centralTextbox.boxHeight = expanseVertical;
		else
			centralTextbox.boxHeight = FlxMath.lerp(centralTextbox.boxHeight, expanseVertical, 0.3 * (elapsed / (1 / 60)));

		scrollableCamera.width = Std.int(centralTextbox.width - (centralTextbox.boxInterval * centralTextbox.scale.x));
		scrollableCamera.height = Std.int(centralTextbox.height - (centralTextbox.boxInterval * centralTextbox.scale.y));
		scrollableCamera.x = centralTextbox.x - (scrollableCamera.width / 2);
		scrollableCamera.y = centralTextbox.y - (scrollableCamera.height / 2);
		super.update(elapsed);
		overlayCamera.visible = rebinding;
		if(!rebinding){
			var lastBind = bindID;
			if(controls.UI_LEFT_P)
				bindID = bindID == 1 ? 0 : 1;
			if (controls.UI_RIGHT_P)
				bindID = bindID == 0 ? 1 : 0;

			var last = curSelected;
			if (controls.UI_DOWN_P)
				curSelected++;
			if (controls.UI_UP_P)
				curSelected--;
			

			if(controls.BACK){
				close();
				return;
			}
			

			if (curSelected > bindTexts.length-1)curSelected=0;
			if (curSelected < 0)
				curSelected = bindTexts.length - 1;
			
			if (last != curSelected || lastBind != bindID)
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

			selector.x = bindTexts[curSelected][bindID].x - 10;
			selector.y = bindTexts[curSelected][bindID].y + 4;
			if (controls.ACCEPT)enterRebind();
		}	
		else
		{
			var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
			if (keyPressed == BACKSPACE)
			{
				rebinding = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			else if (keyPressed != NONE)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				var opp = bindID == 0 ? 1 : 0;
				var internal = internals[curSelected];
				trace("bound " + internal + " (" + bindID + ") to " + getStringKey(keyPressed));
				var binds = Init.gameControls.get(internal)[0];

				rebinding = false;
				if (binds[bindID] == keyPressed)
					keyPressed = NONE;

				else if (binds[opp] == keyPressed)
				{
					binds[opp] = NONE;
					bindTexts[curSelected][opp].text = getStringKey(NONE);
				}
				if (forcedBind.contains(internal))
				{
					var defaults = Init.defaultKeys.get(internal);
					if (keyPressed == NONE && binds[opp] == NONE)
					{
						// atleast ONE needs to be bound, so use a default
						if (defaults[bindID] == NONE)
							keyPressed = defaults[opp];
						else
							keyPressed = defaults[bindID];
					}
				}
				binds[bindID] = keyPressed;
				bindTexts[curSelected][bindID].text = getStringKey(keyPressed);
				Init.gameControls.get(internal)[0] = binds;
				controls.setKeyboardScheme(None, false);

			}
		}
	}

	override public function close()
	{
		//
		Init.saveControls(); // for controls
		super.close();
	}
}