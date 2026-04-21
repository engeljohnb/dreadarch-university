extends Node

class_name Blinker
# There's some baggage here to accomodate the dumb
# 	way I was doing things before (using the flip signal and letting the connector 
#	handle it) and the smart way I'm doing it now (letting the node
# 	to be blinked pass itself to the blink function

# So please excuse the mess
signal flip()
var total_duration = 0.0
var blink_duration = 0.05
var blink_timer = 0.0
var total_timer = 0.0
var blinking = false
var state = false
var _node : Node = self

func blink(duration, node : Node = self):
	if node != self:
	# if this is node being used by the NEW interface:
		original_color = node.modulate
		_node = node
	total_duration = duration
	blinking = true
	if total_duration == blink_duration:
		state = (not state)
		flip.emit(state)
	
var original_color : Color
func toggle_modulate(blink_color : Color):
	if _node == self:
		return
	match state:
		true:
			_node.modulate = blink_color
		false:
			_node.modulate = original_color
			
func _process(delta):
	if blinking:
		blink_timer += delta
		total_timer += delta
		if blink_timer >= blink_duration:
			blink_timer = 0.0
			state = (not state)
			flip.emit(state)
			toggle_modulate(Color(1.6,1.6,1.6))
		if total_timer >= total_duration:
			total_timer = 0.0
			blinking = false
			state = false
			flip.emit(false)
			toggle_modulate(Color(1.6,1.6,1.6))
