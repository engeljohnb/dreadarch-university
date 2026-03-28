extends Control

@onready var newgame_button = $NewGame
@onready var loadgame_button = $LoadGame
@onready var quit_button = $Quit
@onready var menu_select_sound = $MenuSelectSound
@export var music = "res://Music/DeathMusic.ogg"
	
func on_quit():
	get_tree().quit()

func _ready():
	newgame_button.grab_focus()
	quit_button.pressed.connect(on_quit)
	newgame_button.focus_exited.connect(menu_select_sound.play)
	loadgame_button.focus_exited.connect(menu_select_sound.play)
	quit_button.focus_exited.connect(menu_select_sound.play)

func hide_button(button):
	button.visible = false
	button.disabled = true
	button.focus_mode = FocusMode.FOCUS_NONE
	
func show_button(button):
	button.visible = true
	button.disabled = false
	button.focus_mode = FocusMode.FOCUS_ALL
	
func hide_all():
	hide_button(newgame_button)
	hide_button(loadgame_button)
	hide_button(quit_button)
	
func show_all():
	show_button(newgame_button)
	show_button(loadgame_button)
	hide_button(quit_button)
	newgame_button.grab_focus()
