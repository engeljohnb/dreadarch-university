extends RichTextLabel

const SIZE = Vector2(150, 40)

func _ready():
	text = text
	custom_minimum_size = SIZE
	position = -SIZE/2.0
	position.y -= (SIZE.y/2.0)+50
