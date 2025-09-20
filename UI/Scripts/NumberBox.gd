extends Control

var timer = 0.0
var duration = 0.15
var mod_color = Color(1,1,1,0.5)
var _max = 0

func on_up():
	$RichTextLabel/UpButton.modulate = mod_color
	$RichTextLabel.text = str(int($RichTextLabel.text)+1)
	if _max > 0:
		if int($RichTextLabel.text) > _max:
			$RichTextLabel.text = str(_max)
	
func on_down():
	$RichTextLabel/DownButton.modulate = mod_color
	$RichTextLabel.text = str(int($RichTextLabel.text)-1)
	if int($RichTextLabel.text) < 0:
		$RichTextLabel.text = "0"

func _process(_delta):
	if visible:
		if Input.is_action_just_pressed("Up"):
			on_up()
		if Input.is_action_just_pressed("Down"):
			on_down()
		if Input.is_action_pressed("Up"):
			timer += _delta
			if timer >= duration:
				on_up()
				timer = 0.0
		if Input.is_action_pressed("Down"):
			timer += _delta
			if timer >= duration:
				on_down()
				timer = 0.0
		if Input.is_action_just_released("Down"):
			timer = 0.0
			$RichTextLabel/DownButton.modulate = Color(0,0,0,1)
		if Input.is_action_just_released("Up"):
			timer = 0.0
			$RichTextLabel/UpButton.modulate = Color(0,0,0,1)
