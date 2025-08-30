extends Node

signal flip()
var total_duration = 0.0
var blink_duration = 0.05
var blink_timer = 0.0
var total_timer = 0.0
var blinking = false
var state = false

func blink(duration):
	total_duration = duration
	blinking = true
	
func _process(delta):
	if blinking:
		blink_timer += delta
		total_timer += delta
		if blink_timer >= blink_duration:
			blink_timer = 0.0
			state = (not state)
			flip.emit(state)
		if total_timer >= total_duration:
			blinking = false
			state = false
			flip.emit(false)
