extends Control

@onready var continue_button = $Continue
@onready var quit_button = $Quit
@onready var save_button = $Save
@onready var load_button = $Load

func continue_callback():
	visible = false
	get_tree().paused = false

func quit_callback():
	get_tree().quit()

func _ready():
	visible = false
	continue_button.grab_focus()
	continue_button.pressed.connect(continue_callback)
	quit_button.pressed.connect(quit_callback)
