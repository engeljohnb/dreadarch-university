extends Control

@onready var newgame_button = $NewGame
@onready var quit_button = $Quit
@onready var menu_select_sound = $MenuSelectSound

func on_quit():
	get_tree().quit()
	
func on_new_game():
	SceneTransition.change_scene("Dungeons/01/01-01.tscn")
	
func _ready():
	get_tree().paused = true
	newgame_button.grab_focus()
	newgame_button.pressed.connect(on_new_game)
	quit_button.pressed.connect(on_quit)
	newgame_button.focus_exited.connect(menu_select_sound.play)
	quit_button.focus_exited.connect(menu_select_sound.play)
