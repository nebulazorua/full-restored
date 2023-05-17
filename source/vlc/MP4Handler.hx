package vlc;

#if (hxCodec >= "2.6.1")
import hxcodec.VideoHandler;
#elseif (hxCodec == "2.6.0")
import VideoHandler;
#end

import openfl.events.Event;
import flixel.FlxG;

/**
 * Play a video using cpp.
 * Use bitmap to connect to a graphic or use `MP4Sprite`.
 */
class MP4Handler extends VideoHandler
{
	public var isDisposed:Bool = false;
	public var readyCallback:Void->Void;
	override function onVLCOpening(){
		super.onVLCOpening();
		if (readyCallback != null)
			readyCallback();
	}

	override function dispose(){
		isDisposed = true;
		super.dispose();
	}

	public function finishVideo()
		onVLCEndReached();
	
}
