extends Node

var showing_mouse = false

func _process(_delta):
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
