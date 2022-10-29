package meta.state.menus;

import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import gameObjects.userInterface.menu.Textbox;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import meta.MusicBeat.MusicBeatSubState;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.menu.Checkmark;
import gameObjects.userInterface.menu.PixelSelector;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;
import Init.SettingTypes;

/**
 * Options
 * 
 * Preferences
 * Controls
 * Mechanics
 * Effects
 * Exit
 * 
 */

/**
 * Preferences
 * 
 * Downscroll
 * Centered Notefield
 * Framerate Cap
 * 
 * Camera Movement
 * Note Splashes
 * Opaque Arrows
 * Opaque Holds
 * 
 * Antialiasing
 * Colorblind Filter (?)
 * 
 * FPS Counter
 * Memory Counter
 */

/**
 * Controls
 * 
 * Left
 * Down
 * Mechanic
 * Up
 * Right
 * 
 * Accept
 * Back
 * Pause
 * 
 * UI Left
 * UI Down
 * UI Up
 * UI Right
 * Edit Offset
 */

/**
 * Mechanics
 * 
 * Pendulum
 * Rate per Beats (2, min 1, max 8)
 * Psyshock (true by default)
 * Psyshock Damage Percent (1.0)
 * Ghost Tapping (most likely not as it ruins the mechanic/requires a rewrite to function properly based on accuracy)
 * 
 * Typhlosion
 * Rate of Fire (2 by default, min 1, max 4), rate of how many times used per drain 
 * Pain Split (true by default)
 * 
 * Feraligatr
 * Time Before Death (in seconds) (default 10, min 5, max 15)
 * Accuracy Percentage (default 90, min 70, max 99)
 * 
 * Unowns
 * Time Multiplier (1 default, min 0.5, max 2)
 * Lock Arrows (false by default)
 * Disable Time (locked unless using lock arrows, which it gives you the option)
 * 
 * Missingno
 * Glitching (true default)
 * 
 * Buried
 * Gengar Notes (true default)
 * Muk Splashes (true default)
 * 
 * Death Toll 
 * 5th Key (true by default)
 * 
 * Pasta Night
 * MX Pow Block (true by default)
 * 
 * Bygone Purpose
 * Floaty-Note-y (true by default)
 */

typedef OptionData = Array<Dynamic>; // just to make it more readable

class OptionsMenuState extends MusicBeatSubState
{
	/* "name" => [
		["name", ?confirmFunc, ?extraGenerationFunc, ?updateFunc]
	] 
	confirmFunc is called when you press enter while on the option
	extraGenerationFunc is called when generating the extras (checkboxes, selections, etc)
	updateFunc is called every update while the option is on screen
	*/
	var categoryMap:Map<String, Array<OptionData>> = [];

	// would do this diff but im tryna keep it similar to Forever's own without just copy pasting it 
	var currentExtras:Map<FlxText, FlxSprite> = [];
	var currentSelected:Map<String, Int> = [];
	var currentDisplayed:FlxTypedGroup<FlxText>;
	var currentScreen:Array<OptionData>;
	var currentScreenName:String;

	var allDisplays:Map<String, FlxTypedGroup<FlxText>> = [];
	var allExtras:Map<String, Map<FlxText, FlxSprite>> = [];
	var centralTextbox:Textbox;
	var scale:Float = 3;
	var expanseHorizontal:Float;
	var expanseVertical:Float;
	var defaultExpanseHorizontal:Float;
	var defaultExpanseVertical:Float;
	var selector:FlxSprite;
	var curSelected:Int = 0;
	var bg:FlxSprite;

	var canControl:Bool = true;
	function exit(){
		canControl = false;
		FlxTween.cancelTweensOf(bg);
		var menuState:MainMenuState = cast FlxG.state;
		menuState.canSelect = true;

		FlxTween.tween(centralTextbox, {"scale.x": 0, "scale.y": 0}, 0.35, {
			ease: FlxEase.circOut
		});

		FlxTween.tween(bg, {alpha: 0}, 0.35, {
			ease: FlxEase.circOut,
			onComplete: function(tween:FlxTween)
			{
				close();
			}
		});
	}

	override public function create():Void
	{
		categoryMap = [
			'main' => [
				// main page
				["Controls", exit],
				["Preferences", loadSelectedGroup],
				["Appearance", loadSelectedGroup],
				["Mechanics", loadSelectedGroup],
				["Effects", loadSelectedGroup],
				["Exit", exit]
			],
			"Preferences" => [
				["Game Settings"],
				["Downscroll", confirmOption, generateExtra, updateOption],
				["Centered Notefield", confirmOption, generateExtra, updateOption],
				["Counter", confirmOption, generateExtra, updateOption],
				["Display Accuracy", confirmOption, generateExtra, updateOption],

				["Meta Settings"],
				["Framerate Cap", confirmOption, generateExtra, updateOption],
				["FPS Counter", confirmOption, generateExtra, updateOption],
				["Memory Counter", confirmOption, generateExtra, updateOption],
			],
			"Appearance" => [
				["Judgements"],
				["Fixed Judgements", confirmOption, generateExtra, updateOption],
				["Simply Judgements", confirmOption, generateExtra, updateOption],
				["Notes"],
				["No Camera Note Movement", confirmOption, generateExtra, updateOption],
				["Clip Style", confirmOption, generateExtra, updateOption],
				["Disable Note Splashes", confirmOption, generateExtra, updateOption],
				["Opaque Arrows", confirmOption, generateExtra, updateOption],
				["Opaque Holds", confirmOption, generateExtra, updateOption],
				["Accessibility"],
				["Flashing Lights", confirmOption, generateExtra, updateOption],
				["Filter", confirmOption, generateExtra, updateOption],
				["Disable Antialiasing", confirmOption, generateExtra, updateOption],
				["Stage Opacity", confirmOption, generateExtra, updateOption],
				["Opacity Type", confirmOption, generateExtra, updateOption],
				["Reduced Movements", confirmOption, generateExtra, updateOption],
			],
			"Mechanics" => [
				["Mechanics", confirmOption, generateExtra, updateOption],
				["Custom Settings"],
				["Pendulum"],
				["Pendulum Enabled", confirmOption, generateExtra, updateOption],
				["Psyshock", confirmOption, generateExtra, updateOption],
				["Beat Time", confirmOption, generateExtra, updateOption],
				["Psyshock Damage Percent", confirmOption, generateExtra, updateOption],
				
				["Frostbite"],
				["Freezing Enabled", confirmOption, generateExtra, updateOption],
				["Freezing Rate Percent", confirmOption, generateExtra, updateOption],
				["Typhlosion Uses", confirmOption, generateExtra, updateOption],
				["Typhlosion Warmth Percent", confirmOption, generateExtra, updateOption],
				["Typhlosion Diminishing Returns", confirmOption, generateExtra, updateOption],

				["Feraligatr"],
				["Forced Accuracy", confirmOption, generateExtra, updateOption],
				["Accuracy Cap", confirmOption, generateExtra, updateOption],

				["Hell Bell"],
				["Fifth Key", confirmOption, generateExtra, updateOption],

			],
			"Effects" => [
				["Shaders", confirmOption, generateExtra, updateOption],
				["Snowfall"],
				["Snow Enabled", confirmOption, generateExtra, updateOption],

			],
		];
		super.create();

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		bg.alpha = 0;

		FlxTween.tween(bg, {alpha: 1}, 0.25, {ease: FlxEase.circOut});
		centralTextbox = new Textbox(0, 0);
		centralTextbox.screenCenter();
		centralTextbox.scale.set(3, 3);
		expanseHorizontal = 9;
		expanseVertical = (1.5 * categoryMap.get("main").length) - 1;

		defaultExpanseVertical = expanseVertical;
		defaultExpanseHorizontal = expanseHorizontal;

		add(bg);
		add(centralTextbox);

		selector = new FlxSprite();
		selector.loadGraphic(Paths.image('UI/pixel/selector'));
		selector.scrollFactor.set();
		add(selector);

		//allDisplays.set("main", generateGroup(categoryMap.get("main")));
		for (name in categoryMap.keys()){
			var shit = generateGroup(categoryMap.get(name));
			allDisplays.set(name, shit[0]);
			allExtras.set(name, shit[1]);
		}

		loadGroup("main");
	}

	var pressTimers:Map<FlxObject, Float> = [];
	
	function updateOption(){
		var name = currentScreen[curSelected][0];
		if (!Init.trueSettings.exists(name) || !Init.gameSettings.exists(name))
			return;

		switch (Init.gameSettings.get(name)[0])
		{
			case StringSelector | NumberSelector:
				var pressLeft = controls.UI_LEFT_P;
				var pressRight = controls.UI_RIGHT_P;

				var left = controls.UI_LEFT;
				var right = controls.UI_RIGHT;
				
				var selector:PixelSelector = cast currentExtras.get(currentDisplayed.members[curSelected]);
				if (pressTimers.get(selector) == null)
					pressTimers.set(selector, 0);

				if(left || right)
					pressTimers.set(selector, pressTimers.get(selector) + FlxG.elapsed);
				else
					pressTimers.set(selector, 0);
				
				if (pressTimers.get(selector) >= 0.1){ // every 0.1 seconds that its held
					pressTimers.set(selector, pressTimers.get(selector) - 0.1);
					pressLeft = left;
					pressRight = right;
				}
				


				if (!left)
					selector.selectorPlay('left');
					
				if (!right)
					selector.selectorPlay('right');

				if (pressLeft)
					updateSelector(selector, -1);

				if (pressRight)
					updateSelector(selector, 1);

			case Checkmark:

			default:
				// nawr
		}
	}

	function updateSelector(selector:PixelSelector, inc:Int=0){
		var curIdx = selector.options.indexOf(selector.chosenOptionString);
		var newIdx = curIdx+inc;
		var settingDat = Init.gameSettings.get(selector.setting);
		if (newIdx < 0)
			newIdx = selector.options.length - 1;
		else if (newIdx >= selector.options.length)
			newIdx = 0;

		if(inc<0)
			selector.selectorPlay('left', 'press');
		else if(inc>0)
			selector.selectorPlay('right', 'press');

		FlxG.sound.play(Paths.sound('scrollMenu'));

		selector.chosenOptionString = selector.options[newIdx];
		selector.optionChosen.text = selector.chosenOptionString.toUpperCase() + (settingDat[6] == null ? "" : settingDat[6]);

		var type = settingDat[0];
		switch(type){
			case NumberSelector:
				Init.trueSettings.set(selector.setting, Std.parseFloat(selector.chosenOptionString));
			case StringSelector:
				Init.trueSettings.set(selector.setting, selector.chosenOptionString);
			default:

		}
		
		Init.saveSettings();
	}

	function confirmOption(){
		var name = currentScreen[curSelected][0];
		if(!Init.trueSettings.exists(name) || !Init.gameSettings.exists(name))return;

		switch(Init.gameSettings.get(name)[0]){
			case StringSelector:

			case NumberSelector:

			case Checkmark:
				var newTog = !Init.trueSettings.get(name);
				Init.trueSettings.set(name, newTog);
				currentExtras.get(currentDisplayed.members[curSelected]).animation.play(newTog ? "selected" : "unselected");
				Init.saveSettings();
			default:
				// nawr
		}
	}
	
	function loadGroup(daGroup:String){
		if (currentDisplayed!=null)
			remove(currentDisplayed);
		
		for (key in currentExtras.keys()){
			var extra = currentExtras.get(key);
			remove(extra);
		}
		curSelected = currentSelected.get(daGroup);
		currentDisplayed = allDisplays.get(daGroup);
		currentScreen = categoryMap.get(daGroup);
		currentExtras = allExtras.get(daGroup);
		currentScreenName = daGroup;
		
		add(currentDisplayed);
		if (daGroup=='main'){
			expanseVertical = defaultExpanseVertical;
			expanseHorizontal = defaultExpanseHorizontal;
		}else{
			expanseHorizontal = 24;
			expanseVertical = 18;
		}
		for (key in currentExtras.keys())
		{
			var extra = currentExtras.get(key);
			add(extra);
		}
		changeSelection(0);
	}

	function generateGroup(group:Array<OptionData>):Array<Dynamic>{	
		var idx:Int = 0;
		var typedGroup = new FlxTypedGroup<FlxText>();
		var extraMap:Map<FlxText, FlxSprite>=[];
		for(dat in group){
			var label = dat[0];

			var newText:FlxText = new FlxText(0, idx * 30, 0, label);
			newText.setFormat(Paths.font('poketext.ttf'), 8, FlxColor.BLACK);
			newText.screenCenter();
			newText.antialiasing = false;
			newText.scrollFactor.set();
			typedGroup.add(newText);

			var extra:Dynamic = (dat[2] == null)?null:dat[2](dat);
			if(extra!=null){
				extraMap.set(newText, extra);
			}
		}
		return [typedGroup, extraMap];
		//allDisplays.set(group)
	}

	function generateExtra(data:OptionData):FlxSprite{
		var shit = Init.gameSettings.get(data[0]);
		if(shit!=null){
			switch(shit[0]){
				case StringSelector:
					var selector:PixelSelector = new PixelSelector(10, 0, data[0], Init.gameSettings.get(data[0])[3]);
					selector.scale.set(3, 3);
					selector.updateHitbox();
					return selector;
				case NumberSelector:
					var options:Array<String> = [];
					var gameSettings = Init.gameSettings.get(data[0]);
					var idx:Float = gameSettings[4];
					var step:Float = gameSettings[3];
					while(idx <= gameSettings[5]){
						options.push(Std.string(idx));
						idx += step;
					}
					var selector:PixelSelector = new PixelSelector(10, 0, data[0], options);
					selector.scale.set(3, 3);
					selector.updateHitbox();
					
					return selector;
				case Checkmark:
					var checkbox = new FlxSprite().loadGraphic(Paths.image("UI/pixel/checkbox"), true, 11, 11);
					checkbox.animation.add("unselected", [0], 24, false);
					checkbox.animation.add("selected", [1], 24, true);
					checkbox.animation.play(Init.trueSettings.get(data[0])?"selected":"unselected");
					checkbox.antialiasing=false;
					checkbox.scale.set(3, 3);
					checkbox.updateHitbox();
					return checkbox;
				default:
					// nawr
			}
		}
		return null;
	}

	function loadSelectedGroup(){
		var name = currentScreen[curSelected][0];
		loadGroup(name);
	}

	function changeSelection(inc:Int){
		curSelected+=inc;
		if (curSelected > currentScreen.length - 1)
			curSelected = 0;

		if (curSelected < 0)
			curSelected = currentScreen.length - 1;
		currentSelected.set(currentScreenName, curSelected);
		if (currentScreen[curSelected][1] == null)
			changeSelection(inc==0?1:inc);
	}
	override function update(elapsed:Float){
		super.update(elapsed);
		
		
		if (Math.abs(centralTextbox.boxWidth - expanseHorizontal) < 0.05)
			centralTextbox.boxWidth = expanseHorizontal;
		else
			centralTextbox.boxWidth = FlxMath.lerp(centralTextbox.boxWidth, expanseHorizontal, 0.3 * (elapsed / (1 / 60)));

		if (Math.abs(centralTextbox.boxHeight - expanseVertical) < 0.05)
			centralTextbox.boxHeight = expanseVertical;
		else
			centralTextbox.boxHeight = FlxMath.lerp(centralTextbox.boxHeight, expanseVertical, 0.3 * (elapsed / (1 / 60)));

		//centralTextbox.scale.x = FlxMath.lerp(centralTextbox.scale.x, scale, 0.3 * (elapsed / (1 / 60)));
		//centralTextbox.scale.y = FlxMath.lerp(centralTextbox.scale.y, scale, 0.3 * (elapsed / (1 / 60)));
		//trace(centralTextbox.scale.x, centralTextbox.scale.y);
		selector.scale.set(centralTextbox.scale.x * (centralTextbox.boxWidth / expanseHorizontal),
		centralTextbox.scale.y * (centralTextbox.boxHeight / expanseVertical));
		selector.x = centralTextbox.x - centralTextbox.width / 2 + (selector.scale.x * centralTextbox.boxInterval);
		selector.screenCenter(Y);
		selector.y -= (centralTextbox.boxInterval * centralTextbox.boxHeight * centralTextbox.scale.y) / 2;
		selector.y += 12;

		var m = curSelected;
		// TODO: rewrite scrolling so that it stays in the middle til the end idfk
		// I hate doing this shit lol
		if (curSelected > 12)
			m -= curSelected - 12;
		
		selector.y += 36 * m;
		for (i in 0...currentDisplayed.members.length)
		{
			var s = i;
			if (curSelected > 12)
				s -= curSelected-12;

			var text = currentDisplayed.members[i];
			text.visible=s < 13 && s >= 0;
			text.scale.set(centralTextbox.scale.x * (centralTextbox.boxWidth / expanseHorizontal), centralTextbox.scale.y * (centralTextbox.boxHeight / expanseVertical));
			text.updateHitbox();
			text.screenCenter();
			if(currentScreen[i][1]!=null)
				text.x -= ((centralTextbox.width - text.width)/2) - (selector.frameWidth * selector.scale.x);

			text.y -= (centralTextbox.boxInterval * centralTextbox.boxHeight * centralTextbox.scale.y)/2;

			text.y += 12;
			text.y += 36 * s;

			var attachment = currentExtras.get(text);
			if(attachment!=null){
				attachment.scale.set(centralTextbox.scale.x * (centralTextbox.boxWidth / expanseHorizontal),
					centralTextbox.scale.y * (centralTextbox.boxHeight / expanseVertical));
				attachment.updateHitbox();
				if((attachment is PixelSelector)){
					attachment.x = text.x + text.width;
					attachment.y = text.y + 6; // da magic number 
				}else{
					attachment.x = text.x + text.width;
					attachment.y = text.y + ((text.height - attachment.height) / 2);
				}
				attachment.visible = text.visible;
			}
		}

		if (canControl){
			var pressUp = controls.UI_UP_P;
			var pressDown = controls.UI_DOWN_P;
			var confirm = controls.ACCEPT;
			var back = controls.BACK;

			if(back){
				if(currentScreenName=='main')
					exit();
				else
					loadGroup("main");
			}

			/*if (pressDown)
				curSelected++;
			
			if (pressUp)
				curSelected--;
			
			if (curSelected > currentScreen.length - 1)
				curSelected = 0;

			if (curSelected < 0)
				curSelected = currentScreen.length - 1;*/
			if (pressDown)
				changeSelection(1);
			if (pressUp)
				changeSelection(-1);

			
			if (confirm){
				if (currentScreen[curSelected][1]!=null)
					currentScreen[curSelected][1]();
			}

			if (currentScreen[curSelected][3]!=null)
				currentScreen[curSelected][3]();
		}
	}
}
