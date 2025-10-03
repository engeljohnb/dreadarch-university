extends Node2D

const DUNGEON_MUSIC = "res://Music/DungeonMusic.ogg"
const DEATH_MUSIC = "res://Music/DeathMusic.ogg"
@onready var hud = $CanvasLayer/HUD
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var canvas = $CanvasLayer
@onready var close_menu_sound = $CloseMenuSound
@onready var music = $Music

class Player:
	var position: Vector2
	var life: int
	var temporary_life : int
	var total_life: int
	# Guess it has to be a dictionary bc for some reason the JSON serializer can do Class.Class, but not Class.Class.Class
	var inventory: Dictionary

class Save:
	var current_scene: String
	var current_scene_path : String
	var player: Player
	var rooms : Dictionary
	var completed_tutorial_prompts : Array

var current_scene = null
var current_music = null
var death_cutscene = {"timer":0.0, "duration":2.5}
var player = null
var _save = Save.new()
var _player = Player.new()
var floor_tiles = null

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
	hud.lifebar.set_life_total(player.total_life, player.life)
	show_hud()

func end_gameplay():
	hide_hud()
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
		hide_hud()
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
			get_tree().paused = true
		death_cutscene["timer"] += delta
			
func on_player_dead():
	player_death_cutscene(0.0)

func update_music():
	if "music" in current_scene:
		if music.stream:
			if not music.stream.resource_path == current_scene.music:
				music.stream = load(current_scene.music)
				music.play()
		else:
			music.stream = load(current_scene.music)
			music.play()
	music.stream.loop = true
		
func get_room_save_info(scene):
	if not ("save_info" in scene):
		return {SceneTransition.current_scene_name:{}}
	var interactables = get_tree().get_nodes_in_group("Interactable")
	for index in range(0, interactables.size()):
		var i = interactables[index]
		assert(("type" in i), "ERROR: Interactable object " + i.name + "does not have defined type.")
		match i.type:
			Types.POT:
				if (not i.activated) and (not i.has_overrides.is_empty()):
					if Collectible.GOLDEN_DAGGER in i.has_overrides:
						i.has_overrides.erase(Collectible.GOLDEN_DAGGER)
					scene.save_info["pots"].append({"name":i.name,"has":i.has_overrides,"amounts":i.amounts})
			Types.NPC:
				if "status" in i:
					scene.save_info["NPCs"].append({"name":i.name, "status":i.status})
	var treasures = scene.get_node_or_null("Treasure")
	if treasures:
		scene.save_info["items"][Collectible.TREASURE] = []
		for treasure in treasures.get_children():
			scene.save_info["items"][Collectible.TREASURE].append(treasure.name)
	return scene.save_info

func load_room_save_info(scene):
	if not ("save_info" in scene):
		return
	var scene_path = str(get_path_to(scene))
	if _save.rooms[SceneTransition.current_scene_name].get("pots"):
		for i in _save.rooms[SceneTransition.current_scene_name]["pots"]:
			var pot = get_node(NodePath(scene_path + "/Pots/" + i["name"]))
			pot.activated = false
			pot.has_overrides = i["has"]
			pot.amounts = i["amounts"]
	if _save.rooms[SceneTransition.current_scene_name].get("NPCs"):
		for i in _save.rooms[SceneTransition.current_scene_name]["NPCs"]:
			var npc = get_node(NodePath(scene_path + "/" + i["name"]))
			npc.status = i["status"]
			if npc.status.get("gone"):
				if npc.status["gone"]:
					npc.queue_free()
	var treasure_node = scene.get_node_or_null("Treasure")
	if treasure_node:
		var scene_treasures = treasure_node.get_children()
		var items = _save.rooms[SceneTransition.current_scene_name].get("items")
		var uncollected_treasures = []
		if items:
			uncollected_treasures = items[Collectible.TREASURE]
		for scene_treasure in scene_treasures:
			if not (scene_treasure.name in uncollected_treasures):
				scene_treasure.queue_free()
			
func on_scene_changed():
	if SceneTransition.prev_scene_name != SceneTransition.current_scene_name:
		_save.rooms[SceneTransition.prev_scene_name] = get_room_save_info(current_scene)
	current_scene.queue_free()
	current_scene = load(SceneTransition.current_scene_path).instantiate()
	current_scene.process_mode = PROCESS_MODE_PAUSABLE
	if not player:
		init_player()
	player.y_sort_enabled = true
	player.z_index = 0
	if player.get_parent():
		player.reparent(current_scene)
	else:
		current_scene.add_child(player)
		update_music()
	hud.lifebar.set_life_total(player.total_life, player.life+player.temporary_life)
	add_child(current_scene)
	var scene_name = SceneTransition.current_scene_name
	if _save.rooms.get(scene_name):
		if not _save.rooms[scene_name].is_empty():
			load_room_save_info(current_scene)
	get_tree().paused = false
	# If player is above ground, turn down the light
	if SceneTransition.current_scene_path.contains("00"):
		player.light.energy = 1.0
		player.modulate = Color(1.3,1.3,1.3)
	else:
		player.light.energy = 3.0
		player.modulate = Color(1,1,1)
	pause_menu.visible = false
	player.global_position = SceneTransition.player_start_position
	player.in_cutscene = false
	if SceneTransition.by_door:
		player.modulate.a = 0.0
		player.play_door_cutscene(0.0, SceneTransition.player_start_position, true)
	if SceneTransition.by_ladder:
		player.sprite.modulate.a = 1.0
		var direction = SceneTransition.ladder_direction
		var start_pos = SceneTransition.player_start_position
		var arriving = true
		player.play_climb_cutscene(0.0, 
		{"position":start_pos, "start_pos":start_pos, "direction":direction, "arriving":arriving})
	var _floor_tiles = get_tree().get_nodes_in_group("FloorLayer")
	if _floor_tiles.size() > 0:
		for t in _floor_tiles:
			if t != floor_tiles:
				floor_tiles = t
				break
	else:
		floor_tiles = null
	

func open_load_game_menu():
	load_game()
	
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
	ObjectSerializer.register_script("Save", Save)
	ObjectSerializer.register_script("Player", Player)
	
	_save.current_scene = "01-01"
	_save.current_scene_path = "res://Dungeons/01/01-01.tscn"
	_player.total_life = 3
	_player.life = _player.total_life
	_player.position = Vector2()
	_player.inventory = {
		Collectible.SCROLL_FRAGMENT : [], 
		Collectible.TREASURE : int(0),
		Collectible.TALONS: int(0), 
		Collectible.GOLDEN_DAGGER : int(0)
		}
	_save.player = _player

	current_scene = load("res://UI/WelcomeMenu.tscn").instantiate()
	init_player()
	
	pause_menu.save_button.pressed.connect(save_game)
	pause_menu.load_button.pressed.connect(load_game)
	pause_menu.continue_button.pressed.connect(close_menu_sound.play)
	
	Dialogue.prompt_player.connect(_prompt_player)
	Dialogue.open_document.connect(_open_document)
	Dialogue.open_dialogue.connect(_open_dialogue)
	Dialogue.notify_player.connect(_notify_player)
	
	canvas.add_child(current_scene)
	current_scene.loadgame_button.pressed.connect(open_load_game_menu)
	
	Collectible.item_collected.connect(hud.on_item_collected)
	Collectible.item_collected.connect(Collectible.on_item_collected)
	SceneTransition.scene_changed.connect(on_scene_changed)
	SceneTransition.won.connect(on_won)
	get_tree().paused = true
	update_music()

func load_from_file(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var content = file.get_as_text()
	return content

func save_game():
	_save.player.total_life = player.total_life
	_save.player.life = player.life
	_save.player.temporary_life = player.temporary_life
	_save.player.position = player.global_position
	_save.current_scene = SceneTransition.current_scene_name
	_save.current_scene_path = SceneTransition.current_scene_path
	_save.player.inventory = player.inventory
	_save.rooms[SceneTransition.current_scene_name] = get_room_save_info(current_scene)
	_save.completed_tutorial_prompts = Collectible.get_completed_tutorial_prompts()
	var game_save_string = DictionarySerializer.serialize_json(_save)
	var file = FileAccess.open("user://save.da", FileAccess.WRITE)
	file.store_string(game_save_string)
	file.close()
	
func load_game():
	var file = FileAccess.open("user://save.da", FileAccess.READ)
	_save = null
	_save = DictionarySerializer.deserialize_json(file.get_as_text())
	_player = _save.player
	init_player()
	player.life = _player.life
	player.total_life = _player.total_life
	player.temporary_life = _player.temporary_life
	hud.lifebar.temporary_life = _player.temporary_life
	hud.lifebar.life = _player.life
	player.global_position = _player.position
	player.inventory = _player.inventory
	hud.lifebar.set_life_total(player.total_life, player.total_life+player.temporary_life)
	hud.set_treasure(player.inventory[Collectible.TREASURE])
	Collectible.load_collected_scroll_fragments(_player.inventory[Collectible.SCROLL_FRAGMENT])
	Collectible.load_completed_tutorial_prompts(_save.completed_tutorial_prompts)
	SceneTransition.change_scene(_save.current_scene_path, player.global_position)
	file.close()

func open_inventory():
	var inventory = load("res://UI/InventoryMenu.tscn").instantiate()
	inventory.top_level = true
	$CanvasLayer.add_child(inventory)
	inventory.open(player.inventory)
	inventory.inventory_action_chosen.connect(player.on_inventory_action_chosen)
	
func _process(_delta):
	if player:
		if (not player.in_cutscene) and (not player.in_dialogue):
			if floor_tiles:
				player.update_step_sound(floor_tiles)
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

		
	
