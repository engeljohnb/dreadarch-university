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
	player = get_tree().get_nodes_in_group("Player")[0]
	global_position = player.global_position
	ItemCollection.item_collected.connect(_on_item_collected)
	
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
			interaction_message = "Z to talk"
			waiting_for_player = true
		else:
			var spotlight_size = Utils.padink(_timer, _open_duration, 0.75, 1.1, 1.2, 0.0, 0.63)
			fx.material.set_shader_parameter("spotlight_size", spotlight_size)
			_timer += delta
	if waiting_for_player:
		if should_surprise_player():
			player.play_surprised_cutscene(0.0)
			waiting_for_player = false
	if Dialogue.dialogue_open():
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
	Dialogue.open_dialogue.emit(intro_dialogue)

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
