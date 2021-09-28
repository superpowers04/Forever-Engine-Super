package gameFolder.meta.data.dependency;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
	Global FNF sprite utilities, all in one parent class!
	You'll be able to easily edit functions and such that are used by sprites
**/
class FNFSprite extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>> = [];
	public var objPos:Array<Float> = [0,0];
	var lastAnim:String = "";

	public function moveOffsets(x:Float=0,y:Float = 0){
		objPos[0] += x;
		objPos[1] += y;
	}


	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
	}
	public function setOffsets(?AnimName:String = "",?offsetX:Float = 0,?offsetY:Float = 0){
		
		var daOffset = animOffsets.get(AnimName); // Get offsets
		var offsets:Array<Float> = [offsetX,offsetY];
		if (animOffsets.exists(AnimName)) // Set offsets if animation has any
		{
			offsets[0]+=daOffset[0];
			offsets[1]+=daOffset[1];
		}
		offsets[0]+=objPos[0]; // Add offset for objpos
		offsets[1]+=objPos[1]; 
		offset.set(offsets[0], offsets[1]); // Set offsets
	}
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (AnimName != lastAnim){
		
			setOffsets(AnimName);
		} // Skip if already playing, no need to recalculate offsets and such
		lastAnim = AnimName;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0,?custom:Bool = false,?replace:Bool = false)
	{
		
		if (animOffsets[name] == null || replace){ // If animation is null, just add the offsets out right
			animOffsets[name] = [x, y];
		}else{ // If animation is not null, add the offsets to the existing ones
			animOffsets[name] = [animOffsets[name][0] + x, animOffsets[name][1] + y];
		}
	}

	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):FNFSprite
	{
		var graph:FlxGraphic = FlxG.bitmap.add(Graphic, Unique, Key);
		if (graph == null)
			return this;

		if (Width == 0)
		{
			Width = Animated ? graph.height : graph.width;
			Width = (Width > graph.width) ? graph.width : Width;
		}

		if (Height == 0)
		{
			Height = Animated ? Width : graph.height;
			Height = (Height > graph.height) ? graph.height : Height;
		}

		if (Animated)
			frames = FlxTileFrames.fromGraphic(graph, FlxPoint.get(Width, Height));
		else
			frames = graph.imageFrame;

		return this;
	}

	override public function destroy()
	{
		// dump cache stuffs
		if (graphic != null)
			graphic.dump();

		super.destroy();
	}
}
