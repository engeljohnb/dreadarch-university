extends NPC

@onready var fx : Sprite2D = $Visual/FX
@onready var sprite : AnimatedSprite2D = $Visual/AnimatedSprite2D
var is_open = false
var _opening : bool = false
var _open_duration : float = 1.33
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
	
func _process(delta):
	if _opening:
		if _timer >= _open_duration:
			_opening = false
			is_open = true
			interaction_message = "Z to talk"
			start_dialogue(intro_dialogue)
		else:
			#var spotlight_size = lerp(0.0, 0.7, (_timer/_open_duration))
			var spotlight_size = Utils.padink(_timer, _open_duration, 0.75, 1.2, 1.3, 0.0, 0.7)
			fx.material.set_shader_parameter("spotlight_size", spotlight_size)
			_timer += delta
	if Dialogue.dialogue_open():
		sprite.play("Speak")
	else:
		sprite.play("Idle")
		
func start_dialogue(dialogue : Array[Dictionary]):
	Dialogue.open_dialogue.emit(intro_dialogue)
	
func open():
	_opening = true

func activate(_using_item : Variant = null, _count = 1):
	open()
