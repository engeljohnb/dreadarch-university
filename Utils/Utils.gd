extends Node
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)
const UP = Vector2(0,-1)
const DOWN = Vector2(0,1)
const SAVE_FILE_DIRECTORY = "user://SaveFiles/"
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
		
func nearest_cardinal_direction(direction : Vector2, as_text = false):
	var x = direction.x
	var y = direction.y
	if (abs(x) > abs(y)):
		if (x < 0):
			if as_text:
				return "Left"
			else:
				return LEFT
		else:
			if as_text:
				return "Right"
			else:
				return RIGHT
	else:
		if (y < 0):
			if as_text:
				return "Up"
			else:
				return UP
		else:
			if as_text:
				return "Down"
			else:
				return DOWN

func is_scroll_fragment(document):
	if not (document is Dictionary):
		return false
	return document.get("document_type") == Collectible.SCROLL_FRAGMENT

func is_valid_save_filename(filename):
	var valid = true
	if not filename.containsn("user://"):
		valid = false
	if not filename.containsn(".da"):
		valid = false
	var slot_name = filename.replace(Utils.SAVE_FILE_DIRECTORY, "")
	var index = slot_name[0]
	if not index.is_valid_int():
		valid = false
	else:
		if int(index) < 1:
			valid = false
	return valid
		
func read_save_data_from_file(filename = "user://SaveFiles/save.da"):
	var file = FileAccess.open(filename, FileAccess.READ)
	if file == null:
		print("Error reading save data for file" + filename + ":", FileAccess.get_open_error())
	var _save = Save.new()
	_save.init()
	_save = DictionarySerializer.deserialize_json(file.get_as_text())
	file.close()
	return _save
func read_save_data_from_slot(slot):
	var files = DirAccess.get_files_at(SAVE_FILE_DIRECTORY)
	slot = str(slot)
	var filename = ""
	for file in files:
		if file[0] == slot:
			filename = file
			break
	var f = FileAccess.open(SAVE_FILE_DIRECTORY + filename, FileAccess.READ)
	var _save = Save.new()
	_save.init()
	_save = DictionarySerializer.deserialize_json(f.get_as_text())
	f.close()
	return _save
	
func save_slot_has_data(filename):
	var slot_name = filename.replace(Utils.SAVE_FILE_DIRECTORY, "")
	var index = slot_name[0]
	var dir = DirAccess.get_files_at(Utils.SAVE_FILE_DIRECTORY)
	for f in dir:
		if f[0] == index:
			return true
	return false
	
func delete_save_slot(filename):
	var dir = DirAccess.open(Utils.SAVE_FILE_DIRECTORY)
	var files = dir.get_files()
	for file in files:
		var slot_name = filename.replace(Utils.SAVE_FILE_DIRECTORY, "")
		if file[0] == slot_name[0]:
			dir.remove(file)
			
func write_save_data_to_file(save_data, filename):
	var game_save_string = DictionarySerializer.serialize_json(save_data)
	if is_valid_save_filename(filename):
		if save_slot_has_data(filename):
			delete_save_slot(filename)
		var file = FileAccess.open(filename, FileAccess.WRITE)
		file.store_string(game_save_string)
		file.close() 
	else:
		print("Error: invalid filename (game was not : ", filename)

func read_file(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var content = file.get_as_text()
	return content

func interactables_equal(i1 : Dictionary, i2 : Dictionary) -> bool:
	var name1 = i1.get("name")
	var name2 = i2.get("name")
	if (name1 == null):
		print("ERROR: invalid interactable object: ", i1)
		return false
	elif (name2 == null):
		print("ERROR: invalid interactable object: ", i2)
		return false
	return name1 == name2
