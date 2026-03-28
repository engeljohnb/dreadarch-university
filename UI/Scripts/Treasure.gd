extends Node2D
@onready var canvas = $CanvasLayer
@onready var label = $CanvasLayer/RichTextLabel
@onready var sprite = $CanvasLayer/RichTextLabel/AnimatedSprite2D


var for_save_slot = false
var save_slot_position = Vector2()
func shrink_label(size : float):
	label.scale = Vector2(size, size)
	sprite.scale = Vector2(size*2, size*2)
func _ready():
	if for_save_slot:
		canvas.layer = 2
		label.position = save_slot_position
		#label.position.x += 50
		label.position.x = 575
		label.position.y += 35
		sprite.position.x = 60
		shrink_label(0.9)
		visible = true
		z_index = 1000
	else:
		sprite.play("default")
func set_treasure(treasure : int):
	var treasure_string = str(treasure)
	$CanvasLayer/RichTextLabel.text = treasure_string
