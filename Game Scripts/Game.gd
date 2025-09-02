extends Node2D

@onready var hud = $CanvasLayer/HUD
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var canvas = $CanvasLayer

class Player:
	var position: Vector2
	var life: int
	var total_life: int
class Save:
	var current_scene: String
	var player: Player
	
var current_scene = null
var player = null
var _save = Save.new()
var _player = Player.new()

func init_player():
	player = load("res://Characters/Player/Player.tscn").instantiate()
	player.lost_life.connect(on_player_lost_life)
	player.gained_life.connect(on_player_gain_life)
	player.dead.connect(on_player_dead)
	hud.lifebar.set_life_total(player.total_life, player.life)

func end_gameplay():
	player = current_scene.get_node("Player")
	if (player.get_node_or_null("PlayerAttackFX")):
		player.get_node("PlayerAttackFX").queue_free()
	player.queue_free()
	current_scene.queue_free()

func on_player_lost_life(damage):
	hud.lifebar.deduct_damage(damage)
	
func on_player_gain_life(life):
	hud.lifebar.gain_life(life)

func on_player_dead():
	end_gameplay()
	current_scene = load("res://UI/DeathMenu.tscn").instantiate()
	current_scene.z_index = 3
	canvas.add_child(current_scene)
	current_scene.loadgame_button.pressed.connect(open_load_game_menu)
	get_tree().paused = true
	
func on_scene_changed():
	current_scene.queue_free()
	current_scene = load(SceneTransition.current_scene_name).instantiate()
	current_scene.process_mode = PROCESS_MODE_PAUSABLE
	if (not player):
		init_player()
	if player.get_parent():
		player.reparent(current_scene)
	else:
		current_scene.add_child(player)
	player.global_position = SceneTransition.player_start_pos
	hud.lifebar.set_life_total(player.total_life, player.life)
	add_child(current_scene)
	get_tree().paused = false
	pause_menu.visible = false
	
func open_load_game_menu():
	load_game()
	
func on_won():
	end_gameplay()
	current_scene = load("res://UI/VictoryMenu.tscn").instantiate()
	current_scene.z_index = 3
	canvas.add_child(current_scene)
	get_tree().paused = true

func init_wm_settings():
	var screen_size = DisplayServer.window_get_size()
	get_window().size = screen_size
	ProjectSettings.set_setting("display/window/size/mode", DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)
	
	
func _ready():
	init_wm_settings()
	ObjectSerializer.register_script("Save", Save)
	ObjectSerializer.register_script("Player", Player)
	
	_save.current_scene = "res://test.tscn"
	_player.total_life = 3
	_player.life = _player.total_life
	_player.position = Vector2()
	_save.player = _player
	
	current_scene = load("res://UI/WelcomeMenu.tscn").instantiate()
	init_player()
	
	pause_menu.save_button.pressed.connect(save_game)
	pause_menu.load_button.pressed.connect(load_game)
	
	canvas.add_child(current_scene)
	current_scene.loadgame_button.pressed.connect(open_load_game_menu)
	
	SceneTransition.scene_changed.connect(on_scene_changed)
	SceneTransition.won.connect(on_won)
	get_tree().paused = true

func load_from_file(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var content = file.get_as_text()
	return content

func save_game():
	_save.player.total_life = player.total_life
	_save.player.life = player.life
	_save.player.position = player.global_position
	_save.current_scene = SceneTransition.current_scene_name
	var game_save_string = DictionarySerializer.serialize_json(_save)
	var file = FileAccess.open("user://save.da", FileAccess.WRITE)
	file.store_string(game_save_string)

func load_game():
	var file = FileAccess.open("user://save.da", FileAccess.READ)
	_save = DictionarySerializer.deserialize_json(file.get_as_text())
	_player = _save.player
	if (not player):
		init_player()
	player.life = _player.life
	player.total_life = _player.total_life
	player.global_position = _player.position
	hud.lifebar.set_life_total(player.total_life, player.life)
	SceneTransition.change_scene(_save.current_scene, player.global_position)
	
func _process(_delta):
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = true
		pause_menu.continue_button.grab_focus()
		pause_menu.visible = true
		
	
