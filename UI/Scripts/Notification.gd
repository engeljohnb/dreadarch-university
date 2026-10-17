extends Control

var current_line = 0
var total_lines = 0
var _note = []
var safe_to_advance = false
var timer = 0.0

	
func _ready():
	get_tree().paused = true
	if not $TextureRect/RichTextLabel.bbcode_enabled:
		$TextureRect/RichTextLabel.bbcode_enabled = true
	visible = true
	top_level = true
	
func notify(note : Array):
	$TextureRect/RichTextLabel.text = ""
	total_lines = note.size()
	current_line = 0
	visible = true
	$TextureRect/AnimatedSprite2D.play("Proceed")
	_note = note
	advance()
	
func adjust_texture(texture : Texture2D):
	var image: Image = texture.get_image()
	for y in image.get_height():
		for x in image.get_width():
			var color = image.get_pixel(x, y)
			color = color*1.78
			image.set_pixel(x,y,color)
	var new_texture := ImageTexture.create_from_image(image)
	return new_texture
	
	
func advance():
	$TextureRect/RichTextLabel.clear()
	if current_line > (total_lines-1):
		Dialogue.dialogue_ended.emit()
		get_tree().paused = false
		queue_free()
		return
	if current_line == total_lines-1:
		$TextureRect/AnimatedSprite2D.play("End")
	for key in _note[current_line]:
		$TextureRect/RichTextLabel.text = _note[current_line]
	current_line += 1
		
func _process(_delta):
	timer += _delta
	if timer >= 0.2:
		if Input.is_action_just_released("UI Accept"):
			advance()
