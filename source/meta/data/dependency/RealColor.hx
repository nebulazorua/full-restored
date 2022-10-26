package meta.data.dependency;
import flixel.util.FlxColor;

class RealColor {
	public static inline var TRANSPARENT:FlxColor = 0x00000000;
	public static inline var WHITE:FlxColor = 0xFFFFFFFF;
	public static inline var GRAY:FlxColor = 0xFF808080;
	public static inline var BLACK:FlxColor = 0xFF000000;

	public static inline var GREEN:FlxColor = 0xFF008000;
	public static inline var LIME:FlxColor = 0xFF00FF00;
	public static inline var YELLOW:FlxColor = 0xFFFFFF00;
	public static inline var ORANGE:FlxColor = 0xFFFFA500;
	public static inline var RED:FlxColor = 0xFFFF0000;
	public static inline var PURPLE:FlxColor = 0xFF800080;
	public static inline var BLUE:FlxColor = 0xFF0000FF;
	public static inline var BROWN:FlxColor = 0xFF8B4513;
	public static inline var PINK:FlxColor = 0xFFFFC0CB;
	public static inline var MAGENTA:FlxColor = 0xFFFF00FF;
	public static inline var CYAN:FlxColor = 0xFF00FFFF;
	
	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):FlxColor
		return FlxColor.fromRGB(Red, Green, Blue, Alpha);
}