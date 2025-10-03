extends Area2D

signal splashed(me)
@onready var sprite = $AnimatedSprite2D
var style = "01"
var segment_type = "Middle"

func on_animation_finished():
	$AnimatedSprite2D.play(get_animation_name())
	$AnimatedSprite2D.animation_finished.disconnect(on_animation_finished)

func splash():
	$AnimatedSprite2D.play(style + " " + "Splash")
	$AnimatedSprite2D.animation_finished.connect(on_animation_finished)
	splashed.emit(self)
	
func on_body_entered(body):
	if body.is_in_group("Weapons"):
		splash()
		splashed.emit(self)
	
func get_animation_name():
	return style + " " + segment_type

func _ready():
	body_entered.connect(on_body_entered)
	$AnimatedSprite2D.play(get_animation_name())
