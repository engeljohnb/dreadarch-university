extends Control

@onready var newgame_button = $NewGame
@onready var loadgame_button = $LoadGame
@onready var quit_button = $Quit
@onready var menu_select_sound = $MenuSelectSound

func on_new_game():
	SceneTransition.change_scene("Dungeons/01/01-01.tscn", Vector2(500,500))
	
func on_quit():
	get_tree().quit()

func _ready():
	newgame_button.grab_focus()
	newgame_button.pressed.connect(on_new_game)
	quit_button.pressed.connect(on_quit)
	newgame_button.focus_exited.connect(menu_select_sound.play)
	loadgame_button.focus_exited.connect(menu_select_sound.play)
	quit_button.focus_exited.connect(menu_select_sound.play)
