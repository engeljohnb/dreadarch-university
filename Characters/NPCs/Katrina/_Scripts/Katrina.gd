extends NPC
enum Actions {
	SWEEP,
	STEP,
	HUG
}

@onready var sprite = $AnimatedSprite2D
var waiting_for_hug := false
var current_action : Actions = Actions.SWEEP
var sweep_duration = (1.0/12.0)*8.0
var step_duration = (1.0/12.0)*8.0
var num_sweeps = (randi() % 10) + 5
var action_duration = 0.0
var action_timer = 0.0 
var speed = 10.0
var introduced = false
var in_cutscene = false
var default_dialogue = [
	{
		"speaker":"Katrina",
		"text":"Have a good day."
	}
]
var intro_dialogue = [
	{
		"speaker":"Katrina",
		"text":"Is that how you're dressing for class?"
	},
	{
		"speaker":"Player",
		"text":"I'm helping Professor with the excavation."
	},
	{
		"speaker":"Katrina",
		"text":"Strange. I thought that was all shut down."
	},
	{
		"speaker":"Katrina",
		"text":"Well, don't try to leave without this."
	}
]
func should_hide_player():
	return (action_timer >= (1.0/12.0) * 10.0) and (action_timer <= (1.0/12.0) * 22.0)
	
func should_show_player():
	return action_timer >= (1.0/12.0) * 22.0
	
func play_hug_cutscene(_delta : float):
	in_cutscene = true
	var player = get_tree().get_first_node_in_group("Player")
	if _delta == 0.0:
		current_action = Actions.HUG
		action_duration = (1.0/12.0) * 32.0
		action_timer = 0.0
		sprite.play("Hug")
	if should_show_player():
		player.sprite.visible = true
	elif should_hide_player():
		player.sprite.visible = false
	if action_timer >= (1.0/12.0) * 32.0:
		player.sprite.visible = true
			
func activate(_using_item = null, _count = 0):
	if not introduced:
		var seq : EventSequence = EventSequence.new()
		seq.add_dialogue_event(intro_dialogue)
		var player = get_tree().get_first_node_in_group("Player")
		var duration = global_position.distance_to(player.global_position) / player.SPEED
		seq.add_walk_event(global_position + Vector2(22,30), duration)
		seq.add_cutscene_event("play_hug_cutscene", self)
		add_child(seq)
		seq.start_events()
		introduced = true
	else:
		Dialogue.open_dialogue.emit(default_dialogue)

func _ready():
	action_duration = float(num_sweeps) * sweep_duration
	sprite.play("Sweep")
	
func switch_action():
	action_timer = 0.0
	if in_cutscene:
		in_cutscene = false
	if current_action == Actions.SWEEP:
		current_action = Actions.STEP
		action_duration = step_duration
		sprite.play("Step")
	else:
		current_action = Actions.SWEEP
		num_sweeps = (randi() % 10) + 5
		action_duration = sweep_duration * float(num_sweeps)
		sprite.play("Sweep")
		
func _process(_delta):
	if in_cutscene:
		play_hug_cutscene(_delta)
	action_timer += _delta
	if action_timer >= action_duration:
		switch_action()
	if current_action == Actions.STEP:
		position.x += speed * _delta
	
