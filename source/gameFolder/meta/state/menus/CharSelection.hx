package gameFolder.meta.state.menus;
// About 90% of code used from OfflineMenuState
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import gameFolder.gameObjects.userInterface.HealthIcon;

import sys.io.File;
import sys.FileSystem;

using StringTools;

class CharSelection extends SearchMenuState
{
  var defText:String = "Use shift to scroll faster";
  var uiIcon:HealthIcon;
  var playerEdit:Int = 0;
  override public function new(?playerEdit:Int = 0){
    this.playerEdit = playerEdit;
    super();
  }
  override function create()
  {try{
    searchList = TitleState.choosableCharacters;
    // if (playerEdit == 0){
    //   if(!searchList.contains("automatic")) searchList.insert(0,"automatic");
    // } else if (searchList.contains("automatic")) searchList.remove("automatic");
    super.create();
    var title = "";
    switch (playerEdit){
      case 0: title="Change BF";
      case 1: title="Change Opponent";
      case 2: title="Change GF";
      default: title= "You found a secret, You should exit this menu to prevent further 'secrets'";
    }
    if (title != "") addTitleText(title);
    // defText =  "Use shift to scroll faster, Animation Debug keys: 1=bf,2=dad,3=gf";
    uiIcon = new HealthIcon("bf",playerEdit == 0);
    uiIcon.x = FlxG.width * 0.8;
    uiIcon.y = FlxG.height * 0.2;
    add(uiIcon);
    FlxTween.angle(uiIcon, -40, 40, 1.12, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});
    FlxTween.tween(uiIcon, {"scale.x": 1.25,"scale.y": 1.25}, 1.50, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});  
    changeSelection();
  }catch(e) MainMenuState.handleError('Error with charsel "create" ${e.message}');}
  override function extraKeys(){
    // if (songs[curSelected] != "automatic"){
    //     if (FlxG.keys.justPressed.ONE){FlxG.switchState(new AnimationDebug(songs[curSelected],true,0,true));}
    //     if (FlxG.keys.justPressed.TWO){FlxG.switchState(new AnimationDebug(songs[curSelected],false,1,true));}
    //     if (FlxG.keys.justPressed.THREE){FlxG.switchState(new AnimationDebug(songs[curSelected],false,2,true));}
    //   }
  }
  override function ret(){
    FlxG.switchState(new CharaSelectionMenu(-1));
  }
  override function changeSelection(change:Int = 0){
    super.changeSelection(change);

    if (songs[curSelected] != "" && TitleState.characterDescriptions[songs[curSelected]] != null && TitleState.characterDescriptions[songs[curSelected]] != "" ){
      updateInfoText('${defText}; ' + TitleState.characterDescriptions[songs[curSelected]]);
    }else{
      updateInfoText('${defText}; No description for this character.');
    }
    uiIcon.updateIcon(songs[curSelected],false);
  }
  override function select(sel:Int = 0){
    Init.setChar(playerEdit,songs[curSelected]);
    // Init.trueSettings.set('char${playerEdit}',songs[curSelected]);
  }
}