package gameFolder.meta.state;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;
import gameFolder.meta.state.menus.MainMenuState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.Song;


class CustomPlayState extends PlayState
{

	public static var voicesFile = "";
  public static var instFile = "";
  public static var chartFile = "";
  public static var scriptLoc= "";
  function loadSongs(){
    {try{

    if (voicesFile != ""){loadedVoices = new FlxSound().loadEmbedded(Sound.fromFile(voicesFile),false,true);}else loadedVoices = new FlxSound();
    loadedInst = new FlxSound().loadEmbedded(Sound.fromFile(instFile),false,true);
  }catch(e){MainMenuState.handleError('Caught "loadSongs" crash: ${e.message}');}}
  }
  function loadJSON(){
    PlayState.SONG = Song.parseJSONshit(File.getContent(chartFile));
    PlayState.SONG.stage = "stage";
    // PlayState.SONG.player1 = "bf"; // Prevent crash
    // PlayState.SONG.player2 = "dad"; // Prevent crash
  }
  override function create()
    {try{
      PlayState.returnUI = 1;
      moddedSong = true;
    // if (scriptLoc != "") PlayState.songScript = File.getContent(scriptLoc); else PlayState.songScript = "";
  	loadJSON();
    loadSongs();

    super.create();


  }catch(e){MainMenuState.handleError('Caught "create" crash: ${e.message}');}}
  // override function openSubState(SubState:FlxSubState)
  // {
  //   if (Type.getClass(SubState) == PauseSubState)
  //   {
  //     super.openSubState(new PauseSubState(PlayState.boyfriend.x,PlayState.boyfriend.y));
  //     return;
  //   }

  //   super.openSubState(SubState);
  // }
}
