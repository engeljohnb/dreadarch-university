extends Control

@onready var newgame_button = $Buttons/NewGame
@onready var loadgame_button = $Buttons/LoadGame
@onready var quit_button = $Buttons/Quit
@onready var lamplight = $LampLight
@onready var menu_select_sound = $MenuSelectSound
@onready var feedback_button = $Buttons/Feedback
var total_energy = 0.0
var fade_duration = 1.0
var fade_timer = 0.0
var fading = true
@export var music_volume = 0.0
@export var music = "res://Music/IntroMusic.ogg"

func on_new_game():
	SceneTransition.change_scene("Dungeons/01/01-01.tscn")
	
func on_quit():
	get_tree().quit()

func on_feedback():
	var feedback_instance = load("res://UI/FeedbackScreen.tscn").instantiate()
	add_sibling(feedback_instance)
	queue_free()
	
func init_sounds():
	newgame_button.focus_exited.connect(menu_select_sound.play)
	loadgame_button.focus_exited.connect(menu_select_sound.play)
	quit_button.focus_exited.connect(menu_select_sound.play)
	
func _ready():
	newgame_button.pressed.connect(on_new_game)
	quit_button.pressed.connect(on_quit)
	total_energy = lamplight.energy
	feedback_button.pressed.connect(on_feedback)
	newgame_button.grab_focus()
	init_sounds()

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
