import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import lime._internal.backend.native.NativeCFFI;
import meta.CoolUtil;
import meta.InfoHud;
import meta.data.Highscore;
import meta.data.dependency.Discord;
import meta.state.*;
import meta.state.charting.*;
import meta.state.menus.PreloadState;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.net.SharedObject;
import openfl.system.System;
import overworld.OverworldStage;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/** 
	Enumerator for settingtypes
**/
enum SettingTypes
{
	Checkmark; // checkbox/on and off togle
	StringSelector; // select from list of strings
	NumberSelector; // choose a number
	Custom; // anything else
}

/**
	This is the initialisation class. if you ever want to set anything before the game starts or call anything then this is probably your best bet.
	A lot of this code is just going to be similar to the flixel templates' colorblind filters because I wanted to add support for those as I'll
	most likely need them for skater, and I think it'd be neat if more mods were more accessible.
**/
class Init extends FlxState
{
	/*
		Okay so here we'll set custom settings. As opposed to the previous options menu, everything will be handled in here with no hassle.
		This will read what the second value of the key's array is, and then it will categorise it, telling the game which option to set it to.

		0 - boolean, true or false checkmark
		1 - choose string
		2 - choose number (for fps so its low capped at 30)
		3 - offsets, this is unused but it'd bug me if it were set to 0
		might redo offset code since I didnt make it and it bugs me that it's hardcoded the the last part of the controls menu
	 */
	public static var FORCED = 'forced';
	public static var NOT_FORCED = 'not forced';

	// Neb: I hate how this works so im rewriting it lol
	/*
	public static var gameSettings:Map<String, Dynamic> = [
		'Downscroll' => [
			false,
			Checkmark,
			'Whether to have the strumline vertically flipped in gameplay.',
			NOT_FORCED
		],
		'Auto Pause' => [true, Checkmark, '', NOT_FORCED],
		'FPS Counter' => [true, Checkmark, 'Whether to display the FPS counter.', NOT_FORCED],
		'Memory Counter' => [
			true,
			Checkmark,
			'Whether to display approximately how much memory is being used.',
			NOT_FORCED
		],
		'Debug Info' => [false, Checkmark, 'Whether to display information like your game state.', NOT_FORCED],
		'Reduced Movements' => [
			false,
			Checkmark,
			'Whether to reduce movements, like icons bouncing or beat zooms in gameplay.',
			NOT_FORCED
		],
		'Flashing Lights' => [
			true,
			Checkmark,
			'Enables flashing lights, turn this off if you are epileptic or sensitive to flashing lights!',
			NOT_FORCED
		],
		'Stage Opacity' => [
			Checkmark,
			Selector,
			'Darkens non-ui elements, useful if you find the characters and backgrounds distracting.',
			NOT_FORCED
		],
		'Opacity Type' => [
			'UI',
			Selector,
			'Choose whether the filter will be behind the notes or the UI',
			NOT_FORCED,
			['UI', 'Notes']
		],
		'Counter' => [
			'None',
			Selector,
			'Choose whether you want somewhere to display your judgements, and where you want it.',
			NOT_FORCED,
			['None', 'Left', 'Right']
		],
		'Display Accuracy' => [true, Checkmark, 'Whether to display your accuracy on screen.', NOT_FORCED],
		'Disable Antialiasing' => [
			false,
			Checkmark,
			'Whether to disable Anti-aliasing. Helps improve performance in FPS.',
			NOT_FORCED
		],
		'No Camera Note Movement' => [
			false,
			Checkmark,
			'When enabled, left and right notes no longer move the camera.',
			NOT_FORCED
		],
		'Use Forever Chart Editor' => [
			false,
			Checkmark,
			'When enabled, uses the custom Forever Engine chart editor!',
			NOT_FORCED
		],
		'Disable Note Splashes' => [
			false,
			Checkmark,
			'Whether to disable note splashes in gameplay. Useful if you find them distracting.',
			NOT_FORCED
		],
		// custom ones lol
		'Offset' => [Checkmark, 3],
		'Filter' => [
			'none',
			Selector,
			'Choose a filter for colorblindness.',
			NOT_FORCED,
			['none', 'Deuteranopia', 'Protanopia', 'Tritanopia']
		],
		"Clip Style" => ['stepmania', Selector, "Chooses a style for hold note clippings; StepMania: Holds under Receptors; FNF: Holds over receptors", NOT_FORCED, 
			['StepMania', 'FNF']],
		"UI Skin" => ['default', Selector, 'Choose a UI Skin for judgements, combo, etc.', NOT_FORCED, ''],
		"Note Skin" => ['default', Selector, 'Choose a note skin.', NOT_FORCED, ''],
		"Framerate Cap" => [120, Selector, 'Define your maximum FPS.', NOT_FORCED, ['']],
		"Opaque Arrows" => [false, Checkmark, "Makes the arrows at the top of the screen opaque again.", NOT_FORCED],
		"Opaque Holds" => [false, Checkmark, "Huh, why isnt the trail cut off?", NOT_FORCED],
		'Ghost Tapping' => [
			true,
			Checkmark,
			"Enables Ghost Tapping, allowing you to press inputs without missing.",
			NOT_FORCED
		],
		'Centered Notefield' => [false, Checkmark, "Center the notes, disables the enemy's notes."],
		"Custom Titlescreen" => [
			false,
			Checkmark,
			"Enables the custom Forever Engine titlescreen! (only effective with a restart)",
			FORCED
		],
		'Skip Text' => [
			'freeplay only',
			Selector,
			'Decides whether to skip cutscenes and dialogue in gameplay. May be always, only in freeplay, or never.',
			NOT_FORCED,
			['never', 'freeplay only', 'always']
		],
		'Fixed Judgements' => [
			false,
			Checkmark,
			"Fixes the judgements to the camera instead of to the world itself, making them easier to read.", 
			NOT_FORCED
		],
		'Simply Judgements' => [
			false,
			Checkmark,
			"Simplifies the judgement animations, displaying only one judgement / rating sprite at a time.",
			NOT_FORCED
		],


	];*/

	// new settings shit kinda

	/* Settings are defined like Rthis:
		'Name' => [
			Type,
			DefaultValue,
			Description,
			MiscData
		]

		MiscData depends on type.
		If its a NumSelector, MiscData is, in order: Step, Min, Max, Suffix (optional)
		so:
		'FPS Cap' => [
			NumberSelector,
			60,
			"Sets the target framerate of the application",
			30,
			30,
			360,
			""
		]

		StringSelector just has an array of selections

		'Note Clipping' => [
			StringSelector,
			"FNF",
			"Sets how notes are clipped",
			["Stepmania", "FNF"]
		]
		

		// Checkmark and Custom have nothing

	*/
	public static var gameSettings:Map<String, Dynamic> = [
		'Downscroll' => [
			Checkmark,
			false,
			'Whether to have the strumline vertically flipped in gameplay.',
			
		],
		'Auto Pause' => [
			Checkmark, 
			true, 
			'', 
		],
		'FPS Counter' => [
			Checkmark, 
			true, 
			'Whether to display the FPS counter.', 
		],
		'Memory Counter' => [
			Checkmark,
			true,
			'Whether to display approximately how much memory is being used.',
			
		],
		'Debug Info' => [
			Checkmark,
			false,
			'Whether to display information like your game state.',
			
		],
		'Reduced Movements' => [
			Checkmark,
			false,
			'Whether to reduce movements, like icons bouncing or beat zooms in gameplay.',
			
		],
		'Flashing Lights' => [
			Checkmark,
			true,
			'Enables flashing lights, turn this off if you are epileptic or sensitive to flashing lights!',
			
		],
		'Stage Opacity' => [
			NumberSelector,
			100,
			'Darkens non-ui elements, useful if you find the characters and backgrounds distracting.',

			5,
			0,
			100
		],
		'Opacity Type' => [
			StringSelector,
			'UI',
			'Choose whether the filter will be behind the notes or the UI',
			
			['UI', 'Notes']
		],
		'Counter' => [
			StringSelector,
			'None',
			'Choose whether you want somewhere to display your judgements, and where you want it.',
			
			['Left', 'None', 'Right']
		],
		'Display Accuracy' => [
			Checkmark, 
			true,
			'Whether to display your accuracy on screen.'
		],
		'Disable Antialiasing' => [
			Checkmark,
			false,
			'Whether to disable Anti-aliasing. Helps improve performance in FPS.',
			
		],
		'No Camera Note Movement' => [
			Checkmark,
			false,
			'When enabled, left and right notes no longer move the camera.',
			
		],
		'Use Forever Chart Editor' => [
			Checkmark,
			false,
			'When enabled, uses the custom Forever Engine chart editor!',
			
		],
		'Disable Note Splashes' => [
			Checkmark,
			false,
			'Whether to disable note splashes in gameplay. Useful if you find them distracting.',
			
		],

		'Offset' => [
			NumberSelector, 
			0, 
			'How much to offset the song by in gameplay.', 
			1, 
			-1000, 
			1000
		],
		
		'Filter' => [
			StringSelector,
			'none',
			'Choose a filter for colorblindness.',
			['none', 'Deuteranopia', 'Protanopia', 'Tritanopia']
		],
		"Clip Style" => [
			StringSelector,
			'stepmania',
			"Chooses a style for hold note clippings; StepMania: Holds under Receptors; FNF: Holds over receptors",
			['StepMania', 'FNF']
		],
		"UI Skin" => [
			StringSelector,
			'default',
			'Choose a UI Skin for judgements, combo, etc.',
			[]
		],
		"Note Skin" => [
			StringSelector, 
			'default', 
			'Choose a note skin.', 
			[]
		],
		"Framerate Cap" => [
			NumberSelector, 
			120, 
			'Define your maximum FPS.', 
			30, 
			30, 
			360
		],
		"Opaque Arrows" => [
			Checkmark,
			false,
			"Makes the arrows at the top of the screen opaque again.",
			
		],
		"Opaque Holds" => [
			Checkmark, 
			false, 
			"Huh, why isnt the tail cut off?"
		],
		'Ghost Tapping' => [
			Checkmark,
			true,
			"Enables Ghost Tapping, allowing you to press inputs without missing.",
			
		],
		'Centered Notefield' => [
			Checkmark,  
			false, 
			"Center the notes, disables the enemy's notes."
		],
		"Custom Titlescreen" => [
			Checkmark,
			false,
			"Enables the custom Forever Engine titlescreen! (only effective with a restart)",
			
		],
		'Skip Text' => [
			StringSelector,
			'freeplay only',
			'Decides whether to skip cutscenes and dialogue in gameplay. May be always, only in freeplay, or never.',
			['never', 'freeplay only', 'always']
		],
		'Fixed Judgements' => [
			Checkmark,
			false,
			"Fixes the judgements to the camera instead of to the world itself, making them easier to read.",
			
		],
		'Simply Judgements' => [
			Checkmark,
			false,
			"Simplifies the judgement animations, displaying only one judgement / rating sprite at a time.",
		],
		'Mechanics' => [
			StringSelector,
			'normal',
			'Presets for the mechanics settings. "custom" lets you set them yourself.',
			['Off', 'Normal', 'Hell', 'Custom'] // TODO: add fuck you
		],
		'Pendulum Enabled' => [
			Checkmark,
			true,
			"Whether the Pendulum should be enabled on songs that include it",
		],
		'Beat Time' => [
			NumberSelector,
			2,
			"How many beats must pass before you hit the pendulum again",
			1,
			1,
			8
		],
		'Psyshock' => [
			Checkmark,
			true,
			"Whether Hypno can Psyshock you on songs with the Pendulum",
		],
		'Psyshock Damage Percent' => [
			NumberSelector,
			12.5,
			"Determines how much 'trance' the player gains on a Psyshock",
			0.5,
			0.5,
			99.5
		],
		'Shaders' => [
			Checkmark,
			true,
			"Whether to load shaders or not",
		],
		"Unfocus Pause" => [
			Checkmark,
			true,
			"Whether the game should pause when you unfocus"
		],
		'Snow Enabled' => [
			Checkmark, 
			true, 
			"Whether to enable the snow on the Mountain stage"
		],
		'Freezing Enabled' => [
			Checkmark,
			true,
			"Whether the freezing mechanic should be used on songs which include it",
		],
		'Typhlosion Return Curve' => [
			StringSelector,
			'normal',
			'Determines how the diminishing returns are calculated',
			['Off', 'Normal', 'Hell']
		],
		'Typhlosion Uses' => [
			NumberSelector,
			10,
			"How many times you can use your typhlosion before it dies",
			1,
			2,
			20,
		],
		'Typhlosion Warmth Percent' => [
			NumberSelector,
			100,
			"How much warmth your Typhlosion gives you",
			0.5,
			5,
			200
		],

		'Freezing Rate Percent' => [
			NumberSelector,
			100,
			"How fast you freeze",
			0.5,
			0,
			200
		],

		'Fifth Key' => [
			Checkmark, 
			true, 
			"Whether to enable the bell notes on Death Toll"
		],
		"Hell Mode Ear Ringing" => [
			Checkmark,
			true,
			"Whether an ear ringing sound should play when missing a bell in Hell Mode Death Toll"
		],
		'Forced Accuracy' => [
			Checkmark, 
			true, 
			"Whether Insomnia should have its forced accuracy gimmick"
		],
		"Accuracy Cap" => [
			NumberSelector, 
			90,
			'The minimum accuracy you can have in Insomnia before Feraligatr kills you', 
			1, 
			5, 
			100
		],

		"Fully Accurate Restore" => [
			Checkmark,
			false,
			"Disables any changes that wouldn't've been in the original Lullaby V2.\nThis does NOT include custom Hell Mode mechanics."
		]

	];

	public static var trueSettings:Map<String, Dynamic> = [];
	public static var settingsDescriptions:Map<String, String> = [];

	public static var defaultKeys:Map<String, Dynamic> = [];
	public static var gameControls:Map<String, Dynamic> = [
		'UP' => [[FlxKey.UP, W], 3],
		'DOWN' => [[FlxKey.DOWN, S], 1],
		'SPACE' => [[FlxKey.SPACE, NONE], 2],
		'LEFT' => [[FlxKey.LEFT, A], 0],
		'RIGHT' => [[FlxKey.RIGHT, D], 4],
		'ACCEPT' => [[FlxKey.SPACE, Z, FlxKey.ENTER], 5],
		'BACK' => [[FlxKey.BACKSPACE, X, FlxKey.ESCAPE], 6],
		'PAUSE' => [[FlxKey.ENTER, P], 7],
		'RESET' => [[R, NONE], 14],
		'UI_UP' => [[FlxKey.UP, W], 9],
		'UI_DOWN' => [[FlxKey.DOWN, S], 10],
		'UI_LEFT' => [[FlxKey.LEFT, A], 11],
		'UI_RIGHT' => [[FlxKey.RIGHT, D], 12],
	];

	public static var filters:Array<BitmapFilter> = []; // the filters the game has active
	/// initalise filters here
	public static var gameFilters:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}> = [
		"Deuteranopia" => {
			var matrix:Array<Float> = [
				0.43, 0.72, -.15, 0, 0,
				0.34, 0.57, 0.09, 0, 0,
				-.02, 0.03,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Protanopia" => {
			var matrix:Array<Float> = [
				0.20, 0.99, -.19, 0, 0,
				0.16, 0.79, 0.04, 0, 0,
				0.01, -.01,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Tritanopia" => {
			var matrix:Array<Float> = [
				0.97, 0.11, -.08, 0, 0,
				0.02, 0.82, 0.16, 0, 0,
				0.06, 0.88, 0.18, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		}
	];

	override public function create():Void
	{
		/*
		for (i in pathsArray) {
			var singularArray:Array<String> = i.split('/');
			@:privateAccess
			var path = getPreviousPath(singularArray[0], singularArray[1], singularArray[2]) + singularArray[3] + '.sol';
			if (FileSystem.exists(path))
			{
				for (i in pathsArray)
				{
					var singularArray:Array<String> = i.split('/');
					var directory:String = getPreviousPath(singularArray[0], singularArray[1], singularArray[2]);
					var trimmedDirectory:String = directory.substring(0, directory.indexOf('/${singularArray[2]}'));
					FileSystem.createDirectory(trimmedDirectory);
					trace('directory $i lmfao');

					var name:String = singularArray[3].replace('\\', '');
					File.saveContent(directory + name + '.sol', 'yeah');
				}
			}
		}
		*/

		// ^^ is this the leak detector lol


		for (i => v in gameControls){
			defaultKeys.set(i, v.copy());
		}

		FlxG.save.bind('lullabyv2', 'hypno');
		//FlxG.save.bind('lullabyfr', 'hypno');
		Highscore.load();

		loadSettings();
		loadControls();

		Main.updateFramerate(trueSettings.get("Framerate Cap"));

		// apply saved filters
		FlxG.game.setFilters(filters);

		// Some additional changes to default HaxeFlixel settings, both for ease of debugging and usability.
		FlxG.fixedTimestep = false; // This ensures that the game is not tied to the FPS
		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = false; // Hide mouse on start
		// FlxGraphic.defaultPersist = true; // make sure we control all of the memory
		
		gotoTitleScreen();
	}

	private static function getPreviousPath(company:String, file:String, localPath:String):String {
		@:privateAccess
		var path = NativeCFFI.lime_system_get_directory(1, company, file) + "/" + localPath + "/";
		return path;
	}

	private function gotoTitleScreen() {	
		Main.switchState(this, new DisclaimerState());
	}

	public static function loadSettings():Void {
		// set the true settings array
		// only the first variable will be saved! the rest are for the menu stuffs

		// IF YOU WANT TO SAVE MORE THAN ONE VALUE MAKE YOUR VALUE AN ARRAY INSTEAD
		for (setting in gameSettings.keys())
			trueSettings.set(setting, gameSettings.get(setting)[0]);

		// NEW SYSTEM, INSTEAD OF REPLACING THE WHOLE THING I REPLACE EXISTING KEYS
		// THAT WAY IT DOESNT HAVE TO BE DELETED IF THERE ARE SETTINGS CHANGES
		if (FlxG.save.data.settings != null)
		{
			var settingsMap:Map<String, Dynamic> = FlxG.save.data.settings;
			for (singularSetting in settingsMap.keys())
				if (gameSettings.get(singularSetting) != null)
					trueSettings.set(singularSetting, FlxG.save.data.settings.get(singularSetting));
		}

		if (FlxG.save.data != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute == null ? false : FlxG.save.data.mute;
			FlxG.sound.volume = FlxG.save.data.volume == null?3:FlxG.save.data.volume;
		}
		// validate all the options
		for(key => data in gameSettings){
			var val:Dynamic = trueSettings.get(key);
			switch(data[0]){
				case NumberSelector:
					var def:Float = data[1];
					var min:Float = data[4];
					var max:Float = data[5];
					if(!Std.isOfType(val, Float)){
						trueSettings.set(key, def);
						val = def;
					}

					// TODO: check if it lines up w/ the snap, and if not then snap it

					if(val < min)
						trueSettings.set(key, min);
					else if(val > max)
						trueSettings.set(key, max);
					
					
				case StringSelector:
					var options:Array<String> = data[3];
					if(!options.contains(val))
						trueSettings.set(key, data[1]);
				case Checkmark:
					if (!Std.isOfType(val, Bool))
						trueSettings.set(key, data[1]);
				default:
					// nothing
			}
		}

		saveSettings();

		updateAll();
	}

	public static function loadControls():Void
	{
		if ((FlxG.save.data.gameControls != null) && (Lambda.count(FlxG.save.data.gameControls) == Lambda.count(gameControls)))
			gameControls = FlxG.save.data.gameControls;

		saveControls();
	}

	public static function saveSettings():Void
	{
		// ez save lol
		FlxG.save.data.settings = trueSettings;
		FlxG.save.flush();

		updateAll();
	}

	public static function saveControls():Void
	{
		FlxG.save.data.gameControls = gameControls;
		FlxG.save.flush();
	}

	public static function updateAll()
	{
		InfoHud.updateDisplayInfo(trueSettings.get('FPS Counter'), trueSettings.get('Debug Info'), trueSettings.get('Memory Counter'));
		Main.updateFramerate(trueSettings.get("Framerate Cap"));
		
		FlxG.autoPause = Init.trueSettings.get("Unfocus Pause");

		///*
		filters = [];
		FlxG.game.setFilters(filters);

		var theFilter:String = trueSettings.get('Filter');
		if (gameFilters.get(theFilter) != null)
		{
			var realFilter = gameFilters.get(theFilter).filter;

			if (realFilter != null)
				filters.push(realFilter);
		}

		FlxG.game.setFilters(filters);
		// */
	}
}
