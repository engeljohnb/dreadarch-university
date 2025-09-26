extends Control

func close_prompt():
	get_tree().paused = false
	queue_free()
	
func _ready():
	$TextureRect/Yes.pressed.connect(close_prompt)
	$TextureRect/No.pressed.connect(close_prompt)
	get_tree().paused = true
	$TextureRect/Yes.grab_focus()
	
func prompt(text, yes_callback : Callable, no_callback : Callable, yes = "yes", no = "no"):
	$TextureRect/RichTextLabel.text = text
	$TextureRect/Yes.text = yes
	$TextureRect/No.text = no
	$TextureRect/Yes.pressed.connect(yes_callback)
	$TextureRect/No.pressed.connect(no_callback)
	visible = true
