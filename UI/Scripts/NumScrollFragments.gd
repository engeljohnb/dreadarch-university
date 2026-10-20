extends Control
@onready var label = $RichTextLabel
@onready var sprite = $Texture


func set_num_scroll_fragments(num : int):
	$RichTextLabel.text = str(num)
	
func shrink_for_mini_gui(_size):
	$RichTextLabel.size = Vector2(_size, _size)
	
func set_brightness(brightness : float):
	$RichTextLabel.modulate *= brightness
	$Texture.modulate *= brightness
	$RichTextLabel.modulate.a = 1.0
	$Texture.modulate.a = 1.0
	
#func set_position_for_mini_gui(pos : Vector2):
#	position = Vector2(0, y_pos)
	#shrink_for_mini_gui(0.45)
