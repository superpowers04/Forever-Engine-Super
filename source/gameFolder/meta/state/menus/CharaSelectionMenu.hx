package gameFolder.meta.state.menus;

import flixel.FlxG;

import gameFolder.meta.state.TitleState;
import gameFolder.meta.state.menus.*;
import gameFolder.meta.data.dependency.Discord;
import flixel.addons.transition.FlxTransitionableState;


using StringTools;

class CharaSelectionMenu extends SickMenuState
{
	static var retMenu:Int = 0;

	override public function new(?_retMenu:Int = 0){
		if (_retMenu != -1) retMenu = _retMenu;
		super();

	}

	override function goBack(){
		switch(retMenu){ // TODO ADD MORE SUPPORTED STATES
			case 1: FlxG.switchState(new ModdedChartMenuState());
			default:
				FlxG.switchState(new MainMenuState());
		}
	}

	override function create()
	{
		options = ["Player","Opponent","Girlfriend","reload character list","Back"];
		setDesc();
		super.create();

		#if !html5
		Discord.changePresence('CHAR SCREEN', 'Selecting a character');
		#end

	}
	function setDesc(){
		descriptions = ['Current player:${Init.getChar(0)}','Current opponent:${Init.getChar(1)}','Current GF:${Init.getChar(2)}','Reload list of characters, current character count: ${TitleState.choosableCharacters.length}',"Leave this menu"];
// trueSettings.get("char" + playerEdit.toString())
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
		
		if (sel <= 2) FlxG.switchState(new CharSelection(sel))
		else
			switch (daChoice) {
				case "reload character list":
					TitleState.checkCharacters();
					setDesc();
					selected = false;
					changeSelection(0);

				case "Back":
					goBack();
			}
			
	}
}
