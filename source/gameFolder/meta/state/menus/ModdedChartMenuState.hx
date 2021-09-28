package gameFolder.meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIText;
import flixel.math.FlxRandom;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.Song.SwagSong;
import gameFolder.meta.data.dependency.Discord;
import gameFolder.meta.data.font.Alphabet;
import gameFolder.meta.state.menus.MainMenuState;

import sys.io.File;
import sys.FileSystem;

using StringTools;

class ModdedChartMenuState extends SearchMenuState
{
  var sideButton:FlxUIButton;

  var songFiles:Array<String> = [];
  var songDirs:Array<String> = [];
  var dataDir:String = "mods/charts/";
  var optionsButton:FlxUIButton;
  var invertedChart:Bool = false;

  var modes:Map<Int,Array<String>> = [];
  var diffText:FlxText;
  var selMode:Int = 0;
  var blockedFiles:Array<String> = ['picospeaker.json','meta.json','config.json'];

  var songNames:Array<String> = [];

  override function create()
  {



    super.create();
    optionsButton = new FlxUIButton(1100, 40, "Char Sel", goOptions);
    optionsButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    optionsButton.resize(150, 30);
    add(optionsButton);
    diffText = new FlxText(FlxG.width * 0.7, 5, 0, "", 24);
    diffText.font = ForeverTools.font;
    add(diffText);
    changeDiff();
  }
  function sortDirListing(listing:Array<String>){
    
    return listing;
  }
  override function reloadList(?reload=false,?search = ""){
    curSelected = 0;
    if(reload){grpSongs.destroy();}
    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);
    songs = ["No Songs!"];
    songNames = ["Nothing"];
    modes = [0 => ["None"]];
    var i:Int = 0;

    var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
    if (FileSystem.exists(dataDir))
    {
      var dirs = orderList(FileSystem.readDirectory(dataDir));
      for (directory in dirs)
      {
        if (search == "" || query.match(directory.toLowerCase())) // Handles searching
        {
        if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
            modes[i] = [];
            for (file in FileSystem.readDirectory(dataDir + directory))
            {
                if (!blockedFiles.contains(file.toLowerCase()) && StringTools.endsWith(file, '.json')){
                  modes[i].push(file);
                }
            }
            if (modes[i][0] == null){ // No charts to load!
              modes[i][0] = "No charts for this song!";
            }
            songs[i] = dataDir + directory;
            songNames[i] =directory;
                
            var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, directory, true, false);
            controlLabel.isMenuItem = true;
            controlLabel.targetY = i;
            if (i != 0)
              controlLabel.alpha = 0.6;
            grpSongs.add(controlLabel);
            i++;
          }
        }
      }
    }else{
      MainMenuState.handleError('"/mods/charts" does not exist!');
    }
  }

  override function ret(){
    FlxG.mouse.visible = false;
    FlxG.switchState(new MainMenuState());
  }
  override function extraKeys(){
    if (FlxG.keys.justPressed.R){
      changeSelection(Math.floor(songs.length * Math.random()));
    }
  }
  override function select(sel:Int = 0){
      if (songs[curSelected] == "No Songs!" || modes[curSelected][selMode] == "No charts for this song!"){ // Actually check if the song has no charts when loading, if so then error
        FlxG.sound.play(Paths.sound("cancelMenu"));
        return;
      }
      try{

      var songJSON = modes[curSelected][selMode]; // Just for easy access
      var songName = songNames[curSelected]; // Easy access to var
      var selSong = songs[curSelected]; // Easy access to var
      CustomPlayState.chartFile = '${selSong}/${songJSON}';
      // PlayState.SONG = Song.parseJSONshit(File.getContent('${selSong}/${songJSON}'));
      PlayState.isStoryMode = false;
      // Set difficulty
      // PlayState.songDiff = songJSON;
      // PlayState.storyDifficulty = switch(songJSON){case '${songName}-easy.json': 0; case '${songName}-hard.json': 2; default: 1;};
      // if (StringTools.endsWith(songs[curSelected], '-hard.json'))
      // {
      //   songName = songName.substr(0,songName.indexOf('-hard.json'));
      //   PlayState.storyDifficulty = 2;
      // }
      // else if (StringTools.endsWith(songs[curSelected], '-easy.json'))
      // {
      //   songName = songName.substr(0,songName.indexOf('-easy.json'));
      //   PlayState.storyDifficulty = 0;
      // }
      // PlayState.actualSongName = songJSON;
      CustomPlayState.voicesFile = '';
      if (FileSystem.exists('${selSong}/Voices.ogg')) CustomPlayState.voicesFile = '${selSong}/Voices.ogg';
      // if (FileSystem.exists('${selSong}/script.hscript')) {    Maybe hscripts in the future? owo
      //   trace("Song has script!");
      //     MultiPlayState.scriptLoc = '${selSong}/script.hscript';
      //     PlayState.hsBrTools = new HSBrTools('${selSong}');
      //   }else {PlayState.hsBrTools = null;MultiPlayState.scriptLoc = "";PlayState.songScript = "";}
      CustomPlayState.instFile = '${selSong}/Inst.ogg';
      Main.switchState(this, new CustomPlayState());
      }catch(e){
        MainMenuState.handleError('Error while loading chart ${e.message}');
      }
  }


  override function handleInput(){
      if (controls.BACK)
      {
        ret();
      }
      if(songs.length == 0) return;
      
      if(controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
      if(controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}
      if(controls.LEFT_P){changeDiff(-1);}
      if(controls.RIGHT_P){changeDiff(1);}
      extraKeys();
      if (controls.ACCEPT && songs.length > 0)
      {
          select();
      }
  }
  function changeDiff(change:Int = 0,?forcedInt:Int= -100){ // -100 just because it's unlikely to be used
    if (songs.length == 0 || songs[curSelected] == null || songs[curSelected] == "") {
      diffText.text = 'No song selected';
      return;
    }
    if (forcedInt == -100) selMode += change; else selMode = forcedInt;
    if (selMode >= modes[curSelected].length) selMode = 0;
    if (selMode < 0) selMode = modes[curSelected].length - 1;
    diffText.text = modes[curSelected][selMode];
    diffText.x = (FlxG.width) - (diffText.text.length * 14) - 10;
  }
  override function changeSelection(change:Int = 0)
  {
    super.changeSelection(change);
    if (modes[curSelected].indexOf('${songNames[curSelected]}.json') != -1) changeDiff(0,modes[curSelected].indexOf('${songNames[curSelected]}.json')); else changeDiff(0,0);

  }

  function goOptions(){
      FlxG.mouse.visible = false;
      FlxG.switchState(new CharaSelectionMenu(1));
  }
}
