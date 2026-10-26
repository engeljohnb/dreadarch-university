extends Node

var showing_mouse = false
var gamepad_connect_confirmed = false
var gamepad_disconnect_confirmed = false
var num_gamepads = 0
var prev_num_gamepads = 0

func _ready():
	num_gamepads = Input.get_connected_joypads().size()
	prev_num_gamepads = num_gamepads
	
func _process(_delta):
	if num_gamepads != prev_num_gamepads:
		if Input.get_connected_joypads().size() > 0:
			Controls.set_controls_user_gamepad()
		else:
			Controls.set_controls_user_keyboard()
	if Controls.player_set_mouse_invisible:
		return
	if not Controls.can_use_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		return
	if get_tree().paused:
		if not showing_mouse:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			showing_mouse = true
	else:
		if showing_mouse:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			showing_mouse = false
	prev_num_gamepads = num_gamepads
	num_gamepads = Input.get_connected_joypads().size()
	
func _input(event : InputEvent):
		if (event is InputEventJoypadButton) or (event is InputEventJoypadMotion):
			if num_gamepads < 1:
				num_gamepads = 1
			set_process_input(false)
