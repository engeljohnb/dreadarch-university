extends Node2D
@onready var label = $CanvasLayer/RichTextLabel
@onready var sprite = $CanvasLayer/RichTextLabel/AnimatedSprite2Ds

func set_num_scroll_fragments(num : int):
	$CanvasLayer/RichTextLabel.text = str(num)
func shrink_for_mini_gui(size):
	$CanvasLayer/RichTextLabel.scale = Vector2(size, size)
	
func set_brightness(brightness : float):
	$CanvasLayer/RichTextLabel.modulate *= brightness
	$CanvasLayer/RichTextLabel/AnimatedSprite2D.modulate *= brightness
	$CanvasLayer/RichTextLabel.modulate.a = 1.0
	$CanvasLayer/RichTextLabel/AnimatedSprite2D.modulate.a = 1.0
	
func set_position_for_mini_gui(y_pos):
	$CanvasLayer/RichTextLabel.position = Vector2(0, y_pos)
	$CanvasLayer/RichTextLabel.position.x = -1120
	shrink_for_mini_gui(0.9)
