extends Control

@onready var lifebar = $Lifebar
@onready var treasure = $Treasure
var equipped = ""

func on_item_collected(item, amount, _should_play_sound):
	match item:
		ItemCollection.TREASURE:
			$Treasure/CanvasLayer/RichTextLabel.text = str(int($Treasure/CanvasLayer/RichTextLabel.text)+int(amount))
			if int($Treasure/CanvasLayer/RichTextLabel.text) > 0:
				$Treasure/CanvasLayer.visible = true
		ItemCollection.GOLDEN_DAGGER:
			if amount > 0:
				$Equipped/CanvasLayer.visible = true
				$Equipped/CanvasLayer/RichTextLabel.text = ""
			else:
				$Equipped/CanvasLayer.visible = false
			return
		item:
			if item is Dictionary:
				return
	if (item == equipped) and (not equipped.is_empty()):
		$Equipped/CanvasLayer/RichTextLabel.text = str(int($Equipped/CanvasLayer/RichTextLabel.text) + int(amount))

func on_item_equipped(item, count):
	equipped = item
	if equipped.is_empty():
		$Equipped/CanvasLayer.visible = false
		return
	$Equipped/CanvasLayer.visible = true
	$Equipped/CanvasLayer/RichTextLabel/AnimatedSprite2D.sprite_frames = ItemCollection.spriteframes[equipped]
	if equipped == ItemCollection.GOLDEN_DAGGER:
		$Equipped/CanvasLayer/RichTextLabel.text = ""
	else:
		$Equipped/CanvasLayer/RichTextLabel.text = str(int(count))
	
func set_treasure(_treasure: int):
	$Treasure.set_treasure(_treasure)
	
func _hide():
	visible = false
	treasure.canvas.visible = false
	$Equipped/CanvasLayer.visible = false
	
func _show():
	visible = true
	$Treasure/CanvasLayer.visible = true
	$Equipped/CanvasLayer.visible = true
