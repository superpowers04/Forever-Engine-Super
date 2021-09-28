package gameFolder.gameObjects;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import Init;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxAnimation;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import gameFolder.meta.*;
import gameFolder.meta.state.menus.MainMenuState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.dependency.FNFSprite;
import gameFolder.meta.state.PlayState;
import openfl.utils.Assets as OpenFlAssets;
// import CharacterJson;
import gameFolder.meta.state.TitleState;
import flixel.util.FlxColor;

import flash.media.Sound;

import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import Xml;
import flixel.system.FlxSound;


using StringTools;

class Character extends FNFSprite
{
	// By default, this option set to FALSE will make it so that the character only dances twice per major beat hit
	// If set to on, they will dance every beat, such as Skid and Pump
	public var quickDancer:Bool = false;

	public var debugMode:Bool = false;
	public var dance_idle:Bool = false; // Use this instead of checking character name

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var clonedChar:String = '';
	public static var defaultChars:Array<String> = ['bf','dad','gf'];

	// Eventially will be added
	public var charX:Float = 0;
	public var charY:Float = 0;
	public var camX:Float = 0;
	public var camY:Float = 0;
	var tex:FlxAtlasFrames;
	var flipNotes:Bool = true;
	var loadedFrom:String = "";
	var flip:Bool = false;


	public var holdTimer:Float = 0;
	var simplifiedCharacter:String = "";



	public var spiritTrail:Bool = false; // Not implemented at the moment
	public var tintedAnims:Array<String> = [];
	public var definingColor:FlxColor = 0xFFFFFF;
	var loopAnimFrames:Map<String,Int> = new Map();
	var isCustom:Bool = false;
	var charType:Int = 0;
	var needsInverted:Int = 1;
	var customColor:Bool = false;
	var charProperties:CharacterJson;

	// Copypasted from BR but modified
	inline function isValidInt(num:Null<Int>,?def:Int = 0) {return if (num == null) def else num;}
	function loadJSONChar(charProperties:CharacterJson){
		
		trace('Loading Json animations!');
		// BF's animations, they're used by default to prevent crashes
		addAnimation('idle', 'BF idle dance', 24, false);
		addAnimation('singUP', 'BF NOTE UP0', 24, false);
		// WHY DO THESE NEED TO BE FLIPPED?
		addAnimation('singLEFT', 'BF NOTE RIGHT0', 24, false); 
		addAnimation('singRIGHT', 'BF NOTE LEFT0', 24, false);
		addAnimation('singDOWN', 'BF NOTE DOWN0', 24, false);
		addAnimation('singUPmiss', 'BF NOTE UP MISS', 24, false);

		addAnimation('singRIGHTmiss', 'BF NOTE LEFT MISS', 24, false);
		addAnimation('singLEFTmiss', 'BF NOTE RIGHT MISS', 24, false);

		addAnimation('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
		addAnimation('hey', 'BF HEY', 24, false);



		holdTimer = charProperties.sing_duration; // As the varname implies
		flipX=charProperties.flip_x; // Flip for BF clones
		spiritTrail=charProperties.spirit_trail; // Spirit TraiL
		antialiasing = !charProperties.no_antialiasing; 
		dance_idle = charProperties.dance_idle; // Handles if the character uses Spooky/GF's dancing animation

		if (charProperties.flip_notes) flipNotes = charProperties.flip_notes;

		if(!customColor && charProperties.color != null){
			definingColor = FlxColor.fromRGB(isValidInt(charProperties.color[0]),isValidInt(charProperties.color[1]),isValidInt(charProperties.color[2],255));
			customColor = true;
		}

		
		trace('Loading Animations!');
		var animCount = 0;
		for (anima in charProperties.animations){
			try{
			if (anima.stage != "" && anima.stage != null){if(PlayState.curStage.toLowerCase() != anima.stage.toLowerCase()){continue;}} // Check if animation specifies stage, skip if it doesn't match PlayState's stage
			if (anima.song != "" && anima.song != null){if(PlayState.SONG.song.toLowerCase() != anima.song.toLowerCase()){continue;}} // Check if animation specifies song, skip if it doesn't match PlayState's song
			if (animation.getByName(anima.anim) != null){continue;} // Skip if animation has already been defined
			if (anima.char_side != null && anima.char_side != 3 && anima.char_side == charType){continue;} // This if statement hurts my brain
			
			 //  Not setup yet

			// if (anima.ifstate != null){
			// 	trace("Loading a animation with ifstatement...");
			// 	if (anima.ifstate.check == 1 ){ // Do on step or beat
			// 		if (PlayState.stepAnimEvents[charType] == null) PlayState.stepAnimEvents[charType] = [anima.anim => anima.ifstate]; else PlayState.stepAnimEvents[charType][anima.anim] = anima.ifstate;
			// 	} else {
			// 		if (PlayState.beatAnimEvents[charType] == null) PlayState.beatAnimEvents[charType] = [anima.anim => anima.ifstate]; else PlayState.beatAnimEvents[charType][anima.anim] = anima.ifstate;
			// 	}
				
			// 	// PlayState.regAnimEvent(charType,anima.ifstate,anima.anim);
			// }
			// if (anima.oneshot == true){ // "On static platforms, null can't be used as basic type Bool" bruh
			// 	oneShotAnims.push(anima.anim);
			// 	anima.loop = false; // Looping when oneshot is a terrible idea
			// }
			if(anima.loopStart != null && anima.loopStart != 0 )loopAnimFrames[anima.anim] = anima.loopStart;

			if (anima.indices.length > 0) { // Add using indices if specified
				addAnimation(anima.anim, anima.name,anima.indices,"", anima.fps, anima.loop);
			}else{addAnimation(anima.anim, anima.name, anima.fps, anima.loop);}
			}catch(e){MainMenuState.handleError('${curCharacter} had an animation error ${e.message}');break;}
			animCount++;
		}
		trace('Registered ${animCount} animations');
		setGraphicSize(Std.int(width * charProperties.scale)); // Setting size
		updateHitbox();


		if(charProperties.flip != null) flip = charProperties.flip;
		clonedChar = charProperties.clone;
		if (clonedChar != null && clonedChar != "") {
			trace('Character clones $clonedChar copying their offsets!');
			setupOffsets(clonedChar);
		}
		if (charProperties.like != null && charProperties.like != "") clonedChar = charProperties.like;
		trace('Adding custom offsets');
		loadOffsetsFromJSON(charProperties);

	}
	function loadOffsetsFromJSON(?charProperties:CharacterJson){
		if (charProperties == null) return;
		if (charProperties.offset_flip != null ) needsInverted = charProperties.offset_flip;
		if ((charProperties.like != null && charProperties.like == "bf") || (charProperties.clone != null && charProperties.clone == "bf")) moveOffsets(0,300);
		var offsetCount = 0;
		if (charProperties.animations_offsets != null && charProperties.animations_offsets.length > 0){

			for (offset in charProperties.animations_offsets){ // Custom offsets
				offsetCount++;
				if (needsInverted == 1)
					switch (charType) {
						case 0:
							if (offset.player1 != null && offset.player1.length > 1) addOffset(offset.anim,offset.player1[0],offset.player1[1]);
						case 1:
							if (offset.player2 != null && offset.player2.length > 1) addOffset(offset.anim,offset.player2[0],offset.player2[1]); else if (offset.player1 != null && offset.player1.length > 1) addOffset(offset.anim,offset.player1[0],offset.player1[1]);
						case 2:
							if (offset.player3 != null && offset.player3.length > 1) addOffset(offset.anim,offset.player3[0],offset.player3[1]); else if (offset.player1 != null && offset.player1.length > 1) addOffset(offset.anim,offset.player1[0],offset.player1[1]);
					}
				else
					addOffset(offset.anim,offset.player1[0],offset.player1[1]);
			}	
		}


		switch(charType){
			case 0: if (charProperties.char_pos1 != null){moveOffsets(charProperties.char_pos1[0],charProperties.char_pos1[1]);}
			case 1: if (charProperties.char_pos2 != null){moveOffsets(charProperties.char_pos2[0],charProperties.char_pos2[1]);}
			case 2: if (charProperties.char_pos3 != null){moveOffsets(charProperties.char_pos3[0],charProperties.char_pos3[1]);}
		}

		switch(charType){
			case 0: if (charProperties.cam_pos1 != null){camX += charProperties.cam_pos1[0];camY += charProperties.cam_pos1[1];}
			case 1: if (charProperties.cam_pos2 != null){camX += charProperties.cam_pos2[0];camY += charProperties.cam_pos2[1];}
			case 2: if (charProperties.cam_pos3 != null){camX += charProperties.cam_pos3[0];camY += charProperties.cam_pos3[1];}
		}
		if(charProperties.common_stage_offset != null){
			if (needsInverted == 1 && !isPlayer){
				addOffset('all',charProperties.common_stage_offset[2],charProperties.common_stage_offset[3]); // Load common stage offset
				camX+=charProperties.common_stage_offset[2];
				camY-=charProperties.common_stage_offset[3]; // Load common stage offset for camera too
			}else{
				addOffset('all',charProperties.common_stage_offset[0],charProperties.common_stage_offset[1]); // Load common stage offset
				camX+=charProperties.common_stage_offset[0];
				camY-=charProperties.common_stage_offset[1]; // Load common stage offset for camera too
			}
		}
		if(!customColor && charProperties.color != null){
			definingColor = FlxColor.fromRGB(isValidInt(charProperties.color[0]),isValidInt(charProperties.color[1]),isValidInt(charProperties.color[2],255));
		}
		if (charProperties.char_pos != null){addOffset('all',charProperties.char_pos[0],charProperties.char_pos[1]);}
		if (charProperties.cam_pos != null){camX+=charProperties.cam_pos[0];camY+=charProperties.cam_pos[1];}
		trace('Loaded ${offsetCount} offsets!');
	}
	function loadCustomChar(){
		trace('Loading a custom character "$curCharacter"! ');				
		isCustom = true;
		var charPropJson:String = "";
		if (charProperties == null) {charPropJson = File.getContent('mods/characters/$curCharacter/config.json');charProperties = haxe.Json.parse(CoolUtil.cleanJSON(charPropJson));}
		if (charProperties == null || charProperties.animations == null || charProperties.animations[0] == null){MainMenuState.handleError('$curCharacter\'s JSON is invalid!');} // Boot to main menu if character's JSON can't be loaded
		loadedFrom = 'mods/characters/$curCharacter/config.json';
		var pngName:String = "character.png";
		var xmlName:String = "character.xml";
		var forced:Int = 0;
		if (charProperties.asset_files != null){
			var invChIDs:Array<Int> = [1,0,2];
			var selAssets = -10;
			for (i => charFile in charProperties.asset_files) {
				if (charFile.char_side != null && charFile.char_side != 3 && charFile.char_side == charType){continue;} // This if statement hurts my brain
				if (charFile.stage != "" && charFile.stage != null){if(PlayState.curStage.toLowerCase() != charFile.stage.toLowerCase()){continue;}} // Check if charFiletion specifies stage, skip if it doesn't match PlayState's stage
				if (charFile.song != "" && charFile.song != null){if(PlayState.SONG.song.toLowerCase() != charFile.song.toLowerCase()){continue;}} // Check if charFiletion specifies song, skip if it doesn't match PlayState's song
				var tagsMatched = 0;
				// if (charFile.tags != null && charFile.tags[0] != null && PlayState.stageTags != null){
				// 	for (i in charFile.tags) {if (PlayState.stageTags.contains(i)) tagsMatched++;}
				// 	if (tagsMatched == 0) continue;
				// }
				
				if (forced == 0 || tagsMatched == forced)
					selAssets = i;
			}
			if (selAssets != -10){
				if (charProperties.asset_files[selAssets].png != null )pngName=charProperties.asset_files[selAssets].png;
				if (charProperties.asset_files[selAssets].xml != null )xmlName=charProperties.asset_files[selAssets].xml;
				if (charProperties.asset_files[selAssets].animations != null )charProperties.animations=charProperties.asset_files[selAssets].animations;
				if (charProperties.asset_files[selAssets].animations_offsets != null )charProperties.animations_offsets=charProperties.asset_files[selAssets].animations_offsets;
			}
		}


		if (tex == null){
			var charJsonF:String = ('mods/characters/$curCharacter/${xmlName}').substr(0,-3) + "json";
			if (FileSystem.exists(charJsonF)){
				var charXml:String = File.getContent(charJsonF); 				
				if (charXml == null){MainMenuState.handleError('$curCharacter is missing their sprite JSON?');} // Boot to main menu if character's XML can't be loaded

				tex = FlxAtlasFrames.fromTexturePackerJson(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/characters/$curCharacter/${pngName}')), charXml);
			} else {
				var charXml:String = File.getContent('mods/characters/$curCharacter/${xmlName}'); // Loads the XML as a string
				if (charXml == null){MainMenuState.handleError('$curCharacter is missing their XML!');} // Boot to main menu if character's XML can't be loaded
				tex = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/characters/$curCharacter/${pngName}')), charXml);
			}
			if (tex == null){MainMenuState.handleError('$curCharacter is missing their XML!');} // Boot to main menu if character's texture can't be loaded
		}
		trace('Loaded "mods/characters/$curCharacter/${pngName}"');
		frames = tex;


		if (charProperties == null) trace("No charProperites?");
		loadJSONChar(charProperties);
		// Custom misses   Not implemented yet
		// if (charType == 0 && !amPreview && !debugMode){
		// 	switch(charProperties.custom_misses){
		// 		case 1: // Custom misses using FNF Multi custom sounds
		// 			useMisses = true;
		// 			missSounds = [Sound.fromFile('mods/characters/$curCharacter/custom_left.ogg'), Sound.fromFile('mods/characters/$curCharacter/custom_down.ogg'), Sound.fromFile('mods/characters/$curCharacter/custom_up.ogg'),Sound.fromFile('mods/characters/$curCharacter/custom_right.ogg')];
		// 		case 2: // Custom misses using Predefined sound names
		// 			useMisses = true;
		// 			missSounds = [Sound.fromFile('mods/characters/$curCharacter/miss_left.ogg'), Sound.fromFile('mods/characters/$curCharacter/miss_down.ogg'), Sound.fromFile('mods/characters/$curCharacter/miss_up.ogg'),Sound.fromFile('mods/characters/$curCharacter/miss_right.ogg')];
		// 	}
		// }
		// if (FlxG.save.data.playVoices && charProperties.voices == "custom") {
		// 	useVoices = true;
		// 	voiceSounds = [new FlxSound().loadEmbedded(Sound.fromFile('mods/characters/$curCharacter/custom_left.ogg')), new FlxSound().loadEmbedded(Sound.fromFile('mods/characters/$curCharacter/custom_down.ogg')), new FlxSound().loadEmbedded(Sound.fromFile('mods/characters/$curCharacter/custom_up.ogg')),new FlxSound().loadEmbedded(Sound.fromFile('mods/characters/$curCharacter/custom_right.ogg'))];

		// }
		// if (FileSystem.exists('mods/characters/$curCharacter/script.hscript')){
		// 	parseHScript(File.getContent('mods/characters/$curCharacter/script.hscript'));
		// 	trace("Loaded HScript");
		// 	callInterp("initScript",[],true);
		// }
		 // Checks which animation to play, if dance_idle is true, play GF/Spooky dance animation, otherwise play normal idle

		trace('Finished loading character, Lets get funky!');
		}






	function setupOffsets(char:String = ""){
		if (OpenFlAssets.exists(Paths.offsetTxt(char + 'Offsets')))
		{
			var characterOffsets:Array<String> = CoolUtil.coolTextFile(Paths.offsetTxt(char + 'Offsets'));
			for (i in 0...characterOffsets.length)
			{
				var getterArray:Array<Array<String>> = CoolUtil.getOffsetsFromTxt(Paths.offsetTxt(char + 'Offsets'));
				addOffset(getterArray[i][0], Std.parseInt(getterArray[i][1]), Std.parseInt(getterArray[i][2]));
			}
		}
	}

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false,?charId:Int = 0)
	{
		super(x, y);
		this.isPlayer = isPlayer;
		charType = charId;

		setCharacter(character);
	}
	public static function validChar(char:String,?charId:Int = 0):String{
		var chartCharValid:Bool = (TitleState.choosableCharactersLower[char.toLowerCase()] != null);
		var selCharValid:Bool = TitleState.choosableCharactersLower[Init.getChar(charId).toLowerCase()] != null;
		var forcedselChar:Bool = (Init.trueSettings.get('Force selected opponent') || charId != 1);
		

		if ((forcedselChar || !chartCharValid) && selCharValid ){ // While this shouldn't return null, always better to be safe than sorry
			trace('loading ${charId} from settings');
			return TitleState.choosableCharactersLower[Init.getChar(charId).toLowerCase()];
		}else if (chartCharValid){
			trace('loading ${charId} from song');
			return TitleState.choosableCharactersLower[char.toLowerCase()];
		}
		trace('loading ${charId} from defaults');
		return defaultChars[charId];
	}

	function setCharacter(character:String)
	{
		curCharacter = character;
		// var tex:FlxAtlasFrames;
		antialiasing = true;

		definingColor = (isPlayer ? 0xFF66FF33 : 0xFFFF0000);
		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);
				dance_idle = true;

				playAnim('danceRight');

			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('characters/gfChristmas');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);
				dance_idle = true;

				playAnim('danceRight');

			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);
				dance_idle = true;

				playAnim('danceRight');

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);
				dance_idle = true;

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'gf-tankmen':
				frames = Paths.getSparrowAtlas('characters/gfTankmen');

				animation.addByIndices('sad', 'GF Crying at Gunpoint', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				dance_idle = true;

				playAnim('danceRight');

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				playAnim('idle');
			case 'spooky':
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);
				dance_idle = true;

				quickDancer = true;

				playAnim('danceRight');
			case 'mom':
				tex = Paths.getSparrowAtlas('characters/Mom_Assets');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!

				// maybe youre just dumb for not telling him to name it that
				// dw im also dumb
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				playAnim('idle');

			case 'mom-car':
				tex = Paths.getSparrowAtlas('characters/momCar');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByIndices('idlePost', 'Mom Idle', [10, 11, 12, 13], "", 24, true);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				playAnim('idle');
			case 'monster':
				tex = Paths.getSparrowAtlas('characters/Monster_Assets');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster Right note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster left note', 24, false);

				playAnim('idle');
			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('characters/monsterChristmas');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				playAnim('idle');
			case 'pico':
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				playAnim('idle');

				flipX = true;

			case 'bf':
				frames = Paths.getSparrowAtlas('characters/BOYFRIEND');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);

				playAnim('idle');

				flipX = true;
			/*
				case 'bf-og':
					frames = Paths.getSparrowAtlas('characters/og/BOYFRIEND');

					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('scared', 'BF idle shaking', 24);
					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

					playAnim('idle');

					flipX = true;
			 */

			case 'bf-dead':
				frames = Paths.getSparrowAtlas('characters/BF_DEATH');

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				playAnim('firstDeath');

				flipX = true;

			case 'bf-holding-gf':
				frames = Paths.getSparrowAtlas('characters/bfAndGF');

				animation.addByPrefix('idle', 'BF idle dance w gf', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				playAnim('idle');

				flipX = true;

			case 'bf-holding-gf-dead':
				frames = Paths.getSparrowAtlas('characters/bfHoldingGF-DEAD');

				animation.addByPrefix('firstDeath', "BF Dies with GF", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead with GF Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY confirm holding gf", 24, false);

				playAnim('firstDeath');

			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('characters/bfChristmas');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				playAnim('idle');

				flipX = true;
			case 'bf-car':
				var tex = Paths.getSparrowAtlas('characters/bfCar');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByIndices('idlePost', 'BF idle dance', [8, 9, 10, 11, 12, 13, 14], "", 24, true);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				playAnim('idle');

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;

			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				playAnim('idle');
			case 'tankman':
				frames = Paths.getSparrowAtlas('characters/tankmanCaptain');
				animation.addByPrefix('idle', 'Tankman Idle Dance instance', 24, false);

				animation.addByPrefix('singUP', 'Tankman UP note instance', 24, false);
				animation.addByPrefix('singRIGHT', 'Tankman Note Left instance', 24, false);
				animation.addByPrefix('singLEFT', 'Tankman Right Note instance', 24, false);
				animation.addByPrefix('singDOWN', 'Tankman DOWN note instance', 24, false);

				animation.addByPrefix('singUP-alt', 'TANKMAN UGH instance', 24, false);
				animation.addByPrefix('singDOWN-alt', 'PRETTY GOOD tankman instance', 24, false);

				flipX = true;
				playAnim('idle');
			// flipX = true;
			case 'pico-speaker':
				frames = Paths.getSparrowAtlas('characters/picoSpeaker');

				animation.addByPrefix('shoot1', 'Pico shoot 1', 24, false);
				animation.addByPrefix('shoot2', 'Pico shoot 2', 24, false);
				animation.addByPrefix('shoot3', 'Pico shoot 3', 24, false);
				animation.addByPrefix('shoot4', 'Pico shoot 4', 24, false);

				playAnim('shoot1');
			default:
				if (TitleState.choosableCharacters.contains(curCharacter)){ // Custom character?
					loadCustomChar();
				}else{
					// set up animations if they aren't already

					// fyi if you're reading this this isn't meant to be well made, it's kind of an afterthought I wanted to mess with and
					// I'm probably not gonna clean it up and make it an actual feature of the engine I just wanted to play other people's mods but not add their files to
					// the engine because that'd be stealing assets
					curCharacter = "dad";
					var fileNew = curCharacter + 'Anims';
					
					if (OpenFlAssets.exists(Paths.offsetTxt(fileNew)))
					{
						var characterAnims:Array<String> = CoolUtil.coolTextFile(Paths.offsetTxt(fileNew));
						var characterName:String = characterAnims[0].trim();
						frames = Paths.getSparrowAtlas('characters/$characterName');
						for (i in 1...characterAnims.length)
						{
							var getterArray:Array<Array<String>> = CoolUtil.getAnimsFromTxt(Paths.offsetTxt(fileNew));
							animation.addByPrefix(getterArray[i][0], getterArray[i][1].trim(), 24, false);
						}
					}
					else
					{
						// DAD ANIMATION LOADING CODE
						tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST');
						frames = tex;
						animation.addByPrefix('idle', 'Dad idle dance', 30, false);
						animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
						animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
						animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
						animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

						playAnim('idle');
					}
				}
		}

		// set up offsets cus why not
		if (!isCustom) setupOffsets(curCharacter);

		dance();
		simplifiedCharacter = simplifyCharacter();

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
				flipLeftRight();
			//
		}
		else if (curCharacter.startsWith('bf'))
			flipLeftRight();
		for (i in ['RIGHT','UP','LEFT','DOWN']) { // Add main animations over miss if miss isn't present
			if (animation.getByName('sing${i}miss') == null){
				cloneAnimation('sing${i}miss', animation.getByName('sing$i'));
				tintedAnims.push('sing${i}miss');
			}
		}
		if(animation.curAnim == null){MainMenuState.handleError('$curCharacter is missing an idle/dance animation!');}
	}

	function flipLeftRight():Void
	{
		// get the old right sprite
		var oldRight = animation.getByName('singRIGHT').frames;

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		// insert ninjamuffin screaming I think idk I'm lazy as hell

		if (animation.getByName('singRIGHTmiss') != null)
		{
			var oldMiss = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		var curCharSimplified:String = simplifyCharacter();
		switch (curCharSimplified)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
				if ((animation.curAnim.name.startsWith('sad')) && (animation.curAnim.finished))
					playAnim('danceLeft');
		}

		// Post idle animation (think Week 4 and how the player and mom's hair continues to sway after their idle animations are done!)
		if (animation.curAnim.finished && animation.curAnim.name == 'idle')
		{
			// We look for an animation called 'idlePost' to switch to
			if (animation.getByName('idlePost') != null)
				// (( WE DON'T USE 'PLAYANIM' BECAUSE WE WANT TO FEED OFF OF THE IDLE OFFSETS! ))
				animation.play('idlePost', true, false, 0);
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if (!debugMode)
		{
			switch (simplifiedCharacter)
			{
				case 'gf':
					if ((!animation.curAnim.name.startsWith('hair')) && (!animation.curAnim.name.startsWith('sad')))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
				default:
					// Left/right dancing, think Skid & Pump
					if (dance_idle)
						playAnim((animation.curAnim.name == 'danceRight') ? 'danceLeft' : 'danceRight', forced);
					// Play normal idle animations for all other characters
					else
						playAnim('idle', forced);
			}
		}
	}
	override public function setOffsets(?AnimName:String = "",?offsetX:Float = 0,?offsetY:Float = 0){
		if (tintedAnims.contains(animation.curAnim.name)){this.color = 0x330066;}else{this.color = 0xffffff;}
		super.setOffsets(AnimName,offsetX,offsetY);
	}
	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if(AnimName == lastAnim && loopAnimFrames[AnimName] != null){Frame = loopAnimFrames[AnimName];}
		super.playAnim(AnimName, Force, Reversed, Frame);


		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}
	public function addAnimation(anim:String,prefix:String,?indices:Array<Int>,?postFix:String = "",?fps:Int = 24,?loop:Bool = false){
		if (indices != null && indices.length > 0) { // Add using indices if specified
			animation.addByIndices(anim, prefix,indices,postFix, fps, loop);
		}else{
			animation.addByPrefix(anim, prefix, fps, loop);
		}
	}

	public function simplifyCharacter():String
	{
		var base = curCharacter;

		if (base.startsWith('gf'))
			base = 'gf';
		return base;
	}
	public function cloneAnimation(name:String,anim:FlxAnimation){
		try{

		if(anim != null){
			animation.add(name,anim.frames,anim.frameRate,anim.flipX);
			if (animOffsets.exists(anim.name)){
				addOffset(name,animOffsets[anim.name][0],animOffsets[anim.name][1],true);
			}
		}
		}catch(e)MainMenuState.handleError('Caught character "cloneAnimation" crash: ${e.message}');
	}
}
