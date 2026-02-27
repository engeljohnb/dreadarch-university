extends Control

@onready var continue_button = $Continue
@onready var quit_button = $Quit
@onready var save_button = $Save
@onready var load_button = $Load
@onready var open_menu_sound = $OpenMenuSound
@onready var menu_select_sound = $MenuSelectSound

func pause_game():
		get_tree().paused = true
		continue_button.grab_focus()
		visible = true
		open_menu_sound.play()
		# if player is above ground, turn down the light0.486
		if SceneTransition.current_scene_name.contains("00"):
			$LampLight.energy = 4.50
		else:
			$LampLight.energy = 10.0

func continue_callback():
	visible = false
	get_tree().paused = false

func quit_callback():
	get_tree().quit()
	
func on_focus_changed():
	# Menu is always here but not always visible, so sometimes 
	# another menu opening will grab the focus and play the sound
	# when I don't wan it to.
	if visible:
		menu_select_sound.play()
		
func _ready():
	visible = false
	continue_button.grab_focus()
	continue_button.pressed.connect(continue_callback)
	quit_button.pressed.connect(quit_callback)
	continue_button.focus_exited.connect(on_focus_changed)
	save_button.focus_exited.connect(on_focus_changed)
	load_button.focus_exited.connect(on_focus_changed)
	quit_button.focus_exited.connect(on_focus_changed)
	
