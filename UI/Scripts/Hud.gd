extends Control

@onready var lifebar = $Lifebar

func on_treasure_collected(amount):
	$Treasure/CanvasLayer/RichTextLabel.text = str(int($Treasure/CanvasLayer/RichTextLabel.text)+int(amount))
	if int($Treasure/CanvasLayer/RichTextLabel.text) > 0:
		$Treasure/CanvasLayer.visible = true
	
func set_treasure(treasure: int):
	$Treasure/CanvasLayer/RichTextLabel.text = str(int(treasure))
	if treasure > 0:
		$Treasure/CanvasLayer.visible = true
	
