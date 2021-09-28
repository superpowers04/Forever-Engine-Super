package gameFolder.gameObjects.userInterface;

import flixel.FlxSprite;
import sys.FileSystem;
import flash.display.BitmapData;
import flixel.graphics.FlxGraphic;


using StringTools;

class HealthIcon extends FlxSprite
{
	// rewrite using da new icon system as ninjamuffin would say it
	public var sprTracker:FlxSprite;

	static var chars:Array<String> = ["bf","spooky","pico","mom","mom-car",'parents-christmas',"senpai","senpai-angry","spirit","spooky","bf-pixel","gf","dad","monster","monster-christmas","parents-christmas","bf-old","gf-pixel","gf-christmas","face","tankman"];

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		updateIcon(char, isPlayer);
	}

	public function updateIcon(?char:String = 'bf', ?isPlayer:Bool = false)
	{
		if ((!char.endsWith('pixel')) && (char.contains('-')))
		{
			char = char.substring(0, char.indexOf('-'));
		}

		if (!chars.contains(char) &&FileSystem.exists(Sys.getCwd() + "mods/characters/"+char+"/healthicon.png")){
			trace('Custom character with custom icon! Loading custom icon.');
			loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/characters/$char/healthicon.png')), true, 150, 150);
			char = "bf";
		}else{
			antialiasing = true;
			if (!FileSystem.exists(Paths.image('icons/icon-' + char))) char = "face";
			loadGraphic(Paths.image('icons/icon-' + char), true, 150, 150);
		}
		animation.add('icon', [0, 1], 0, false, isPlayer);
		animation.play('icon');
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
