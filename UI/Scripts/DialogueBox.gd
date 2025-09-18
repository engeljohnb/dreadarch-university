extends Control

signal dialogue_ended()

var reveal_sounds = ["res://Assets/Sounds/UI/RevealDialogueSound1.ogg", "res://Assets/Sounds/UI/RevealDialogueSound2.ogg", "res://Assets/Sounds/RevealDialogueSound3.ogg"]
var portraits = {"Player" : "res://Assets/Student/DialoguePortrait.png"}
var dialogue : Array = []
var current_index = 0
var displaying = false
var characters_per_second = 32
var display_timer = 0.0
var character_display_duration = 0.0
var opening = true
var closing = false
var opening_timer = 0.0
var opening_duration = 0.33
var closing_duration = 0.24
var _anchor_bottom = 0.0
var _anchor_right = 0.0

func _ready():
	character_display_duration = 1.0/characters_per_second
	$TextureRect/Indicator.visible = false
	$TextureRect/Portrait.visible = false
	_anchor_right = anchor_right
	_anchor_bottom = anchor_bottom
	anchor_bottom = anchor_top
	anchor_right = anchor_left
	
func display_next():
	display_timer = 0
	displaying = true
	$TextureRect/RichTextLabel.visible_characters = 0
	if current_index > dialogue.size()-1:
		dialogue_ended.emit()
		closing = true
		return
	if current_index == dialogue.size()-1:
		$TextureRect/Indicator.play("End")
	else:
		$TextureRect/Indicator.play("Proceed")
	$TextureRect/RichTextLabel.text = dialogue[current_index]["text"]
	$TextureRect/Portrait.texture = load(portraits[dialogue[current_index]["speaker"]])
	current_index += 1
	var filename = reveal_sounds[randi()%2]
	$DialogueRevealSound.stream = load(filename)
	$DialogueRevealSound.play()
	
func all_characters_shown():
	return $TextureRect/RichTextLabel.visible_characters >= $TextureRect/RichTextLabel.text.length()
	
func _process(_delta):
	if opening:
		opening_timer += _delta
		anchor_bottom = lerp(anchor_top+0.7, _anchor_bottom+0.2, (opening_timer/opening_duration))
		anchor_right = lerp(anchor_left+0.7, _anchor_right+0.2, (opening_timer/opening_duration))
		if anchor_bottom >= _anchor_bottom:
			anchor_bottom = lerp(anchor_bottom, _anchor_bottom, (opening_timer/opening_duration))
			anchor_right = lerp(anchor_right, _anchor_right, (opening_timer/opening_duration))
		if opening_timer >= opening_duration:
			opening_timer = 0.0
			anchor_right = _anchor_right
			anchor_bottom = _anchor_bottom
			opening = false
			$TextureRect/Indicator.visible = true
			$TextureRect/Portrait.visible = true
			display_next()
		return
	if closing:
		$TextureRect/Portrait.visible = false
		$TextureRect/Indicator.visible = false
		$TextureRect/RichTextLabel.visible = false
		opening_timer += _delta
		anchor_bottom = lerp(_anchor_bottom, anchor_top+0.6, (opening_timer/opening_duration))
		anchor_top = lerp(anchor_top, anchor_bottom, (opening_timer/opening_duration))
		anchor_right = lerp(_anchor_right, anchor_left+0.75, (opening_timer/opening_duration))
		if opening_timer >= closing_duration:
			queue_free()
	if Input.is_action_just_released("ui_accept"):
		if displaying:
			$TextureRect/RichTextLabel.visible_characters = -1
			$DialogueRevealSound.stop()
			$DialogueSkipSound.play()
			displaying = false
		else:
			display_next()
		return
	if displaying:
		display_timer += _delta
		if display_timer >= character_display_duration:
			display_timer = 0.0
			$TextureRect/RichTextLabel.visible_characters += 1
		if all_characters_shown():
			$DialogueRevealSound.stop()
			$TextureRect/RichTextLabel.visible_characters = -1
			displaying = false
			display_timer = 0.0
		
