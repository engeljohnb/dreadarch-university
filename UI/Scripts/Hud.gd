extends Control

@onready var lifebar = $Lifebar
var equipped = ItemCollection.GOLDEN_DAGGER

func on_item_collected(item, amount, _should_play_sound):
	match item:
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
	if (item == equipped):
		$Equipped/CanvasLayer/RichTextLabel.text = str(int($Equipped/CanvasLayer/RichTextLabel.text) + int(amount))

func on_item_equipped(item, count):
	equipped = item
	var equipment_sprite : Sprite2D = $Equipped/CanvasLayer/RichTextLabel/Sprite2D
	var equipment_text : RichTextLabel = $Equipped/CanvasLayer/RichTextLabel
	if not ItemCollection.is_item_id_valid(item):
		Error.error("Attempting to equip invalid item")
		$Equipped/CanvasLayer.visible = false
		return
	equipment_text.visible = true
	equipment_sprite.texture = ItemCollection.textures[equipped]
	if equipped == ItemCollection.GOLDEN_DAGGER:
		if count == 0:
			equipment_sprite.visible = false
		else:
			equipment_sprite.visible = true
		equipment_text.text = ""
	else:
		equipment_sprite.visible = true
		equipment_text.text = str(int(count))
	
	
func _hide():
	visible = false
	$Equipped/CanvasLayer.visible = false
	
func _show():
	visible = true
	$Equipped/CanvasLayer.visible = true
