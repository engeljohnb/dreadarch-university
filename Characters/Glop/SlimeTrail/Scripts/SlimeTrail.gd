extends Area2D

var fade_in_duration = 0.5
var fade_in_timer = 0.0
var fading_in = true
# This is here so the slime trail doesn't hurt other glops
var glop_weapon = true
				
func _ready():
	modulate.a = 0
	
func _process(_delta):
	if fading_in:
		fade_in_timer += _delta
		modulate.a = lerp(0.0, 0.5, fade_in_timer/fade_in_duration)
		if fade_in_timer >= fade_in_duration:
			modulate.a = 0.5
			fading_in = false

	
