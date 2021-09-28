package gameFolder.meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flash.media.Sound;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.font.Alphabet;

typedef MusicTime ={
	var file:String;
	var begin:Int;
	var end:Int;
	var color:Int;
	var wrapAround:Bool;
}

class SickMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var options:Array<String> = ["replace me dammit", "what are you doing, replace me"];
	var descriptions:Array<String> = ["Hello there, Please report this","Bruh"];

	var descriptionText:FlxText;
	var grpControls:FlxTypedGroup<Alphabet>;
	var selected:Bool = false;
	var bg:FlxSprite;
	var isMainMenu:Bool = false;


	function goBack(){
		FlxG.switchState(new MainMenuState());
	}
	function generateList(){
		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			if (i != 0)
				controlLabel.alpha = 0.6;
			grpControls.add(controlLabel);
		}
	}

	override function create()
	{
		super.create();
		bg = new FlxSprite(-85);
		bg.loadGraphic(Paths.image('menus/base/menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		ForeverTools.resetMenuMusic();


		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);
		generateList();

		descriptionText = new FlxText(5, FlxG.height - 18, 0, descriptions[0], 12);
		descriptionText.scrollFactor.set();
		descriptionText.setFormat(ForeverTools.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		var blackBorder:FlxSprite = new FlxSprite(-30,FlxG.height - 18).makeGraphic((FlxG.width),40,FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(descriptionText);


		FlxG.mouse.visible = false;
		FlxG.autoPause = true;


	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (selected) return;
		if (controls.BACK)
		{
			goBack();
		}
		if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
		if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}

		if (controls.ACCEPT)
		{

			select(curSelected);
		}
	}
	function select(sel:Int){
		trace("Why wasn't this replaced?");
	}
	function changeSelection(change:Int = 0)
	{

		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;


		descriptionText.text = descriptions[curSelected];


		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.color = 0xdddddd;
			if (item.targetY == 0)
			{
				item.alpha = 1;
				item.color = 0xffffff;
			}
		}

	}
}
