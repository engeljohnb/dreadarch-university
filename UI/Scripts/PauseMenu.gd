extends Control

@onready var continue_button = $Continue
@onready var quit_button = $Quit
@onready var save_button = $Save
@onready var load_button = $Load
@onready var open_menu_sound = $OpenMenuSound
@onready var menu_select_sound = $MenuSelectSound
@onready var options_button = $Options
var is_open := false
var alt_menu_open := false
var last_focused_button : Button

func get_focused_button():
	var co = continue_button.has_focus()
	var sa = save_button.has_focus()
	var lo = load_button.has_focus()
	var qu = quit_button.has_focus()
	match true:
		co:
			return continue_button
		sa:
			return save_button
		lo:
			return load_button
		qu:
			return quit_button
	return continue_button
		
func hide_all():
	process_mode = Control.PROCESS_MODE_DISABLED
	last_focused_button = get_focused_button()
	continue_button.disabled = true
	continue_button.visible = false
	continue_button.focus_mode = FocusMode.FOCUS_NONE
	
	save_button.disabled = true
	save_button.visible = false
	save_button.focus_mode = FocusMode.FOCUS_NONE
	
	load_button.disabled = true
	load_button.visible = false
	load_button.focus_mode = FocusMode.FOCUS_NONE
	
	quit_button.disabled = true
	quit_button.visible = false
	quit_button.focus_mode = FocusMode.FOCUS_NONE
	
	options_button.disabled = true
	options_button.visible = false
	options_button.focus_mode = FocusMode.FOCUS_NONE
	
func show_all():
	process_mode = Control.PROCESS_MODE_WHEN_PAUSED
	continue_button.disabled = false
	continue_button.visible = true
	continue_button.focus_mode = FocusMode.FOCUS_ALL
	
	save_button.disabled = false
	save_button.visible = true
	save_button.focus_mode = FocusMode.FOCUS_ALL
	
	load_button.disabled = false
	load_button.visible = true
	load_button.focus_mode = FocusMode.FOCUS_ALL
	
	quit_button.disabled = false
	quit_button.visible = true
	quit_button.focus_mode = FocusMode.FOCUS_ALL
	
	options_button.disabled = false
	options_button.visible = true
	options_button.focus_mode = FocusMode.FOCUS_ALL
	if last_focused_button:
		last_focused_button.grab_focus()

func on_save_file_chosen(_filename):
	continue_callback()

func pause_game():
		is_open = true
		show_all()
		get_tree().paused = true
		continue_button.grab_focus()
		visible = true
		open_menu_sound.play()

func continue_callback():
	hide_all()
	is_open = false
	visible = false
	get_tree().paused = false

func quit_callback():
	get_tree().quit()
	
func on_focus_changed():
	# Menu is always here but not always visible, so sometimes 
	# another menu opening will grab the focus and play the sound
	# when I don't wan it to.
	if visible:
		if menu_select_sound.is_inside_tree():
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
	var on_alt_menu = func (): alt_menu_open = true
	load_button.pressed.connect(on_alt_menu)
	options_button.pressed.connect(on_alt_menu)
	hide_all()
		
func _process(_delta):
	if Input.is_action_just_pressed("UI Cancel"):
		if not alt_menu_open:
			continue_callback()
