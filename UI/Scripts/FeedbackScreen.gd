extends Control
@export var music = "res://Music/DungeonMusic.ogg"
@export var music_volume = 0.0

func on_back():
	var welcome = load("UI/WelcomeMenu.tscn").instantiate()
	welcome.fading = false
	welcome.fade_timer = welcome.fade_duration
	add_sibling(welcome)
	welcome.newgame_button.grab_focus()
	var game_node = get_parent().get_parent()
	game_node.current_scene = welcome
	welcome.loadgame_button.pressed.connect(game_node.load_game)
	queue_free()
	
func _ready():
	$Back.pressed.connect(on_back)
	$Back.grab_focus()
