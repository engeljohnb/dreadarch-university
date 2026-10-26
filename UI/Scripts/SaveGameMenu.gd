extends Control
signal save_file_chosen(filename)
signal closed()

var _mode = null

const EMPTY_SLOT_NAME = "empty"
enum OpenModes {
	SAVE = 0,
	LOAD = 1
}

var all_buttons : Array[Button]
var lifebars = []
var icons = []
func on_save_file_chosen(_filename):
	close()

func _ready():
	if not DirAccess.dir_exists_absolute(Utils.SAVE_FILE_DIRECTORY):
		DirAccess.make_dir_recursive_absolute(Utils.SAVE_FILE_DIRECTORY)
	save_file_chosen.connect(on_save_file_chosen)
	for child in get_children():
		if child is Button:
			if child.disabled == false:
				child.grab_focus()
				break

func get_button_name(filename : String):
	return filename.replace(Utils.SAVE_FILE_DIRECTORY, "").replace(".da", "")
	
func get_save_filename(location_name, slot_num):
	# index+1 because save slot numbering starts at 1
	return Utils.SAVE_FILE_DIRECTORY + str(slot_num) + " - " + location_name + ".da"
	
func get_location_name(room_name):
	if "00-" in room_name:
		return "University Campus"
	else:
		return "Shallow Ruins"
	
func make_save_slot_mini_gui(button : Button, index : int):
	var save_data = Utils.read_save_data_from_slot(button.text[0])
	if save_data == null:
		print("ERROR: Can't open save slot ", button.text[0])
		return
	var lifebar = load("res://Characters/Player/Lifebar.tscn").instantiate()
	var life = save_data.player.life
	var total_life = save_data.player.total_life
	var temp_life = save_data.player.temporary_life
	if total_life == 0:
		total_life = 3
	lifebar.for_save_slot = true
	button.add_child(lifebar)
	lifebar.name = "Lifebar"
	lifebar.set_life_total(total_life, life)
	lifebar.position.x += 25
	if temp_life > 0:
		lifebar.gain_temporary_life(temp_life)
	lifebar.modulate *= 1.2
	lifebars.append(lifebar)
	
	var scroll_icon = load("res://UI/NumScrollFragments.tscn").instantiate()
	var num_scroll_fragments = save_data.player.documents.size()
	scroll_icon.set_num_scroll_fragments(num_scroll_fragments)
	scroll_icon.position = Vector2(-75, (button.position.y + 35) + (75.0 * index))
	scroll_icon.modulate /= 1.5
	add_child(scroll_icon)
	icons.append(scroll_icon)
	
func make_button(save_filename, button : Button, index : int):
	var slot_num = index+1
	button.add_theme_font_size_override("font_size", 32)
	var scene_name = ""
	if Utils.is_valid_save_filename(save_filename):
		if _mode == OpenModes.LOAD:
			var save_data = Utils.read_save_data_from_file(save_filename)
			if save_data == null:
				print("ERROR: Can't open file: ", save_filename)
				return make_empty_save_slot(button)
			scene_name = save_data.current_scene
		else:
			scene_name = SceneTransition.current_scene_name
		button.text = get_button_name(save_filename)
	elif save_filename == EMPTY_SLOT_NAME:
		scene_name = SceneTransition.current_scene_name
		button.text = EMPTY_SLOT_NAME
	var location_name = get_location_name(scene_name)
	var button_filename : String = get_save_filename(location_name, slot_num)
	if not save_filename == EMPTY_SLOT_NAME:
		make_save_slot_mini_gui(button, index)
	button.pressed.connect(save_file_chosen.emit.bind(button_filename))
	button.set_deferred("size.x", 302.0)
	return button

func make_empty_save_slot(button : Button):
	button.text = EMPTY_SLOT_NAME
	button.disabled = true
	button.focus_mode = FocusMode.FOCUS_NONE
	return button

func open(all_save_filenames : Array[String], mode = OpenModes.SAVE, max_save_files : int = 5):
	_mode = mode
	var occupied_save_slots = []
	for filename in all_save_filenames:
		if Utils.is_valid_save_filename(filename):
			var slot_num = int(get_button_name(filename)[0])
			var button : Button = get_node(str(slot_num-1))
			all_buttons.append(make_button(filename, button, slot_num-1))
			occupied_save_slots.append(slot_num)
		else:
			print("ERROR: invalid save filename: ", filename)
	# Iterating twice is necessary to make the slots appear in the right order
	for i in range(0, max_save_files):
		var slot_num = i+1
		if slot_num not in occupied_save_slots:
			var button : Button = get_node(str(slot_num-1))
			if mode == OpenModes.SAVE:
				all_buttons.append(make_button(EMPTY_SLOT_NAME, button, slot_num-1))
			else:
				all_buttons.append(make_empty_save_slot(button))
	for button in all_buttons:
		if all_buttons.find(button) < max_save_files:
			var separator = HSeparator.new()
			separator.size.x = 375
			separator.position.x -= 62
			separator.position.y = button.position.y+64
	
func close():
	closed.emit()
	queue_free()

func _process(_delta):
	if Input.is_action_just_pressed("UI Cancel"):
		close()
