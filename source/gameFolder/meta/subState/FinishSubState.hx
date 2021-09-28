package gameFolder.meta.subState;

import openfl.Lib;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import gameFolder.meta.*;
import gameFolder.meta.data.Timings;
import gameFolder.meta.state.*;
import gameFolder.meta.state.menus.*;
import gameFolder.meta.MusicBeat.MusicBeatSubState;

class FinishSubState extends MusicBeatSubState
{
	var curSelected:Int = 0;

	var music:FlxSound;
	var perSongOffset:FlxText;
	
	var offsetChanged:Bool = false;
	var win:Bool = true;
	var ready = false;
	var camFollow:FlxObject;
	var week:Bool = false;
	public function new(x:Float, y:Float,?won = true,?week:Bool = false)
	{
		this.week = week;
		FlxG.state.persistentUpdate = true;
		FlxG.state.persistentDraw = true;
		win = won;
		// FlxG.sound.pause();
		PlayState.generatedMusic = false;
		var dad = PlayState.dadOpponent;
		var boyfriend = PlayState.boyfriend;
		// if(win){
		// 	for (g in [PlayState.instance.cpuStrums,PlayState.instance.playerStrums]) {
		// 		g.forEach(function(i){
		// 			FlxTween.tween(i, {y:if(FlxG.save.data.downscroll)FlxG.height + 200 else -200},1,{ease: FlxEase.expoIn});
		// 		});
		// 	}
		// 	if (FlxG.save.data.songPosition)
		// 	{
		// 		for (i in [PlayState.songPosBar,PlayState.songPosBG,PlayState.instance.songName]) {
		// 			FlxTween.tween(i, {y:if(FlxG.save.data.downscroll)FlxG.height + 200 else -200},1,{ease: FlxEase.expoIn});
		// 		}
		// 	}
		// 	FlxTween.tween(PlayState.instance.kadeEngineWatermark, {y:FlxG.height + 200},1,{ease: FlxEase.expoIn});
		// 	FlxTween.tween(PlayState.instance.scoreTxt, {y:if(FlxG.save.data.downscroll) -200 else FlxG.height + 200},1,{ease: FlxEase.expoIn});
		// }
		if(win){
			boyfriend.playAnim("hey",true);
			boyfriend.playAnim("win",true);
			if (PlayState.SONG.player2 == FlxG.save.data.gfChar) dad.playAnim('cheer'); else {dad.playAnim('singDOWNmiss');dad.playAnim('lose');}
			PlayState.gf.playAnim('cheer',true);
		}else{
			boyfriend.playAnim('singDOWNmiss');
			boyfriend.playAnim('lose');
			dad.playAnim("hey",true);
			dad.playAnim("win",true);
			if (PlayState.SONG.player2 == FlxG.save.data.gfChar) dad.playAnim('sad'); else dad.playAnim("hey");
			PlayState.gf.playAnim('sad',true);
		}
		super();
		if (win) boyfriend.animation.finishCallback = this.finishNew; else finishNew();
		FlxG.camera.zoom = 1;
		PlayState.camHUD.zoom = 1;
		// if (FlxG.save.data.camMovement){
		// 	PlayState.instance.followChar(if(win) 0 else 1);
		// }
	}

	public function finishNew(?name:String){

			if (win) PlayState.boyfriend.animation.finishCallback = null; else PlayState.dadOpponent.animation.finishCallback = null;
			ready = true;
			FlxG.state.persistentUpdate = false;
			FlxG.state.persistentDraw = true;
			FlxG.sound.pause();

			music = new FlxSound().loadEmbedded(Paths.music(if(win) 'breakfast' else 'gameOver'), true, true);
			music.play(false);
			// if(win){
			// 	music.looped = false;
			// 	music.onComplete = function(){music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);music.play(false);} 

			// }
			FlxG.camera.zoom = PlayState.camHUD.zoom = 1;

			FlxG.sound.list.add(music);

			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();

			var finishedText:FlxText = new FlxText(20,-55,0, (if(week) "Week" else "Song") + " " + (if(win) "Won!" else "failed...") );
			finishedText.size = 34;
			finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
			finishedText.color = FlxColor.WHITE;
			finishedText.scrollFactor.set();
			var comboText:FlxText = new FlxText(20,-75,0,'Preformance:'
			+'\n\nSicks - ${PlayState.sicks}'
			+'\nGoods - ${PlayState.goods}'
			+'\nBads - ${PlayState.bads}'
			+'\nShits - ${PlayState.shits}'
			+'\n\nLast Combo: ${PlayState.combo} Max: ${PlayState.maxCombo}'
			+'\nHit/Misses: ${Timings.notesHit}/${PlayState.misses}'
			+'\n\nScore: ${PlayState.songScore}'
			+'\nAccuracy: ${Timings.getAccuracy()}%'
			+'\n\n${Timings.returnScoreRating()}');
			comboText.size = 28;
			comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
			comboText.color = FlxColor.WHITE;
			comboText.scrollFactor.set();

			// var settingsText:FlxText = new FlxText(Std.int(FlxG.width * 0.45),-30,0,
			// (if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
			
			// +'\n\nSettings:'
			// +'\n\n Downscroll: ${FlxG.save.data.downscroll}'
			// +'\n Ghost Tapping: ${FlxG.save.data.ghost}'
			// +'\n HScripts: ${QuickOptionsSubState.getSetting("Song hscripts")}'
			// +'\n Safe Frames: ${FlxG.save.data.frames}'
			// +'\n Input Engine: ${PlayState.inputEngineName}'
			// +'\n Song Offset: ${FlxG.save.data.offset + PlayState.songOffset}ms'
			// );
			// settingsText.size = 28;
			// settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
			// settingsText.color = FlxColor.WHITE;
			// settingsText.scrollFactor.set();

			var contText:FlxText = new FlxText(FlxG.width - 475,FlxG.height + 100,0,'Press ENTER to continue\nor R to restart.');
			contText.size = 28;
			contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
			contText.color = FlxColor.WHITE;
			contText.scrollFactor.set();
			// var chartInfoText:FlxText = new FlxText(20,FlxG.height + 50,0,'Offset: ${FlxG.save.data.offset + PlayState.songOffset}ms | Played on ${songName}');
			// chartInfoText.size = 16;
			// chartInfoText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
			// chartInfoText.color = FlxColor.WHITE;
			// chartInfoText.scrollFactor.set();
			
			add(bg);
			add(finishedText);
			add(comboText);
			add(contText);
			// add(settingsText);
			// add(chartInfoText);

			FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
			FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
			FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
			FlxTween.tween(contText, {y:FlxG.height - 90},0.5,{ease: FlxEase.expoInOut});
			// FlxTween.tween(chartInfoText, {y:FlxG.height - 35},0.5,{ease: FlxEase.expoInOut});
			// FlxTween.tween(settingsText, {y:145},0.5,{ease: FlxEase.expoInOut});

			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]]; 
	}

	function retMenu(){
		if (PlayState.isStoryMode){FlxG.switchState(new StoryMenuState());return;}
		switch (PlayState.returnUI)
		{
			case 1:FlxG.switchState(new ModdedChartMenuState());
				

			default:FlxG.switchState(new FreeplayState());
		}
		return;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ready){
			var upP = controls.UP_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
			var rightP = controls.RIGHT_P;
			var accepted = controls.ACCEPT;
			var oldOffset:Float = 0;


			if (accepted)
			{
				retMenu();
			}

			if (FlxG.keys.justPressed.R)
			{if(win){FlxG.resetState();}else{restart();}}
		}else{
			if(FlxG.keys.justPressed.ANY){
				PlayState.boyfriend.animation.finishCallback = null;
				finishNew();
			}
		}

	}
	function restart()
	{
		ready = false;
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.music('gameOverEnd'));
		FlxG.resetState();
	}
	override function destroy()
	{
		if (music != null){music.destroy();}

		super.destroy();
	}

}