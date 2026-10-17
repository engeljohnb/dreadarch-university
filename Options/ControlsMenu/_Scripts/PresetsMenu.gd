extends Control
@onready var preset_list = $ItemList
@onready var apply = $Apply
@onready var cancel = $Cancel
signal closed

func set_preset():
	var preset_name = preset_list.get_item_text(preset_list.get_selected_items()[0])
	match preset_name:
		"        Keyboard and Mouse":
			Controls.set_controls_mouse()
		"        Keyboard Only - WASD":
			Controls.set_controls_keyboard_wasd()
		"        Keyboard Only - Arrows":
			Controls.set_controls_keyboard_arrows()
		"        Gamepad":
			Controls.set_controls_gamepad()
			
func activate_buttons(_selected_item):
	cancel.disabled = false
	apply.disabled = false
	cancel.visible = true
	apply.visible = true
	apply.grab_focus()
	
func _ready() -> void:
	preset_list.item_selected.connect(activate_buttons)
	apply.pressed.connect(set_preset)
	cancel.pressed.connect(closed.emit)
