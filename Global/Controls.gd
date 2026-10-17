extends Node

const FREE_CROSSHAIRS = 0
const FIXED_CROSSHAIRS = 1

const PRESET_MOUSE = 0
const PRESET_KEYBOARD_ARROWS = 1
const PRESET_KEYBOARD_WASD = 2
const PRESET_GAMEPAD = 3

var control_scheme = FREE_CROSSHAIRS

var can_use_mouse = false
# This is necessary because if the player sets the mouse
#  invisible manually, the game's just going to show the mouse
#  again when the player opens one of the menus.
var player_set_mouse_invisible = false
var _prev_mouse_pos := Vector2()
	
func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
func _ready():
	_prev_mouse_pos = get_viewport().get_mouse_position()
	
func set_control_mouse_button(action : StringName, button : MouseButton, erase : bool = true):
	if erase:
		InputMap.action_erase_events(action)
	var event : InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)

func set_control_joystick(action : StringName, axis : JoyAxis, value : float, erase : bool = true):
	if erase:
		InputMap.action_erase_events(action)
	var event : InputEventJoypadMotion = InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	InputMap.action_add_event(action, event)
	
func set_control_key(action : StringName, keycode : Key, erase : bool = true, location = KEY_LOCATION_UNSPECIFIED):
	if erase:
		InputMap.action_erase_events(action)
	var event : InputEventKey = InputEventKey.new()
	event.keycode = keycode
	event.key_label = keycode
	event.physical_keycode = keycode
	event.location = location
	InputMap.action_add_event(action, event)
	
func set_control_button(action : StringName, button : JoyButton, erase : bool = true):
	if erase:
		InputMap.action_erase_events(action)
	var event : InputEventJoypadButton = InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)
	
	
func set_controls_preset(preset : int):
	match preset:
		PRESET_MOUSE:
			set_controls_mouse()
		PRESET_KEYBOARD_ARROWS:
			set_controls_keyboard_arrows()
		PRESET_KEYBOARD_WASD:
			set_controls_keyboard_wasd()
		PRESET_GAMEPAD:
			set_controls_gamepad()

func set_controls_keyboard_wasd():
	set_control_key("Left", KEY_A)
	set_control_key("ui_left", KEY_A)
	set_control_key("ui_left", KEY_LEFT)
	
	set_control_key("Right", KEY_D)
	set_control_key("ui_right", KEY_D)
	set_control_key("ui_right", KEY_RIGHT)
	
	set_control_key("Up", KEY_W)
	set_control_key("ui_up", KEY_W)
	set_control_key("ui_up", KEY_UP)
	
	set_control_key("Down", KEY_S)
	set_control_key("ui_down", KEY_S)
	set_control_key("ui_down", KEY_DOWN)
	
	set_control_key("Click", KEY_J)
	set_control_key("Attack", KEY_K)
	
	set_control_key("Inventory", KEY_I)
	set_control_key("Pause", KEY_ENTER)
	
	set_control_key("UI Accept", KEY_J)
	set_control_key("UI Accept", KEY_ENTER, false)
	
	set_control_key("ui_accept", KEY_J)
	set_control_key("ui_accept", KEY_ENTER, false)
	
	set_control_key("UI Cancel", KEY_K)
	set_control_key("UI Cancel", KEY_ESCAPE, false)
	
	set_control_key("ui_cancel", KEY_K)
	set_control_key("ui_cancel", KEY_ESCAPE, false)
	
	set_control_key("Switch Equipped Left", KEY_SHIFT, true, KEY_LOCATION_LEFT)
	set_control_key("Switch Equipped Right", KEY_SHIFT, true, KEY_LOCATION_RIGHT)
	control_scheme = FIXED_CROSSHAIRS
	ControllerIcons.refresh()

func set_controls_keyboard_arrows():
	set_control_key("Left", KEY_LEFT)
	set_control_key("ui_left", KEY_LEFT)
	
	set_control_key("Right", KEY_RIGHT)
	set_control_key("ui_right", KEY_RIGHT)
	
	set_control_key("Up", KEY_UP)
	set_control_key("ui_up", KEY_UP)
	
	set_control_key("Down", KEY_DOWN)
	set_control_key("ui_down", KEY_DOWN)
	
	set_control_key("Click", KEY_Z)
	set_control_key("Attack", KEY_X)
	
	set_control_key("Inventory", KEY_I)
	set_control_key("Pause", KEY_ENTER)
	
	set_control_key("UI Accept", KEY_Z)
	set_control_key("UI Accept", KEY_ENTER, false)
	set_control_key("ui_accept", KEY_Z)
	set_control_key("ui_accept", KEY_ENTER, false)
	
	set_control_key("UI Cancel", KEY_X)
	set_control_key("UI Cancel", KEY_ESCAPE, false)
	set_control_key("ui_cancel", KEY_X)
	set_control_key("ui_cancel", KEY_ESCAPE, false)
	
	set_control_key("Switch Equipped Left", KEY_SHIFT, true, KEY_LOCATION_LEFT)
	set_control_key("Switch Equipped Right", KEY_SHIFT, true, KEY_LOCATION_RIGHT)
	control_scheme = FIXED_CROSSHAIRS
	ControllerIcons.refresh()

func set_controls_gamepad():
	set_control_button("Left", JOY_BUTTON_DPAD_LEFT)
	set_control_button("ui_left", JOY_BUTTON_DPAD_LEFT)
	set_control_joystick("Left", JOY_AXIS_LEFT_X, -0.75, false)
	
	set_control_button("Right", JOY_BUTTON_DPAD_RIGHT)
	set_control_button("ui_right", JOY_BUTTON_DPAD_RIGHT)
	set_control_joystick("Right", JOY_AXIS_LEFT_X, 0.75, false)

	set_control_button("Up", JOY_BUTTON_DPAD_UP)
	set_control_button("ui_up", JOY_BUTTON_DPAD_UP)
	set_control_joystick("Up", JOY_AXIS_LEFT_Y, -0.75, false)

	set_control_button("Down", JOY_BUTTON_DPAD_DOWN)
	set_control_button("ui_down", JOY_BUTTON_DPAD_DOWN)
	set_control_joystick("Down", JOY_AXIS_LEFT_Y, 0.75, false)
	
	set_control_button("Click", JOY_BUTTON_A)
	set_control_button("Attack", JOY_BUTTON_B)
	set_control_button("Inventory", JOY_BUTTON_Y)
	set_control_button("Pause", JOY_BUTTON_START)
	
	set_control_button("UI Accept", JOY_BUTTON_A)
	set_control_button("ui_accept", JOY_BUTTON_A)
	set_control_button("UI Cancel", JOY_BUTTON_B)
	set_control_button("ui_cancel", JOY_BUTTON_B)
	
	set_control_button("Switch Equipped Left", JOY_BUTTON_LEFT_SHOULDER)
	set_control_button("Switch Equipped Right", JOY_BUTTON_RIGHT_SHOULDER)
	control_scheme = FIXED_CROSSHAIRS
	ControllerIcons.refresh()

func set_controls_mouse():
	set_control_key("Left", KEY_A)
	set_control_key("ui_left", KEY_A)
	set_control_key("ui_left", KEY_LEFT, false)
	
	set_control_key("Right", KEY_D)
	set_control_key("ui_right", KEY_D)
	set_control_key("ui_right", KEY_RIGHT, false)
	
	set_control_key("Up", KEY_W)
	set_control_key("ui_up", KEY_W)
	set_control_key("ui_up", KEY_UP, false)
	
	set_control_key("Down", KEY_S)
	set_control_key("ui_down", KEY_S)
	set_control_key("ui_down", KEY_DOWN, false)
	
	set_control_mouse_button("Click", MOUSE_BUTTON_LEFT)
	set_control_mouse_button("Attack", MOUSE_BUTTON_RIGHT)
	
	set_control_key("Inventory", KEY_I)
	set_control_key("Pause", KEY_ENTER)
	
	set_control_key("UI Accept", KEY_ENTER)
	set_control_key("ui_accept", KEY_ENTER)
	set_control_mouse_button("UI Accept", MOUSE_BUTTON_LEFT, false)
	set_control_mouse_button("ui_accept", MOUSE_BUTTON_LEFT, false)
	
	set_control_key("UI Cancel", KEY_ESCAPE)
	set_control_key("ui_cancel", KEY_ESCAPE)
	
	set_control_mouse_button("Switch Equipped Left", MOUSE_BUTTON_WHEEL_DOWN)
	set_control_mouse_button("Switch Equipped Right", MOUSE_BUTTON_WHEEL_UP)
	
	control_scheme = FREE_CROSSHAIRS
	ControllerIcons.refresh()

func _input(event : InputEvent):
	if event is InputEventMouse:
		can_use_mouse = true
