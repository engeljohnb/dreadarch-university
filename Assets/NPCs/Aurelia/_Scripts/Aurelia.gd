extends NPC

@onready var fx : Sprite2D = $VisualStationary/FX
@onready var sprite : AnimatedSprite2D = $VisualStationary/AnimatedSprite2D
@onready var visual_travel : Node2D = $VisualTravel
@onready var visual_stationary : Node2D = $VisualStationary
var is_open = false
var _opening : bool = false
var _open_duration : float = 0.75 
var _timer : float = 0.0

var intro_dialogue : Array[Dictionary] = [
	{
		"speaker":"Aurelia",
		"text":"Quid mandatum ducit te hac?"
	},
	{
		"speaker":"Aurelia",
		"text":"Discede statim."
	}
]

func _ready():
	sprite.play("Idle")
	interaction_message = "Z to examine"
	visual_travel.travel_ended.connect(_on_travel_ended)
	
func _on_travel_ended():
	visual_stationary.visible = true
	open()
	
func _process(delta):
	if _opening:
		if _timer >= _open_duration:
			_opening = false
			is_open = true
			interaction_message = "Z to talk"
			start_dialogue(intro_dialogue)
		else:
			var spotlight_size = Utils.padink(_timer, _open_duration, 0.75, 1.1, 1.2, 0.0, 0.63)
			fx.material.set_shader_parameter("spotlight_size", spotlight_size)
			_timer += delta
	if Dialogue.dialogue_open():
		sprite.play("Speak")
	else:
		sprite.play("Idle")
		
func start_dialogue(dialogue : Array[Dictionary]):
	Dialogue.open_dialogue.emit(dialogue)
	
func open():
	_opening = true

func activate(_using_item : Variant = null, _count = 1):
	open()
