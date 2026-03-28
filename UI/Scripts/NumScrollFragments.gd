extends Node2D

func set_num_scroll_fragments(num : int):
	$CanvasLayer/RichTextLabel.text = str(num)
func shrink_for_mini_gui(size):
	$CanvasLayer/RichTextLabel.scale = Vector2(size, size)
	#$CanvasLayer/RichTextLabel/AnimatedSprite2D.scale = Vector2(size*2, size*2)
	
func set_position_for_mini_gui(y_pos):
	$CanvasLayer/RichTextLabel.position = Vector2(0, y_pos)
	#label.position.x += 50
	$CanvasLayer/RichTextLabel.position.x = -1120
	shrink_for_mini_gui(0.9)
	#$CanvasLayer/RichTextLabel.position.y += 
	#$CanvasLayer/RichTextLabel.position.x = 60
