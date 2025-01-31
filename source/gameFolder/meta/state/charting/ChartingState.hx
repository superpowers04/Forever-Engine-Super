package gameFolder.meta.state.charting;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import gameFolder.gameObjects.*;
import gameFolder.gameObjects.userInterface.*;
import gameFolder.gameObjects.userInterface.notes.*;
import gameFolder.gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.Section.SwagSection;
import gameFolder.meta.data.Song.SwagSong;
import gameFolder.meta.data.dependency.Discord;
import gameFolder.meta.subState.charting.*;
import haxe.Json;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

#if !html5
import sys.thread.Thread;
#end

/**
	As the name implies, this is the class where all of the charting state stuff happens, so when you press 7 the game
	state switches to this one, where you get to chart songs and such. I'm planning on overhauling this entirely in the future
	and making it both more practical and more user friendly.
**/
class ChartingState extends MusicBeatState
{
	var _song:SwagSong;

	var songMusic:FlxSound;
	var vocals:FlxSound;
	private var keysTotal = 8;

	var strumLine:FlxSprite;

	var camHUD:FlxCamera;
	var camGame:FlxCamera;
	var strumLineCam:FlxObject;

	public static var songPosition:Float = 0;
	public static var curSong:SwagSong;

	public static var gridSize:Int = 50;

	private var dummyArrow:FlxSprite;
	private var curRenderedNotes:FlxTypedGroup<Note>;
	private var curRenderedSustains:FlxTypedGroup<Note>;
	private var curRenderedSections:FlxTypedGroup<FlxBasic>;

	override public function create()
	{
		//
		super.create();

		generateBackground();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
			_song = Song.loadFromJson('test', 'test');

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		generateGrid();

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<Note>();
		curRenderedSections = new FlxTypedGroup<FlxBasic>();

		add(curRenderedSections);
		add(curRenderedSustains);
		add(curRenderedNotes);

		strumLineCam = new FlxObject(0, 0);
		strumLineCam.screenCenter(X);

		// epic strum line
		strumLine = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width / 2), 2);
		add(strumLine);
		strumLine.screenCenter(X);

		// code from the playstate so I can separate the camera and hud
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		FlxG.camera.follow(strumLineCam);
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			if (songMusic.playing)
			{
				songMusic.pause();
				vocals.pause();
				// playButtonAnimation('pause');
			}
			else
			{
				vocals.play();
				songMusic.play();

				// reset note tick sounds
				// hitSoundsPlayed = [];

				// playButtonAnimation('play');
			}
		}

		var scrollSpeed:Float = 0.75;
		if (FlxG.mouse.wheel != 0)
		{
			songMusic.pause();
			vocals.pause();

			songMusic.time = Math.max(songMusic.time - (FlxG.mouse.wheel * Conductor.stepCrochet * scrollSpeed), 0);
			songMusic.time = Math.min(songMusic.time, songMusic.length);
			vocals.time = songMusic.time;
		}

		// strumline camera stuffs!
		Conductor.songPosition = songMusic.time;

		strumLine.y = getYfromStrum(Conductor.songPosition);
		strumLineCam.y = strumLine.y + (FlxG.height / 3);

		coolGradient.y = strumLineCam.y - (FlxG.height / 2);
		coolGrid.y = strumLineCam.y - (FlxG.height / 2);

		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
		{
			songPosition = songMusic.time;

			PlayState.SONG = _song;
			ForeverTools.killMusic([songMusic, vocals]);
			Main.switchState(this, new PlayState());
		}
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, 0, (songMusic.length / Conductor.stepCrochet) * gridSize, songMusic.length, 0);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, songMusic.length, 0, (songMusic.length / Conductor.stepCrochet) * gridSize);
	}

	var fullGrid:FlxTiledSprite;

	function generateGrid()
	{
		// create new sprite
		var base:FlxSprite = FlxGridOverlay.create(gridSize, gridSize, gridSize * 2, gridSize * 2, true, FlxColor.WHITE, FlxColor.BLACK);
		fullGrid = new FlxTiledSprite(null, gridSize * keysTotal, gridSize);
		// base graphic change data
		var newAlpha = (26 / 255);
		base.graphic.bitmap.colorTransform(base.graphic.bitmap.rect, new ColorTransform(1, 1, 1, newAlpha));
		fullGrid.loadGraphic(base.graphic);
		fullGrid.screenCenter(X);

		// fullgrid height
		fullGrid.height = (songMusic.length / Conductor.stepCrochet) * gridSize;

		add(fullGrid);
	}

	function generateNotes()
	{
		// GENERATING THE GRID NOTES!
	}

	function loadSong(daSong:String):Void
	{
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();

		songMusic = new FlxSound().loadEmbedded(Sound.fromFile('./' + Paths.inst(daSong)), false, true);
		if (_song.needsVoices)
			vocals = new FlxSound().loadEmbedded(Sound.fromFile('./' + Paths.voices(daSong)), false, true);
		else
			vocals = new FlxSound();
		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		songMusic.play();
		vocals.play();

		if (curSong == _song)
			songMusic.time = songPosition;
		curSong = _song;

		pauseMusic();

		songMusic.onComplete = function()
		{
			ForeverTools.killMusic([songMusic, vocals]);
			loadSong(daSong);
		};
		//
	}

	private function generateChartNote(daNoteInfo, daStrumTime, daSus, daNoteAlt, noteSection, curNoteMap:Map<Note, Dynamic>)
	{
		//
		var note:Note = new Note(daStrumTime, daNoteInfo % 4, daNoteAlt);
		// I love how there's 3 different engines that use this exact same variable name lmao
		note.rawNoteData = daNoteInfo;
		note.sustainLength = daSus;
		note.setGraphicSize(gridSize, gridSize);
		note.updateHitbox();

		note.screenCenter(X);
		note.x -= ((gridSize * (keysTotal / 2)) - (gridSize / 2));
		note.x += Math.floor(adjustSide(daNoteInfo, _song.notes[noteSection].mustHitSection) * gridSize);

		note.y = Math.floor(getYfromStrum(daStrumTime));

		curRenderedNotes.add(note);

		curNoteMap.set(note, null);
		generateSustain(daStrumTime, daNoteInfo, daSus, daNoteAlt, note, curNoteMap);
	}

	private function generateSustain(daStrumTime:Float = 0, daNoteInfo:Int = 0, daSus:Float = 0, daNoteAlt:Float = 0, note:Note, curNoteMap:Map<Note, Dynamic>)
	{
		/*
			if (daSus > 0)
			{
				//prevNote = note;
				var constSize = Std.int(gridSize / 3);

				var sustainVis:Note = new Note(daStrumTime + (Conductor.stepCrochet * daSus) + Conductor.stepCrochet, daNoteInfo % 4, daNoteAlt, prevNote, true);
				sustainVis.setGraphicSize(constSize,
					Math.floor(FlxMath.remapToRange((daSus / 2) - constSize, 0, Conductor.stepCrochet * verticalSize, 0, gridSize * verticalSize)));
				sustainVis.updateHitbox();
				sustainVis.x = note.x + constSize;
				sustainVis.y = note.y + (gridSize / 2);

				var sustainEnd:Note = new Note(daStrumTime + (Conductor.stepCrochet * daSus) + Conductor.stepCrochet, daNoteInfo % 4, daNoteAlt, sustainVis, true);
				sustainEnd.setGraphicSize(constSize, constSize);
				sustainEnd.updateHitbox();
				sustainEnd.x = sustainVis.x;
				sustainEnd.y = note.y + (sustainVis.height) + (gridSize / 2);

				// loll for later
				sustainVis.rawNoteData = daNoteInfo;
				sustainEnd.rawNoteData = daNoteInfo;

				curRenderedSustains.add(sustainVis);
				curRenderedSustains.add(sustainEnd);
				//

				// set the note at the current note map
				curNoteMap.set(note, [sustainVis, sustainEnd]);
			}
		 */
	}

	///*
	var coolGrid:FlxBackdrop;
	var coolGradient:FlxSprite;

	private function generateBackground()
	{
		coolGrid = new FlxBackdrop(null, 1, 1, true, true, 1, 1);
		coolGrid.loadGraphic(Paths.image('UI/forever/base/chart editor/grid'));
		coolGrid.alpha = (32 / 255);
		add(coolGrid);

		// gradient
		coolGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			FlxColor.gradient(FlxColor.fromRGB(188, 158, 255, 200), FlxColor.fromRGB(80, 12, 108, 255), 16));
		coolGradient.alpha = (32 / 255);
		add(coolGradient);
	}

	function adjustSide(noteData:Int, sectionTemp:Bool)
	{
		return (sectionTemp ? ((noteData + 4) % 8) : noteData);
	}

	function pauseMusic()
	{
		songMusic.time = Math.max(songMusic.time, 0);
		songMusic.time = Math.min(songMusic.time, songMusic.length);

		resyncVocals();
		songMusic.pause();
		vocals.pause();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		songMusic.play();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	// */
}
