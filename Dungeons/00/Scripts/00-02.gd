extends Node2D
var start_color = Color(0.85, 0.85, 0.85)
var finish_color = Color(1.2, 1.2, 1.1)
var light_progress = 0.0

func _process(_delta):
	modulate = lerp(start_color, finish_color, Noise.new.call())
	light_progress += _delta
