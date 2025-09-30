extends Control

@onready var lifebar = $Lifebar
var equipped = ""

func on_item_collected(item, amount, _should_play_sound):
	match item:
		Collectible.TREASURE:
			$Treasure/CanvasLayer/RichTextLabel.text = str(int($Treasure/CanvasLayer/RichTextLabel.text)+int(amount))
			if int($Treasure/CanvasLayer/RichTextLabel.text) > 0:
				$Treasure/CanvasLayer.visible = true
		Collectible.GOLDEN_DAGGER:
			if amount > 0:
				$Equipped/CanvasLayer.visible = true
				$Equipped/CanvasLayer/RichTextLabel.text = ""
			else:
				$Equipped/CanvasLayer.visible = false
			return
	if (item == equipped) and (not equipped.is_empty()):
		$Equipped/CanvasLayer/RichTextLabel.text = str(int($Equipped/CanvasLayer/RichTextLabel.text) + int(amount))

func on_item_equipped(item, count):
	equipped = item
	if equipped.is_empty():
		$Equipped/CanvasLayer.visible = false
		return
	$Equipped/CanvasLayer.visible = true
	$Equipped/CanvasLayer/RichTextLabel/AnimatedSprite2D.sprite_frames = Collectible.spriteframes[equipped]
	if equipped == Collectible.GOLDEN_DAGGER:
		$Equipped/CanvasLayer/RichTextLabel.text = ""
	else:
		$Equipped/CanvasLayer/RichTextLabel.text = str(int(count))
	
func set_treasure(treasure: int):
	$Treasure/CanvasLayer/RichTextLabel.text = str(int(treasure))
	if treasure > 0:
		$Treasure/CanvasLayer.visible = true
	
