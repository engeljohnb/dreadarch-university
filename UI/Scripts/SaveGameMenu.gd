extends Control
signal save_file_chosen(filename)
signal closed()

class Player:
	var attack_damage
	var position: Vector2
	var life: int
	var temporary_life : int
	var total_life: int
	# Guess it has to be a dictionary bc for some reason the JSON serializer can do Class.Class, but not Class.Class.Class
	var inventory: Dictionary
	func init():
		attack_damage = 1
		position = Vector2()
		life = 3
		temporary_life = 0
		total_life = 0
		inventory = {
			Collectible.SCROLL_FRAGMENT : [],
			Collectible.TREASURE : int(0),
			Collectible.TALONS: int(0),
			Collectible.GOLDEN_DAGGER : int(0)
		}

class Save:
	var current_scene: String
	var current_scene_path : String
	var player: Player
	var rooms : Dictionary
	var completed_tutorial_prompts : Array
	func init():
		current_scene = "01-01"
		current_scene_path = "res://Dungeons/01/01-01.tscn"
		player = null
		rooms = {}
		completed_tutorial_prompts = []

const EMPTY_SLOT_NAME = "empty"
enum OpenModes {
	SAVE = 0,
	LOAD = 1
}

var all_buttons : Array[Button]

func on_save_file_chosen(_filename):
	close()

func _ready():
	if not DirAccess.dir_exists_absolute(Utils.SAVE_FILE_DIRECTORY):
		DirAccess.make_dir_recursive_absolute(Utils.SAVE_FILE_DIRECTORY)

	save_file_chosen.connect(on_save_file_chosen)
	if all_buttons.size() > 0:
		all_buttons[0].grab_focus()

func get_button_name(filename : String):
	return filename.replace(Utils.SAVE_FILE_DIRECTORY, "").replace(".da", "")
	
func get_save_filename(index):
	# index+1 because save slot numbering starts at 1
	return Utils.SAVE_FILE_DIRECTORY + str(index) + " - " + get_location_name() + ".da"
	
func get_location_name():
	if "00-" in SceneTransition.current_scene_name:
		return "University Campus"
	else:
		return "Shallow Ruins"
	
func make_save_slot_mini_gui(button, pos):
	var save_data = Utils.read_save_data_from_slot(button.text[0])
	var lifebar = load("res://Characters/Player/Lifebar.tscn").instantiate()
	var life = save_data.player.life
	var total_life = save_data.player.total_life
	var temp_life = save_data.player.temporary_life
	if total_life == 0:
		total_life = 3
	lifebar.for_save_slot = true
	button.add_child(lifebar)
	lifebar.set_life_total(total_life, life)
	if temp_life > 0:
		lifebar.gain_temporary_life(temp_life)
	
	var treasure_icon = load("res://UI/Treasure.tscn").instantiate()
	var treasure = save_data.player.inventory[Collectible.TREASURE]
	if treasure == null:
		treasure = 0
	treasure_icon.set_treasure(treasure)
	treasure_icon.for_save_slot = true
	treasure_icon.save_slot_position = pos + button.position
	button.add_child(treasure_icon)
	
	var scroll_icon = load("res://UI/NumScrollFragments.tscn").instantiate()
	var num_scroll_fragments = save_data.player.inventory[Collectible.SCROLL_FRAGMENT].size()
	scroll_icon.set_num_scroll_fragments(num_scroll_fragments)
	scroll_icon.set_position_for_mini_gui(pos.y + button.position.y - 10)
	button.add_child(scroll_icon)
	
func make_button(save_filename, pos, slot_num):
	var button = Button.new()
	var index = slot_num-1
	button.text = get_button_name(save_filename)
	button.size.x = 499
	button.size.y = 131
	button.position.y = 150*(int(index))
	button.z_index = 100
	button.z_as_relative = false
	button.add_theme_font_size_override("font_size", 75)
	var button_filename : String
	button_filename = get_save_filename(slot_num)
	if not save_filename == EMPTY_SLOT_NAME:
		make_save_slot_mini_gui(button, pos)
	button.pressed.connect(save_file_chosen.emit.bind(button_filename))
	return button

func make_empty_save_slot(slot_num):
	var button = Button.new()
	var index = slot_num-1
	button.text = EMPTY_SLOT_NAME
	button.disabled = true
	button.size.x = 499
	button.size.y = 131
	button.position.y = 150*index
	button.focus_mode = FocusMode.FOCUS_NONE
	return button

func open(all_save_filenames : Array[String], mode = OpenModes.SAVE, pos = Vector2(), max_save_files : int = 5):
	var non_empty_save_slots = []
	for i in range(0, max_save_files):
		if i < all_save_filenames.size():
			var filename = all_save_filenames[i]
			if Utils.is_valid_save_filename(filename):
				var slot_num = int(get_button_name(filename)[0])
				all_buttons.append(make_button(all_save_filenames[i], pos, slot_num))
				non_empty_save_slots.append(slot_num)
	# Iterating twice is necessary to make the slots appear in the right order
	for i in range(0, max_save_files):
		var slot_num = i+1
		if slot_num not in non_empty_save_slots:
			if mode == OpenModes.SAVE:
				all_buttons.append(make_button(EMPTY_SLOT_NAME, pos, slot_num))
			else:
				all_buttons.append(make_empty_save_slot(slot_num))
	for button in all_buttons:
		add_child(button)
		if all_buttons.find(button) < max_save_files:
			var separator = HSeparator.new()
			separator.size.x = 750
			separator.position.x -= 125
			separator.position.y = button.position.y+131
			add_child(separator)
	position = pos

func close():
	closed.emit()
	queue_free()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		close()
