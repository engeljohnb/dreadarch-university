extends Node2D

var fill_texture = load("res://Assets/Items/ScrollFragment/Scroll.png")
var blank_texture = load("res://Assets/UI/EmptyScroll.png")
var blink_duration = 0.25

func on_flip(state):
	if state:
		modulate = Color(2,2,2)
	else:
		modulate = Color(1,1,1)

func fill():
	$TranslatedSound.play()
	$Sprite2D.texture = fill_texture
	$Blinker.blink(1.0)
	
func reset():
	$Sprite2D.texture = blank_texture
	
func _ready():
	$Blinker.blink_duration = blink_duration
	$Blinker.flip.connect(on_flip)
