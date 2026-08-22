extends NPC

@onready var fx : Sprite2D = $VisualStationary/FX
@onready var sprite : AnimatedSprite2D = $VisualStationary/AnimatedSprite2D
@onready var visual_travel : Node2D = $VisualTravel
@onready var visual_stationary : Node2D = $VisualStationary
var is_open = false
var _opening : bool = false
var _open_duration : float = 0.75 
var _timer : float = 0.0
var player : CharacterBody2D
var stationary = false
var waiting_for_player = false
@export var following_player : bool = true

var intro_dialogue : Array[Dictionary] = [
	{
		"speaker":"Aurelia",
		"text":"Qui es? Quid agis? Noli timere."
	},
	{
		"speaker":"Player",
		"text":"D-Discipulum... sum..."
	},
	{
		"speaker":"Player",
		"text":"If only P-Professor were here..."
	},
	{
		"speaker":"Aurelia",
		"text":"Let it be as fortune would have it. Do not be afraid."
	},
	{
		"speaker":"Aurelia",
		"text":"Who are you? And what is it you do?"
	},
	{
		"speaker":"Player",
		"text":"I'm a student of archaeology, and what I'm doing is dreaming or becoming ill."
	},
	{
		"speaker":"Aurelia",
		"text":"This place is dangerous, but I am not. An abominable figure, but a human heart."
	},
	{
		"speaker":"Player",
		"text":"If you're nothing to fear, you could show it with a favor. Have you seen my Professor?"
	},
	{
		"speaker":"Player",
		"text":"She's tall and old, with light hair. She's been here for some weeks."
	},
	{
		"speaker":"Aurelia",
		"text":"Leave this room and go North."
	},
	{
		"speaker":"Aurelia",
		"text":"Please, take that weapon with you. You will not go far without it."
	}
]

var second_dialogue : Array[Dictionary] = [
	{
		"speaker":"Player",
		"text":"What are you?",
	},
	{
		"speaker":"Aurelia",
		"text":"I am old. I am cursed. I am betrayed."
	},
	{
		"speaker":"Aurelia",
		"text":"Most grievous of all, I am the Queen. But I will not hold you to courtly manners. You may call me Aurelia."
	},
	{
		"speaker":"Aurelia",
		"text":"When you have found whom you seek, come talk with me again. It has been long since I have talked with anyone."
	}
]

func _ready():
	sprite.play("Idle")
	visual_travel.travel_ended.connect(_on_travel_ended)
	player = get_tree().get_nodes_in_group("Player")[0]
	global_position = player.global_position
	ItemCollection.item_collected.connect(_on_item_collected)
	
func _is_speaking():
	return Dialogue.dialogue_open() and Dialogue.current_box.get("speaker") == "Aurelia"
	
func _process(delta):
	if not stationary:
		if Input.is_action_just_released("ui_text_delete"):
			following_player = false
		if following_player:
			follow_player(delta)
		else:
			go_to(Vector2(478.0, -474.0), 7.0)
			visual_travel.pulsate(delta)
	if _opening:
		if _timer >= _open_duration:
			_opening = false
			is_open = true
			waiting_for_player = true
		else:
			var spotlight_size = Utils.padink(_timer, _open_duration, 0.75, 1.1, 1.2, 0.0, 0.63)
			fx.material.set_shader_parameter("spotlight_size", spotlight_size)
			_timer += delta
	if waiting_for_player:
		if should_surprise_player():
			player.play_surprised_cutscene(0.0)
			waiting_for_player = false
	if _is_speaking():
		sprite.play("Speak")
	else:
		sprite.play("Idle")
	
func should_surprise_player():
	var distance_to_player = abs(global_position.y - player.global_position.y)
	return (player.facing == Vector2.UP) and (distance_to_player < 125.0) and is_open
	
func _on_item_collected(item, _count, _should_play_sound):
	if item == ItemCollection.GOLDEN_DAGGER:
		following_player = false
	
func _on_travel_ended():
	visual_stationary.visible = true
	open()
		
func start_dialogue(dialogue : Array[Dictionary]):
	Dialogue.open_dialogue.emit(dialogue)
	status["gone"] = true
	
func open():
	_opening = true

func activate(_using_item : Variant = null, _count = 1):
	if check_status("introduced"):
		if check_status("invited_return"):
			start_dialogue([second_dialogue[-1]])
		else:
			start_dialogue(second_dialogue)
			status["invited_return"] = true
	else:
		start_dialogue(intro_dialogue)
		status["introduced"] = true

var _position_weight := 0.01
func follow_player(delta : float):
	# This is here because if you load_game while in the room, the player may not 
	#  be initialized for some reason.
	if player == null:
		player = get_tree().get_nodes_in_group("Player")[0]
	var target_position = player.global_position - Vector2(0.0, -160.0) - (player.facing * 100.0)
	var weight = max(0.01, _position_weight + delta)
	global_position = lerp(global_position, target_position, weight)

var _go_to_timer := 0.0
var _starting_goto_position := Vector2()
func go_to(pos : Vector2, duration : float):
	if _go_to_timer >= duration:
		set_stationary(true)
		visual_travel.begin_transition()
		return
	if _go_to_timer == 0.0:
		_starting_goto_position = global_position
	var delta = get_process_delta_time()
	global_position = lerp(_starting_goto_position, pos, (_go_to_timer/duration))
	_go_to_timer += delta
	
func set_stationary(state : bool):
	if state:
		stationary = true
		$CollisionShape2D.disabled = false
	else:
		stationary = false
		$CollisionShape2D.disabled = true
