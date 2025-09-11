extends Control

@onready var newgame_button = $NewGame
@onready var loadgame_button = $LoadGame
@onready var quit_button = $Quit
@onready var lamplight = $LampLight
@onready var menu_select_sound = $MenuSelectSound
var total_energy = 0.0
var fade_duration = 0.5
var fade_timer = 0.0
var fading = true

func on_new_game():
	SceneTransition.change_scene("Dungeons/01/01-01.tscn")
	
func on_quit():
	get_tree().quit()

func _ready():
	newgame_button.grab_focus()
	newgame_button.pressed.connect(on_new_game)
	quit_button.pressed.connect(on_quit)
	total_energy = lamplight.energy
	newgame_button.focus_exited.connect(menu_select_sound.play)
	loadgame_button.focus_exited.connect(menu_select_sound.play)
	quit_button.focus_exited.connect(menu_select_sound.play)

func _process(_delta):		
	if fading:
		fade_timer += _delta
		var fade_percent = fade_timer/fade_duration
		lamplight.energy = total_energy*fade_percent
		if (fade_timer >= fade_duration) or Input.is_action_just_pressed("ui_accept")  or Input.is_action_just_pressed("Pause"):
			fading = false
			fade_timer = 0.0
			fade_duration = 0.0
			lamplight.energy = total_energy
		

	
