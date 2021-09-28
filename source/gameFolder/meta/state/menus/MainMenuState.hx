package gameFolder.meta.state.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

// For Title Screen GF
import flixel.graphics.FlxGraphic;
import flixel.animation.FlxAnimation;
import flixel.animation.FlxBaseAnimation;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import flixel.util.FlxAxes;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.dependency.Discord;
import flixel.addons.transition.FlxTransitionableState;


using StringTools;

class MainMenuState extends SickMenuState
{
	
	public static var firstStart:Bool = true;

	public static var bgcolor:Int = 0;
	public static var errorMessage:String = "";
	public static function handleError(?error:String = "An error occurred",?details:String=""):Void{
		if (errorMessage != "") return; // Prevents it from trying to switch states multiple times
		MainMenuState.errorMessage = error;
		if(details != "") trace(details);

		FlxG.switchState(new MainMenuState());
		
	}

	override function create()
	{
		options = ['story mode',"freeplay","modded charts","character selection","options"];
		descriptions = ['Play a story mode week','Play a single song','Play charts from your mods/charts folder','Select your characters','Customise your experience'];

		super.create();

		#if !html5
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		var versionShit:FlxText = new FlxText(5, FlxG.height - 34, 0, "Forever Engine v" + Main.gameVersion + "-Super", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(ForeverTools.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		if (MainMenuState.errorMessage != ""){

			FlxG.sound.play(Paths.sound('cancelMenu'));
			trace(errorMessage);
			var errorText =  new FlxText(2, 64, 0, MainMenuState.errorMessage, 12);
		    errorText.scrollFactor.set();
		    errorText.wordWrap = true;
		    errorText.fieldWidth = 1200;
		    errorText.setFormat(ForeverTools.font, 32, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		    add(errorText);
		    MainMenuState.errorMessage="";
		}
	}



	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		super.update(elapsed);
	}
	
  override function select(sel:Int){
  	    if (selected){return;}
    	selected = true;
		var daChoice:String = options[sel];
		FlxG.sound.play(Paths.sound('confirmMenu'));
		
		switch (daChoice)
		{
			case 'story mode':
				Main.switchState(this, new StoryMenuState());
			case 'freeplay':
				Main.switchState(this, new FreeplayState());
			case 'modded charts':
				Main.switchState(this, new ModdedChartMenuState());
			case 'character selection':
				Main.switchState(this, new CharaSelectionMenu());
			case 'options':
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				Main.switchState(this, new OptionsMenuState());
		}
	}
}
