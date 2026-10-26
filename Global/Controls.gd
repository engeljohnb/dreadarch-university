extends Node

const GAMEPAD_SCHEME_FILENAME = "user://GamepadControls.da"
const GAMEPAD_SCHEME_TYPES_FILENAME = "user://GamepadControlsTypes.da"
const KEYBOARD_SCHEME_FILENAME = "user://KeyboardControls.da"
const KEYBOARD_SCHEME_TYPES_FILENAME = "user://KeyboardControlsTypes.da"

const FREE_CROSSHAIRS = 0
const FIXED_CROSSHAIRS = 1

const PRESET_MOUSE = 0
const PRESET_KEYBOARD_ARROWS = 1
const PRESET_KEYBOARD_WASD = 2
const PRESET_GAMEPAD = 3

const LEFT_JOYSTICK_UP = -1
const LEFT_JOYSTICK_DOWN = -2
const LEFT_JOYSTICK_LEFT = -3
const LEFT_JOYSTICK_RIGHT = -4

const RIGHT_JOYSTICK_UP = -5
const RIGHT_JOYSTICK_DOWN = -6
const RIGHT_JOYSTICK_LEFT = -7
const RIGHT_JOYSTICK_RIGHT = -8


var crosshair_mode = FREE_CROSSHAIRS

var can_use_mouse = false
# This is necessary because if the player sets the mouse
#  invisible manually, the game's just going to show the mouse
#  again when the player opens one of the menus.
var player_set_mouse_invisible = false
var _prev_mouse_pos := Vector2()

var gamepad_scheme : Dictionary[StringName, Array]
var gamepad_scheme_types : Dictionary[StringName, Array]
var keyboard_scheme : Dictionary[StringName, Array] 
var keyboard_scheme_types : Dictionary[StringName, Array] 

enum InputTypes
{
	KEY,
	BUTTON,
	MOUSE_BUTTON,
	JOYSTICK
}

var game_actions : Array[StringName] = [
	"Click",
	"Attack",
	
	"Pause",
	"Inventory",
	
	"Switch Equipped Right",
	"Switch Equipped Left",
	
	"UI Accept",
	"UI Cancel",
	
	"ui_left",
	"ui_right",
	"ui_up",
	"ui_down",
	
	"ui_accept",
	"ui_cancel",
	
	"Up",
	"Down",
	"Left",
	"Right"
]

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
func _ready():
	auto_load_schemes()
	_prev_mouse_pos = get_viewport().get_mouse_position()
	

func get_joystick_direction_id(event : InputEventJoypadMotion) -> int:
	match event.axis:
		JOY_AXIS_LEFT_X:
			if event.axis_value < 0:
				return LEFT_JOYSTICK_LEFT
			elif event.axis_value > 0:
				return LEFT_JOYSTICK_RIGHT
		JOY_AXIS_LEFT_Y:
			if event.axis_value > 0:
				return LEFT_JOYSTICK_DOWN
			elif event.axis_value < 0:
				return LEFT_JOYSTICK_UP
		JOY_AXIS_RIGHT_X:
			if event.axis_value < 0:
				return RIGHT_JOYSTICK_LEFT
			elif event.axis_value > 0:
				return RIGHT_JOYSTICK_RIGHT
		JOY_AXIS_RIGHT_Y:
			if event.axis_value > 0:
				return RIGHT_JOYSTICK_DOWN
			elif event.axis_value < 0:
				return RIGHT_JOYSTICK_UP
	return 0

func update_keyboard_action(action : StringName, value : int, type : int):
	if keyboard_scheme.get(action) and keyboard_scheme_types.get(action):
		if (value in keyboard_scheme.get(action)) and (type in keyboard_scheme_types.get(action)):
			if keyboard_scheme[action].find(value) == keyboard_scheme_types[action].find(type):
				return
	keyboard_scheme.get_or_add(action, []).append(value)
	keyboard_scheme_types.get_or_add(action, []).append(type)
	
func update_gamepad_action(action : StringName, value : int, type : int):
	if gamepad_scheme.get(action) and gamepad_scheme_types.get(action):
		if (value in gamepad_scheme.get(action)) and (type in gamepad_scheme_types.get(action)):
			if gamepad_scheme[action].find(value) == gamepad_scheme_types[action].find(type):
				return
	gamepad_scheme.get_or_add(action, []).append(value)
	gamepad_scheme_types.get_or_add(action, []).append(type)

func write_scheme_to_file(filename : StringName, scheme : Dictionary[StringName, Array]):
	var file = FileAccess.open(filename, FileAccess.WRITE)
	var json_string = JSON.stringify(scheme)
	file.store_string(json_string)
	file.close()

func read_scheme_from_file(filename : StringName) -> Dictionary[StringName, Array]:
	if not FileAccess.file_exists(filename):
		return {}
	var file = FileAccess.open(filename, FileAccess.READ)
	var string = file.get_as_text()
	var _scheme = JSON.parse_string(string)
	var scheme : Dictionary[StringName, Array]
	for _key in _scheme:
		var key : StringName = StringName(_key)
		var values : Array = []
		var _values = _scheme[_key]
		for _value in _values:
			values.append(int(_value))
		scheme[key] = values
	return scheme
	
func clear_action(action : StringName, scheme : Dictionary[StringName, Array], types : Dictionary[StringName, Array]):
	if scheme.get(action):
		scheme[action].clear()
	if types.get(action):
		types[action].clear()
		
func is_directional(action : StringName) -> bool:
	return (action == "Left") or (action == "Right") or (action == "Up") or (action == "Down")
func auto_load_schemes():
	gamepad_scheme = read_scheme_from_file(GAMEPAD_SCHEME_FILENAME)
	gamepad_scheme_types = read_scheme_from_file(GAMEPAD_SCHEME_TYPES_FILENAME)
	keyboard_scheme = read_scheme_from_file(KEYBOARD_SCHEME_FILENAME)
	keyboard_scheme_types = read_scheme_from_file(KEYBOARD_SCHEME_TYPES_FILENAME)
	if Input.get_connected_joypads().size() > 0:
		set_controls_user_gamepad()
	else:
		set_controls_user_keyboard()
func autosave_schemes():	
	for action : StringName in InputMap.get_actions():
		if action not in game_actions:
			continue
		var events : Array[InputEvent] = InputMap.action_get_events(action)
		for event in events:
			if event is InputEventJoypadMotion:
				update_gamepad_action(action, get_joystick_direction_id(event), InputTypes.JOYSTICK)
			elif event is InputEventKey:
				clear_action(action, keyboard_scheme, keyboard_scheme_types)
				update_keyboard_action(action, event.keycode, InputTypes.KEY)
			elif event is InputEventJoypadButton:
				clear_action(action, gamepad_scheme, gamepad_scheme_types)
				update_gamepad_action(action, event.button_index, InputTypes.BUTTON)
			elif event is InputEventMouseButton:
				clear_action(action, keyboard_scheme, keyboard_scheme_types)
				update_keyboard_action(action, event.button_index, InputTypes.MOUSE_BUTTON)
	write_scheme_to_file(GAMEPAD_SCHEME_FILENAME, gamepad_scheme)
	write_scheme_to_file(GAMEPAD_SCHEME_TYPES_FILENAME, gamepad_scheme_types)
	write_scheme_to_file(KEYBOARD_SCHEME_FILENAME, keyboard_scheme)
	write_scheme_to_file(KEYBOARD_SCHEME_TYPES_FILENAME, keyboard_scheme_types)
	
func adjust_for_ui_events(action : StringName, event : InputEvent, erase : bool = true):
	if is_directional(action):
		var ui_action = "ui_" + action.to_lower()
		if erase:
			InputMap.action_erase_events(ui_action)
		InputMap.action_add_event(ui_action, event)
	if is_cancel_or_accept(action):
		var ui_action = action.to_lower().replace(" ", "_")
		if erase:
			InputMap.action_erase_events(ui_action)
		InputMap.action_add_event(ui_action, event)
		
func is_cancel_or_accept(action : StringName) -> bool:
	return (action == "UI Accept") or (action == "UI Cancel")
func set_control_mouse_button(action : StringName, button : MouseButton, erase : bool = true):
	if erase:
		InputMap.action_erase_events(action)
	var event : InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)
	adjust_for_ui_events(action, event, erase)

func set_control_joystick(action : StringName, axis : JoyAxis, value : float, erase : bool = true):
	if erase:
		InputMap.action_erase_events(action)
	var event : InputEventJoypadMotion = InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	InputMap.action_add_event(action, event)
	adjust_for_ui_events(action, event, erase)

func set_control_key(action : StringName, keycode : Key, erase : bool = true, location = KEY_LOCATION_UNSPECIFIED):
	if erase:
		InputMap.action_erase_events(action)
	var event : InputEventKey = InputEventKey.new()
	event.keycode = keycode
	event.key_label = keycode
	event.physical_keycode = keycode
	event.location = location
	InputMap.action_add_event(action, event)
	if is_cancel_or_accept(action):
		adjust_for_ui_events(action, event, false)
	else:
		adjust_for_ui_events(action, event, erase)
	
func set_control_button(action : StringName, button : JoyButton, erase : bool = true):
	if erase:
		InputMap.action_erase_events(action)
	var event : InputEventJoypadButton = InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)
	adjust_for_ui_events(action, event, erase)
	
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
	crosshair_mode = FIXED_CROSSHAIRS
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
	crosshair_mode = FIXED_CROSSHAIRS
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
	crosshair_mode = FIXED_CROSSHAIRS
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
	
	crosshair_mode = FREE_CROSSHAIRS
	ControllerIcons.refresh()

func _input(event : InputEvent):
	if event is InputEventMouse:
		can_use_mouse = true

func get_joystick_event_from_id(id : int) -> InputEventJoypadMotion:
	var event : InputEventJoypadMotion = InputEventJoypadMotion.new()
	match id:
		LEFT_JOYSTICK_UP:
			event.axis = JOY_AXIS_LEFT_Y
			event.axis_value = -1.0
		LEFT_JOYSTICK_DOWN:
			event.axis = JOY_AXIS_LEFT_Y
			event.axis_value = 1.0
		LEFT_JOYSTICK_LEFT:
			event.axis = JOY_AXIS_LEFT_X
			event.axis_value = -1.0
		LEFT_JOYSTICK_RIGHT:
			event.axis = JOY_AXIS_LEFT_X
			event.axis_value = 1.0
		RIGHT_JOYSTICK_UP:
			event.axis = JOY_AXIS_RIGHT_Y
			event.axis_value = -1.0
		RIGHT_JOYSTICK_DOWN:
			event.axs = JOY_AXIS_RIGHT_Y
			event.axis_value = 1.0
		RIGHT_JOYSTICK_LEFT:
			event.axis = JOY_AXIS_RIGHT_X
			event.axis_value = -1.0
		RIGHT_JOYSTICK_RIGHT:
			event.axis = JOY_AXIS_RIGHT_X
			event.axis_value = 1.0
	return event
	
func set_user_action(action : StringName, values : Array, types : Array):
	for type in types:
		match type:
			InputTypes.KEY:
				for value in values:
					set_control_key(action, value, false)
			InputTypes.MOUSE_BUTTON:
				for value in values:
					set_control_mouse_button(action, value, false)
			InputTypes.JOYSTICK:
				for value in values:
					var event = get_joystick_event_from_id(value)
					set_control_joystick(action, event.axis, event.axis_value, false)
			InputTypes.BUTTON:
				for value in values:
					set_control_button(action, value, false)
					
func set_user_controls(scheme : Dictionary[StringName, Array], types : Dictionary[StringName, Array]):
	for action : StringName in scheme:
		InputMap.action_erase_events(action)
		set_user_action(action, scheme[action], types[action])
		
func set_controls_user_gamepad():
	set_controls_gamepad()
	set_user_controls(gamepad_scheme, gamepad_scheme_types)
		
func set_controls_user_keyboard():
	set_controls_mouse()
	set_user_controls(keyboard_scheme, keyboard_scheme_types)
	# TODO: Figure out why the enter key keeps getting overwritten whenever the player
	#  customizes anything in the keyboard configuration.
	set_control_key("ui_accept", KEY_ENTER, false)
