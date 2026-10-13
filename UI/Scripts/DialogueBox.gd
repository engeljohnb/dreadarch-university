extends Control
@onready var tex : TextureRect = $TextureRect
@onready var indicator : AnimatedSprite2D = $Indicator
@onready var portrait : TextureRect = $Portrait
@onready var label : RichTextLabel = $RichTextLabel

var reveal_sounds = ["res://Assets/Sounds/UI/RevealDialogueSound1.ogg", "res://Assets/Sounds/UI/RevealDialogueSound2.ogg", "res://Assets/Sounds/RevealDialogueSound3.ogg"]
var portraits = {"Player" : load("res://Assets/Student/DialoguePortrait.png"),
				"Fitzroy" : load("res://Assets/NPCs/PrivateFitzroy/Portrait.png"),
				"Aelia" : load("res://Assets/NPCs/Aelia/Portrait.png"),
				"Aurelia" : load("res://Assets/NPCs/Aurelia/Portrait.png"),
				"Atticus" : load("res://Assets/NPCs/Atticus/portrait.png"),
				"Katrina" : load("res://Assets/NPCs/Katrina/portrait.png")
				}
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
var _offset_bottom = 0.0
var _starting_bottom = 0.0

func _ready():
	character_display_duration = 1.0/characters_per_second
	indicator.visible = false
	portrait.visible = false
	_anchor_right = tex.anchor_right
	_anchor_bottom = tex.anchor_bottom
	_starting_bottom = -180.0
	_offset_bottom = 1610.0
	tex.offset_bottom = _starting_bottom
	label.text = ""
	
	
func display_next():
	display_timer = 0
	displaying = true
	label.visible_characters = 0
	if current_index > dialogue.size()-1:
		closing = true
		return
	if current_index == dialogue.size()-1:
		indicator.play("End")
	else:
		indicator.play("Proceed")
	label.text = dialogue[current_index]["text"]
	Dialogue.current_box = dialogue[current_index]
	portrait.texture = portraits[dialogue[current_index]["speaker"]]
	current_index += 1
	var filename = reveal_sounds[randi()%2]
	$DialogueRevealSound.stream = load(filename)
	$DialogueRevealSound.play()
	
func all_characters_shown():
	return label.visible_characters >= label.text.length()
func end():
	Dialogue.dialogue_ended.emit()
	queue_free()
func _process(_delta):
	if opening:
		opening_timer += _delta
		tex.offset_bottom = Utils.padink(opening_timer,opening_duration,0.8, 1.2,1.3,_starting_bottom,_offset_bottom)
		if opening_timer >= opening_duration:
			opening_timer = 0.0
			opening = false
			indicator.visible = true
			portrait.visible = true
			display_next()
		return
	if closing:
		portrait.visible = false
		indicator.visible = false
		label.visible = false
		opening_timer += _delta
		anchor_top = lerp(anchor_top, anchor_bottom, (opening_timer/opening_duration))
		anchor_right = lerp(_anchor_right, anchor_left+0.75, (opening_timer/opening_duration))
		if opening_timer >= closing_duration:
			end()
	if Input.is_action_just_released("ui_accept"):
		if displaying:
			label.visible_characters = -1
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
			label.visible_characters += 1
		if all_characters_shown():
			$DialogueRevealSound.stop()
			label.visible_characters = -1
			displaying = false
			display_timer = 0.0
		
