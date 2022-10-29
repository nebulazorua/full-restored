package gameObjects.userInterface.menu;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;

class PixelSelector extends FlxTypedSpriteGroup<FlxSprite>
{
	//
	var leftSelector:FNFSprite;
	var rightSelector:FNFSprite;

	public var optionChosen:FlxText;
	public var chosenOptionString:String = '';
    public var setting:String = '';
	public var options:Array<String>;

	public function new(x:Float = 0, y:Float = 0, word:String, options:Array<String>)
	{
		// call back the function
		super(x, y);

		this.options = options;
		trace(options);

		// oops magic numbers
		var shiftX = 0;
		var shiftY = 0;
		// generate multiple pieces
        
		var val:Dynamic = Init.trueSettings.get(word);
		chosenOptionString = (Std.isOfType(val, Int) || Std.isOfType(val, Float))?Std.string(val):(cast val);
		var longestLen:Float = 0;
		var longestWord = '';

		var shitText = new FlxText(0, 0, 0, "wow");
		shitText.setFormat(Paths.font('poketext.ttf'), 8, FlxColor.BLACK, FlxTextAlign.CENTER);
		for (shit in options){
			shitText.text = shit.toUpperCase();
			if (shitText.width > longestLen){
				longestLen = shitText.width;
				longestWord = shit.toUpperCase();
            }
		}

		shitText.destroy();
		
		leftSelector = createSelector(shiftX, shiftY, word, 'left');
		setting = word;

		optionChosen = new FlxText(shiftX + leftSelector.width, shiftY, 0, longestWord); //new Alphabet(FlxG.width / 2, shiftY + 20, chosenOptionString, true, false);
		optionChosen.setFormat(Paths.font('poketext.ttf'), 8, FlxColor.BLACK, FlxTextAlign.CENTER);
		optionChosen.antialiasing = false;
		optionChosen.scrollFactor.set();
		optionChosen.y -= optionChosen.height/8;
		optionChosen.fieldWidth = optionChosen.width;
		
		rightSelector = createSelector(shiftX + optionChosen.width + leftSelector.width, shiftY , word, 'right');

		add(leftSelector);
		add(rightSelector);
		optionChosen.text = chosenOptionString.toUpperCase();


		add(optionChosen);
	}

	public function createSelector(objectX:Float = 0, objectY:Float = 0, word:String, dir:String):FNFSprite
	{
		var returnSelector = new FNFSprite(objectX, objectY).loadGraphic(Paths.image("UI/pixel/selectorarrows"), true, 11, 11);

        switch(dir){
            case 'left':
				returnSelector.animation.add('idle', [0], 24, false);
				returnSelector.animation.add('press', [1], 24, false);
            case 'right':
				returnSelector.animation.add('idle', [2], 24, false);
				returnSelector.animation.add('press', [3], 24, false);
            default:
				returnSelector.animation.add('idle', [0], 24, false);
				returnSelector.animation.add('press', [1], 24, false);
        }

		returnSelector.animation.play('idle');

		return returnSelector;
	}

	override public function updateHitbox(){
		for(member in members)
			member.updateHitbox();
		
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		for (object in 0...objectArray.length)
			objectArray[object].setPosition(x + (positionLog[object][0] * scale.x), y + (positionLog[object][1] * scale.y));
	}

	public function selectorPlay(whichSelector:String, animPlayed:String = 'idle')
	{
		switch (whichSelector)
		{
			case 'left':
				leftSelector.animation.play(animPlayed);
			case 'right':
				rightSelector.animation.play(animPlayed);
		}
	}

	var objectArray:Array<FlxSprite> = [];
	var positionLog:Array<Array<Float>> = [];

	override public function add(object:FlxSprite):FlxSprite
	{
		objectArray.push(object);
		positionLog.push([object.x, object.y]);
        trace(object, object.x, object.y);
		return super.add(object);
	}
}
