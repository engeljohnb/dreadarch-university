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
	var total_life: int
	# Guess it has to be a dictionary bc for some reason the JSON serializer can do Class.Class, but not Class.Class.Class
	var inventory: Dictionary
class Save:
	var current_scene: String
	var player: Player
	
var current_scene = null
var current_music = null
var death_cutscene = {"timer":0.0}
var player = null
var _save = Save.new()
var _player = Player.new()

func _prompt_player(text, on_yes, on_no, yes_text = "yes", no_text = "no"):
	var prompt = load("res://UI/Prompt.tscn").instantiate()
	prompt.prompt(text, on_yes, on_no, yes_text, no_text)
	$CanvasLayer.add_child(prompt)

func _open_document():
	var viewer = load("res://UI/DocumentViewer.tscn").instantiate()
	$CanvasLayer.add_child(viewer)

func on_dialogue_ended():
	player.in_dialogue = false
	
func _open_dialogue(dialogue):
	var box = load("res://UI/DialogueBox.tscn").instantiate()
	if "dialogue" in box:
		box.dialogue = dialogue
	else:
		print("Wtf??????")
	box.dialogue_ended.connect(on_dialogue_ended)
	$CanvasLayer.add_child(box)
	player.in_dialogue = true
	
func init_player():
	if player:
		player.queue_free()
	player = load("res://Characters/Player/Player.tscn").instantiate()
	player.lost_life.connect(on_player_lost_life)
	player.gained_life.connect(on_player_gain_life)
	player.died.connect(on_player_dead)
	player.z_index = 0
	hud.lifebar.set_life_total(player.total_life, player.life)
	hud.visible = true

func end_gameplay():
	hud.visible = false
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
		hud.visible = false
	else:
		if player.sprite.animation != "Death":
			player.sprite.play("Death")
		if player.sprite.frame <= 11:
			$Fade.modulate.a = (timer/fade_time)
		if player.sprite.frame > 19:
			player.modulate.a = 1.7 - (timer/(fade_time+1))
		if player.modulate.a <= 0.0:
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
			
func on_scene_changed():
	current_scene.queue_free()
	current_scene = load(SceneTransition.current_scene_name).instantiate()
	current_scene.process_mode = PROCESS_MODE_PAUSABLE
	if (not player):
		init_player()
	player.y_sort_enabled = true
	player.z_index = 0
	if player.get_parent():
		player.reparent(current_scene)
	else:
		current_scene.add_child(player)
		update_music()
	hud.lifebar.set_life_total(player.total_life, player.life)
	add_child(current_scene)
	get_tree().paused = false
	pause_menu.visible = false
	player.global_position = SceneTransition.player_start_position
	if SceneTransition.by_door:
		player.modulate.a = 0.0
		player.play_door_cutscene(0.0, SceneTransition.player_start_position, true)
	
func open_load_game_menu():
	load_game()
	
func on_won():
	player.play_victory_cutscene(0.0)

func init_wm_settings():
	var screen_size = DisplayServer.window_get_size()
	get_window().size = screen_size
	ProjectSettings.set_setting("display/window/size/mode", DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)

func on_scroll_fragment_collected():
	player.inventory.scroll_fragments.append(Collectible.most_recent_scroll_fragment)
	
func _ready():
	seed(1)
	init_wm_settings()
	ObjectSerializer.register_script("Save", Save)
	ObjectSerializer.register_script("Player", Player)
	
	_save.current_scene = "res://test.tscn"
	_player.total_life = 3
	_player.life = _player.total_life
	_player.position = Vector2()
	_player.inventory = {"scroll_fragments" : []}
	_save.player = _player

	current_scene = load("res://UI/WelcomeMenu.tscn").instantiate()
	init_player()
	
	pause_menu.save_button.pressed.connect(save_game)
	pause_menu.load_button.pressed.connect(load_game)
	pause_menu.continue_button.pressed.connect(close_menu_sound.play)
	
	Dialogue.prompt_player.connect(_prompt_player)
	Dialogue.open_document.connect(_open_document)
	Dialogue.open_dialogue.connect(_open_dialogue)
	Collectible.scroll_fragment_collected.connect(on_scroll_fragment_collected)
	canvas.add_child(current_scene)
	current_scene.loadgame_button.pressed.connect(open_load_game_menu)
	
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
	_save.player.position = player.global_position
	_save.current_scene = SceneTransition.current_scene_name
	_save.player.inventory["scroll_fragments"] = player.inventory.scroll_fragments
	var game_save_string = DictionarySerializer.serialize_json(_save)
	var file = FileAccess.open("user://save.da", FileAccess.WRITE)
	file.store_string(game_save_string)
	file.close()
	
func load_game():
	var file = FileAccess.open("user://save.da", FileAccess.READ)
	_save = DictionarySerializer.deserialize_json(file.get_as_text())
	_player = _save.player
	init_player()
	player.life = _player.life
	player.total_life = _player.total_life
	player.global_position = _player.position
	player.inventory.scroll_fragments = _player.inventory["scroll_fragments"]
	hud.lifebar.set_life_total(player.total_life, player.life)
	Collectible.load_collected_scroll_fragments(_player.inventory.scroll_fragments)
	SceneTransition.change_scene(_save.current_scene, player.global_position)
	file.close()
	
func _process(_delta):
	if Input.is_action_just_pressed("Pause") and not (get_tree().paused):
		pause_menu.pause_game()
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

		
	
