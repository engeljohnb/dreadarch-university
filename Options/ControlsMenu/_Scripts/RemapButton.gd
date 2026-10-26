extends Button
class_name RemapButton
signal found_input
@export var action : String

func _init():
	toggle_mode = true
	
func _ready():
	set_process_unhandled_input(false)
	update_button_text()
	
func _toggled(_pressed):
	set_process_unhandled_input(_pressed)
	if _pressed:
		text = "[...]"
		release_focus()
	else:
		update_button_text()
		grab_focus()
		
func _gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed:
			if text == "[...]":
				Controls.set_control_mouse_button(action, event.button_index)
				button_pressed = false
				accept_event()
		
func _unhandled_input(event: InputEvent) -> void:      
	if event is InputEventJoypadMotion:
		Controls.set_control_joystick(action, event.axis, event.axis_value)
		found_input.emit()
	elif event.pressed:
		if event is InputEventMouseButton:
			Controls.set_control_mouse_button(action, event.button_index)
		elif event is InputEventKey:
			Controls.set_control_key(action, event.keycode)
		elif event is InputEventJoypadButton:
			Controls.set_control_button(action, event.button_index)
		button_pressed = false
		found_input.emit()
		
func remove_button_text_junk(string: String) -> String:
	string = string.replace(" - Physical", "")
	string = string.replace("Joypad ", "")
	var regex := RegEx.new()
	regex.compile("Button [0-9]{1,2}")
	var match := regex.search(string)
	if match:
		return string.substr(0, match.get_end())
	return string
	
func update_button_text():
	var _text : String = InputMap.action_get_events(action)[0].as_text()
	_text = remove_button_text_junk(_text)
	text = _text
