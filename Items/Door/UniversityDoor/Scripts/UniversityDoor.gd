extends Door
#TODO: Make it so the player can't walk through walls to get to the door.
func activate(_using_item = null, _count = 0):
	player = get_tree().get_first_node_in_group("Player")
	var seq : EventSequence = EventSequence.new()
	seq.add_walk_event(global_position, Utils.get_walk_duration(global_position))
	seq.ended.connect(start_transition.bind(global_position - Vector2(0,64)))
	add_child(seq)
	seq.start_events()
	
func on_body_entered(body):
	if body.is_in_group("Player"):
		if not body.in_cutscene:
			player = body
			start_transition(global_position - Vector2(0,64))
		$AnimatedSprite2D.frame = 1
		
func on_body_exited(body):
	if body.is_in_group("Player"):
		$AnimatedSprite2D.frame = 0
		
func _ready():
	match direction:
		"Up":
			$AnimatedSprite2D.frame = 1
		"":
			$AnimatedSprite2D.frame = 0
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func _process(_delta):
	if player_entered:
		# Apparently calling this function right from on_body_entered breaks everything
		if not player.in_cutscene:
			SceneTransition.enter_scene(next_scene, next_start_position, true)
