# Note on conventions:
	# "update" is reading from game state and writing it to the save data
	# "load" is reading from the save data and writing it to the game state
extends Node2D

const DUNGEON_MUSIC = "res://Music/DungeonMusic.ogg"
const DEATH_MUSIC = "res://Music/DeathMusic.ogg"
@onready var hud = $CanvasLayer/HUD
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var canvas = $CanvasLayer
@onready var close_menu_sound = $CloseMenuSound
@onready var music = $Music

# For some reason, defining a "new" function on these classes
#  breaks the JSON serializer used for game saves.
#  So they have init. use it like save.init(), not save = Save.new()
class Player:
	var level : int
	var attack_damage : int
	var position: Vector2
	var life: int
	var temporary_life : int
	var total_life: int
	# Guess it has to be a dictionary bc for some reason the JSON serializer can do Class.Class, but not Class.Class.Class
	var inventory: Dictionary
	func init():
		level = 1
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
		
var current_scene = null
var current_music = null
var death_cutscene = {"timer":0.0, "duration":2.5}
var player = null
var _save = Save.new()
var _player = Player.new()
var floor_tiles = null
var step_sound_source = null
var max_save_files = 5
#var all_save_filenames : Array[String]


func apply_or_remove_footstep_reverb():
	#if the player's going up
	var volume_diff = 4.0
	if SceneTransition.prev_scene_name.contains("01-") and SceneTransition.current_scene_name.contains("00-"):
		player.step_sound.volume_db -= volume_diff
		var bus_id = AudioServer.get_bus_index("FXReverb")
		AudioServer.set_bus_effect_enabled(bus_id, 0, false)
	#if the player's going down
	if SceneTransition.prev_scene_name.contains("00-") and SceneTransition.current_scene_name.contains("01-"):
		player.step_sound.volume_db += volume_diff
		var bus_id = AudioServer.get_bus_index("FXReverb")
		AudioServer.set_bus_effect_enabled(bus_id, 0, true)
		
func new_game():
	_save.init()
	_player.init()
	Collectible.load_collected_scroll_fragments([])
	_save.player = _player
	init_player()
	player.init_for_newgame()
	SceneTransition.enter_scene("Dungeons/01/01-01.tscn")

func _prompt_player(text, on_yes, on_no, yes_text = "yes", no_text = "no"):
	var prompt = load("res://UI/Prompt.tscn").instantiate()
	$CanvasLayer.add_child(prompt)
	prompt.prompt(text, on_yes, on_no, yes_text, no_text)

func _notify_player(note):
	var _notification = load("res://UI/Notification.tscn").instantiate()
	$CanvasLayer.add_child(_notification)
	_notification.notify(note)
	
func _open_document():
	var viewer = load("res://UI/DocumentViewer.tscn").instantiate()
	$CanvasLayer.add_child(viewer)

func on_dialogue_ended():
	player.in_dialogue = false
	
func _open_dialogue(dialogue):
	var box = load("res://UI/DialogueBox.tscn").instantiate()
	if "dialogue" in box:
		box.dialogue = dialogue
	box.dialogue_ended.connect(on_dialogue_ended)
	$CanvasLayer.add_child(box)
	player.in_dialogue = true
	player.sprite.play("Idle " + Utils.nearest_cardinal_direction(player.facing, true))
	player.step_sound.stop()
	
func hide_hud():
	hud.visible = false
	$CanvasLayer/HUD/Treasure/CanvasLayer.visible = false
	$CanvasLayer/HUD/Equipped/CanvasLayer.visible = false

func show_hud():
	hud.visible = true
	if int($CanvasLayer/HUD/Treasure/CanvasLayer/RichTextLabel.text) > 0:
		$CanvasLayer/HUD/Treasure/CanvasLayer.visible = true
	
func on_player_lost_dagger():
	$CanvasLayer/HUD/Equipped/CanvasLayer.visible = false
	
func on_player_gain_temporary_life(life):
	hud.lifebar.gain_temporary_life(life)
	
func init_player():
	if player:
		player.queue_free()
	player = load("res://Characters/Player/Player.tscn").instantiate()
	player.lost_life.connect(on_player_lost_life)
	player.gained_life.connect(on_player_gain_life)
	player.gained_temporary_life.connect(on_player_gain_temporary_life)
	player.died.connect(on_player_dead)
	player.z_index = 0
	player.inventory = _player.inventory
	if not player.item_equipped.is_connected(hud.on_item_equipped):
		player.item_equipped.connect(hud.on_item_equipped)
	hud.set_treasure(0)
	if not Collectible.item_collected.is_connected(player.on_item_collected):
		Collectible.item_collected.connect(player.on_item_collected)
	if not Collectible.scroll_fragment_translated.is_connected(player.on_scroll_fragment_translated):
		Collectible.scroll_fragment_translated.connect(player.on_scroll_fragment_translated)
	#hud.lifebar.set_life_total(player.total_life, player.life)
	hud._show()

func end_gameplay():
	hud._hide()
	player = current_scene.get_node("Player")
	if (player.get_node_or_null("PlayerAttackFX")):
		player.get_node("PlayerAttackFX").queue_free()
	player.queue_free()
	current_scene.queue_free()

func on_player_lost_life(damage):
	hud.lifebar.deduct_damage(damage)
	
func on_player_gain_life(life):
	hud.lifebar.gain_life(life)

func player_death_cutscene(delta):
	var timer = death_cutscene["timer"]
	var fade_time = 0.5
	if delta == 0.0:
		player.step_sound.stop()
		music.stream = load(DEATH_MUSIC)
		music.play()
		death_cutscene["timer"] = 0.0
		player.in_cutscene = true
		player.current_cutscene = null
		player.sprite.play("Death")
		player.z_index = 10
		var viewport_size = get_viewport_rect().size
		$Fade.texture.width = viewport_size.x+2
		$Fade.scale.y = viewport_size.y+2
		$Fade.global_position = player.global_position
		hud._hide()
		var playback = player.anim_tree["parameters/playback"]
		playback.travel("End")
	else:
		if player.sprite.animation != "Death":
			player.sprite.play("Death")
		if player.sprite.frame <= 11:
			$Fade.modulate.a = (timer/fade_time)
		if player.sprite.frame > 19:
			player.modulate.a = 1.7 - (timer/(fade_time+1))
		if (player.modulate.a <= 0.0) or (timer >= death_cutscene["duration"]):
			$Fade.modulate.a = 0.0
			death_cutscene["timer"] = 0.0
			player.in_cutscene = false
			end_gameplay()
			current_scene = load("res://UI/DeathMenu.tscn").instantiate()
			current_scene.z_index = 3
			canvas.add_child(current_scene)
			current_scene.loadgame_button.pressed.connect(open_load_game_menu)
			current_scene.newgame_button.pressed.connect(new_game)
			get_tree().paused = true
		death_cutscene["timer"] += delta
			
func on_player_dead():
	player_death_cutscene(0.0)
	
func update_room_interactables_save_data(scene_node : Node2D, interactables : Array):
	var updated_npcs = []
	for i in interactables:
		assert(("type" in i), "ERROR: Interactable object " + i.name + "does not have defined type.")
		match i.type:
			Types.POT:
				if (not i.activated) and (not i.has_overrides.is_empty()):
					if Collectible.GOLDEN_DAGGER in i.has_overrides:
						i.has_overrides.erase(Collectible.GOLDEN_DAGGER)
					scene_node.save_data["pots"].append({"name":i.name,"has":i.has_overrides,"amounts":i.amounts})
			Types.NPC:
				if "status" in i:
					var npc = {"name":i.name, "status":i.status}
					if npc not in scene_node.save_data["NPCs"]:
						scene_node.save_data["NPCs"].append(npc)
						updated_npcs.append(npc)
	return updated_npcs
	
func update_room_gone_npcs(scene_node : Node2D, updated_npcs):
	var npcs_saved = []
	if _save.rooms.get(scene_node.name):
		if _save.rooms[scene_node.name].get("NPCs"):
			npcs_saved = _save.rooms[scene_node.name]["NPCs"]
	for npc in npcs_saved:
		var collected = false
		for c_npc in updated_npcs:
			if Utils.interactables_equal(c_npc, npc):
				collected = true
				break
		if not collected:
			if npc not in scene_node.save_data["NPCs"]:
				scene_node.save_data["NPCs"].append(npc)
	var treasures = scene_node.get_node_or_null("Treasure")
	if treasures:
		scene_node.save_data["items"][Collectible.TREASURE] = []
		for treasure in treasures.get_children():
			scene_node.save_data["items"][Collectible.TREASURE].append(treasure.name)
			
func update_room_save_data(scene_node : Node2D, scene_name : String):
	if not ("save_data" in scene_node):
		return {}
	var interactables = get_tree().get_nodes_in_group("Interactable")
	var updated_npcs = update_room_interactables_save_data(scene_node, interactables)
	update_room_gone_npcs(scene_node, updated_npcs)
	_save.rooms[scene_name] = scene_node.save_data

func load_room_interactables_save_data(scene_node : Node2D):
	var scene_path = str(get_path_to(scene_node))
	if _save.rooms[SceneTransition.current_scene_name].get("pots"):
		for i in _save.rooms[SceneTransition.current_scene_name]["pots"]:
			var pot = get_node(NodePath(scene_path + "/Pots/" + i["name"]))
			pot.activated = false
			pot.has_overrides = i["has"]
			pot.amounts = i["amounts"]
	if _save.rooms[SceneTransition.current_scene_name].get("NPCs"):
		for i in _save.rooms[SceneTransition.current_scene_name]["NPCs"]:
			var npc = get_node(NodePath(scene_path + "/NPCs/" + i["name"]))
			if npc.get("status"):
				npc.status = i["status"]
				if npc.status.get("gone"):
					npc.queue_free()
func load_room_cutscene_save_data(scene_node : Node2D):
	var cutscenes = _save.rooms[SceneTransition.current_scene_name].get("cutscenes")
	if cutscenes:
		scene_node.save_data["cutscenes"] = cutscenes
		
func load_room_treasure_save_data(scene_node : Node2D):
	var treasure_node = scene_node.get_node_or_null("Treasure")
	if treasure_node:
		var scene_treasures = treasure_node.get_children()
		var items = _save.rooms[SceneTransition.current_scene_name].get("items")
		var uncollected_treasures = []
		if items:
			uncollected_treasures = items[Collectible.TREASURE]
		for scene_treasure in scene_treasures:
			if not (scene_treasure.name in uncollected_treasures):
				scene_treasure.queue_free()
	
func load_room_save_data(scene_node : Node2D):
	if not ("save_data" in scene_node):
		return
	load_room_interactables_save_data(scene_node)
	load_room_cutscene_save_data(scene_node)
	load_room_treasure_save_data(scene_node)
	
				
func load_current_scene_node():
	if current_scene:
		current_scene.queue_free()
	current_scene = load(SceneTransition.current_scene_path).instantiate()
	current_scene.process_mode = PROCESS_MODE_PAUSABLE
# Don't ask me how it ended up like this 
func on_player_entered_grass():
	step_sound_source = "Grass"
func on_player_exited_grass():
	step_sound_source = floor_tiles

func update_footstep_sound_source():
	var _floor_tiles = get_tree().get_nodes_in_group("FloorLayer")
	if _floor_tiles.size() > 0:
		for t in _floor_tiles:
			if t != floor_tiles:
				floor_tiles = t
				break
	else:
		floor_tiles = null
	# Scene collection TileMapLayers can't use custom data layers the way other TileMapLayers can,
	#   So I use signals to tell if the player's on grass or not.
	var grass_tileset = current_scene.get_node_or_null("GrassTiles")
	if grass_tileset:
		grass_tileset.player_entered_grass.connect(on_player_entered_grass)
		grass_tileset.player_exited_grass.connect(on_player_exited_grass)
	step_sound_source = floor_tiles
	apply_or_remove_footstep_reverb()

func init_player_for_new_scene():
	# Initialization that has to be done before the player enters the scene
	if not player:
		init_player()
	player.y_sort_enabled = true
	player.z_index = 0
	if player.get_parent():
		player.reparent(current_scene)
	else:
		current_scene.add_child(player)
	hud.lifebar.set_life_total(player.total_life, player.life+player.temporary_life)
	
func init_current_scene():
	add_child(current_scene)
	var world_level = SceneTransition.current_scene_name.substr(0, 2)
	if world_level == "00":
		player.step_sound.bus = "Master"
	if SceneTransition.current_scene_name == "WelcomeMenu" or SceneTransition.prev_scene_name == "WelcomeMenu":
		music.update(current_scene, false, true)
	else:
		music.update(current_scene)
	get_tree().paused = false
		
func load_player_for_new_scene():
	player.global_position = SceneTransition.player_start_position
	player.in_cutscene = false

func play_scene_entrance_cutscene():
	if SceneTransition.by_door:
		player.modulate.a = 0.0
		match player.door_cutscene["direction"]:
			"North":
				var pos = SceneTransition.player_start_position
				pos.y -= 200.0
				player.play_door_cutscene(0.0, pos, "North", true)
			"South":
				var pos = SceneTransition.player_start_position
				pos.y += 120.0
				player.play_door_cutscene(0.0, pos, "South", true)
			"East":
				var pos = SceneTransition.player_start_position
				pos.x += 250.0
				player.play_door_cutscene(0.0, pos, "East", true)
			"West":
				var pos = SceneTransition.player_start_position
				pos.x -= 250.0
				player.play_door_cutscene(0.0, pos, "West", true)
	if SceneTransition.by_outside_door:
		player.modulate.a = 0.0
		player.play_outside_door_cutscene(0.0, true)
	if SceneTransition.by_ladder:
		player.sprite.modulate.a = 1.0
		var direction = SceneTransition.ladder_direction
		var start_pos = SceneTransition.player_start_position
		player.play_climb_cutscene(0.0,
		{"position":start_pos, "start_pos":start_pos, "direction":direction, "arriving":true})
		
func on_new_scene():
	if SceneTransition.scene_changed():
		if not (current_scene is Control):
			update_room_save_data(current_scene, SceneTransition.prev_scene_name)
	load_current_scene_node()
	init_player_for_new_scene()
	init_current_scene()
	var scene_name = SceneTransition.current_scene_name
	if _save.rooms.get(scene_name):
		if not _save.rooms[scene_name].is_empty():
			load_room_save_data(current_scene)
	# If player is above ground, turn down the light
	if SceneTransition.entering_or_leaving_underground():
		player.toggle_light()
	pause_menu.visible = false
	load_player_for_new_scene()
	play_scene_entrance_cutscene()
	update_footstep_sound_source()
	
func open_load_game_menu(pos = null):
	var menu = load("res://UI/SaveGameMenu.tscn").instantiate()
	menu.save_file_chosen.connect(load_game)
	
	var menu_pos : Vector2
	if not pos:
		var menu_pos_y = 250+menu.size.y+10
		var menu_pos_x = (get_window().size.x/2.0) - (250)
		menu_pos = Vector2(menu_pos_x, menu_pos_y)
	else:
		menu_pos = pos
	var saves = get_all_save_filenames()
	menu.open(saves, menu.OpenModes.LOAD, menu_pos, max_save_files)
	var from_gameplay = not ((current_scene.name == "WelcomeMenu") or (current_scene.name == "DeathMenu"))
	if not from_gameplay:
		# Because in the welcome and death menus, the lifebar looks really dark
		# compared to the bright bg
		menu.set_mini_gui_lifebar_brightness(3.0)
		menu.set_mini_gui_icon_brightness(0.66)
		current_scene.add_child(menu)
		current_scene.hide_all()
		menu.closed.connect(current_scene.show_all)
	else:
		menu.set_mini_gui_icon_brightness(0.8)
		if pause_menu.visible:
			pause_menu.hide_all()
			menu.closed.connect(pause_menu.show_all)
		hud.add_child(menu)
	#load_game()
	
func get_all_save_filenames():
	var saves : Array[String]
	var dir = DirAccess.open("user://SaveFiles/")
	for filename in dir.get_files():
		saves.append(dir.get_current_dir() + "/" + filename)
		if saves.size() > max_save_files:
			break
	return saves

func open_save_game_menu(pos = null):
	var menu = load("res://UI/SaveGameMenu.tscn").instantiate()
	menu.save_file_chosen.connect(save_game)
	menu.save_file_chosen.connect(pause_menu.on_save_file_chosen)
	var all_saves = get_all_save_filenames()

	var menu_pos : Vector2
	if not pos:
		var menu_pos_y = 250+menu.size.y+10
		var menu_pos_x = (get_window().size.x/2.0) - (250)
		menu_pos = Vector2(menu_pos_x, menu_pos_y)
	else:
		menu_pos = pos
	menu.open(all_saves, menu.OpenModes.SAVE, menu_pos, max_save_files)
	menu.set_mini_gui_icon_brightness(0.8)
	if pause_menu.visible:
		pause_menu.hide_all()
		menu.closed.connect(pause_menu.show_all)
	hud.add_child(menu)
		
func on_won():
	player.play_victory_cutscene(0.0)

func init_wm_settings():
	var screen_size = DisplayServer.window_get_size()
	get_window().size = screen_size
	ProjectSettings.set_setting("display/window/size/mode", DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _ready():
	seed(1)
	init_wm_settings()
	music.stream = load("res://Music/DungeonMusic.ogg")
	music.play()
	ObjectSerializer.register_script("Save", Save)
	ObjectSerializer.register_script("Player", Player)
	_save.init()
	_player.init()
	_save.player = _player

	current_scene = load("res://UI/WelcomeMenu.tscn").instantiate()
	music.update(current_scene)
	init_player()
	
	pause_menu.save_button.pressed.connect(open_save_game_menu.bind(Vector2(720,200)))
	pause_menu.load_button.pressed.connect(open_load_game_menu.bind(Vector2(720,200)))
	pause_menu.continue_button.pressed.connect(close_menu_sound.play)
	
	Dialogue.prompt_player.connect(_prompt_player)
	Dialogue.open_document.connect(_open_document)
	Dialogue.open_dialogue.connect(_open_dialogue)
	Dialogue.notify_player.connect(_notify_player)
	
	canvas.add_child(current_scene)
	current_scene.loadgame_button.pressed.connect(open_load_game_menu)
	
	Collectible.item_collected.connect(hud.on_item_collected)
	Collectible.item_collected.connect(Collectible.on_item_collected)
	SceneTransition.new_scene.connect(on_new_scene)
	SceneTransition.won.connect(on_won)
	get_tree().paused = true

func update_current_scene():
	_save.current_scene = SceneTransition.current_scene_name
	_save.current_scene_path = SceneTransition.current_scene_path
func update_save_data():
	_save.player.total_life = player.total_life
	_save.player.life = player.life
	_save.player.temporary_life = player.temporary_life
	_save.player.position = player.global_position
	_save.player.inventory = player.inventory
	_save.player.attack_damage = player.attack_damage
	update_current_scene()
	update_room_save_data(current_scene, SceneTransition.current_scene_name)
	_save.completed_tutorial_prompts = Collectible.get_completed_tutorial_prompts()
	_save.player.level = player.level
	
func save_game(filename = "user://SaveFiles/save.da"):
	update_save_data()
	Utils.write_save_data_to_file(_save, filename)
	
func load_player(player_data):
	init_player()
	player.life = player_data.life
	player.total_life = player_data.total_life
	player.temporary_life = player_data.temporary_life
	player.attack_damage = player_data.attack_damage
	
	player.global_position = player_data.position
	player.inventory = player_data.inventory
	player.level = player_data.level

	Collectible.load_collected_scroll_fragments(player_data.inventory[Collectible.SCROLL_FRAGMENT])
	
func load_hud(player_data):
	hud.lifebar.temporary_life = player_data.temporary_life
	hud.lifebar.life = player_data.life
	hud.lifebar.set_life_total(player.total_life, player.total_life+player.temporary_life)
	hud.set_treasure(player.inventory[Collectible.TREASURE])
	
func load_game(filename = "user://SaveFiles/save.da"):
	_save = null
	_save = Utils.read_save_data_from_file(filename)

	load_player(_save.player)
	load_hud(_save.player)
	
	Collectible.load_completed_tutorial_prompts(_save.completed_tutorial_prompts)
	SceneTransition.enter_scene(_save.current_scene_path, player.global_position)

func open_inventory():
	var inventory = load("res://UI/InventoryMenu.tscn").instantiate()
	inventory.top_level = true
	$CanvasLayer.add_child(inventory)
	inventory.open(player.inventory)
	inventory.inventory_action_chosen.connect(player.on_inventory_action_chosen)

func _process(_delta):
	if player:
		if (not player.in_cutscene) and (not player.in_dialogue):
			# Sometimes step_sound_source is "previously freed"
			#  for the first loop after changing rooms
			if not step_sound_source:
				update_footstep_sound_source()
			player.update_step_sound(step_sound_source)
			if Input.is_action_just_pressed("Pause"):
				pause_menu.pause_game()
			if Input.is_action_just_pressed("OpenInventory"):
				open_inventory()
	if player.won:
		# Victory Cutsceene needs to end first
		if not player.in_cutscene:
			end_gameplay()
			current_scene = load("res://UI/VictoryMenu.tscn").instantiate()
			current_scene.z_index = 3
			canvas.add_child(current_scene)
			get_tree().paused = true
	if player.dead:
		if player.in_cutscene:
			player_death_cutscene(_delta)

		
	
