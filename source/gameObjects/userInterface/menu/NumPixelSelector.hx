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

class NumPixelSelector extends FlxTypedSpriteGroup<FlxSprite>
{
	//
	var leftSelector:FNFSprite;
	var rightSelector:FNFSprite;

	public var optionChosen:FlxText;
	public var chosenOptionString:String = '';
    public var setting:String = '';
	public var step:Float = 1;
    public var min:Float = 0;
    public var max:Float = 10;
    public var value:Float = 0;

	public function new(x:Float = 0, y:Float = 0, word:String, min:Float, max:Float, step:Float=1)
	{
		// call back the function
		super(x, y);

		this.step = step;
        this.min = min;
        this.max = max;

		// generate multiple pieces
        
		var val:Float = Init.trueSettings.get(word);

		this.value = val;
		chosenOptionString = Std.string(val);
		
		leftSelector = createSelector(0, 0, word, 'left');
		setting = word;

		optionChosen = new FlxText(leftSelector.width, 0, 0,
			chosenOptionString);
		optionChosen.setFormat(Paths.font('poketext.ttf'), 8, FlxColor.BLACK, FlxTextAlign.CENTER);
		optionChosen.antialiasing = false;
		optionChosen.scrollFactor.set();
		optionChosen.y -= optionChosen.height/8;
		//optionChosen.fieldWidth = optionChosen.width;
		
		rightSelector = createSelector(optionChosen.width + leftSelector.width, 0 , word, 'right');

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

		rightSelector.x = x + (optionChosen.width + leftSelector.width);
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
		return super.add(object);
	}
}
