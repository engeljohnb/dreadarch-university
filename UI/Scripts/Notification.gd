extends Control

var current_line = 0
var total_lines = 0
var _note = []
var safe_to_advance = false
var timer = 0.0

	
func _ready():
	get_tree().paused = true
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
		get_tree().paused = false
		queue_free()
		return
	if current_line == total_lines-1:
		$TextureRect/AnimatedSprite2D.play("End")
	for key in _note[current_line]:
		if key.contains("image"):
				var new_texture = adjust_texture(_note[current_line][key])
				$TextureRect/RichTextLabel.add_image(new_texture, 64, 64)
		if key.contains("text"):
				$TextureRect/RichTextLabel.add_text(_note[current_line][key])
	current_line += 1
		
func _process(_delta):
	if not safe_to_advance:
		timer += _delta
		if timer >= 0.2:
			get_tree().paused = true
			timer = 0.0
			safe_to_advance = true
		return
	else:
		if Input.is_action_just_released("ui_accept"):
			advance()
