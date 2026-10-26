extends Control
signal closed()
var listening_for_input := false
var just_found_input := false
func _ready():
	$TabContainer/Presets.closed.connect(close)
	$TabContainer.get_tab_bar().grab_focus()
	for button in $TabContainer/Customize.get_children():
		if button is RemapButton:
			button.found_input.connect(func (): just_found_input = true)

func close():
	Controls.autosave_schemes()
	queue_free()
	closed.emit()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("UI Cancel"):
		if not just_found_input:
			close()

var stupid_counter = 0
func _process(_delta):
	# This is because if the player wants to remap the "UI Cancel" button to something else,
	#  The menu will close as soon as they choose their new input.
	if just_found_input:
		stupid_counter += 1
		if stupid_counter > 1:
			stupid_counter = 0
			just_found_input = false
