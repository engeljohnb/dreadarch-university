extends Door

func activate(_using_item = null, _count = 0):
	player = get_tree().get_first_node_in_group("Player")
	if player.in_cutscene:
		return
	if player.get_crosshair_distance() > player.FIXED_CROSSHAIR_DISTANCE:
		var seq : EventSequence = EventSequence.new()
		var duration = player.global_position.distance_to(global_position) / player.SPEED
		var target_position = global_position + Vector2(0, -$CollisionShape2D.shape.size.y/2.0)
		seq.add_walk_event(target_position, duration)
		seq.ended.connect(start_transition)
		add_child(seq)
		seq.start_events()
		
func start_transition(_pos : Vector2 = global_position):
	player_entered = true
	player = get_tree().get_first_node_in_group("Player")
	player_entered = true
	player.play_climb_cutscene(0.0, 
		{"direction":"Down", "position":global_position, "start_pos":player.global_position, "arriving":false})
		

func on_body_entered(body):
	if body.is_in_group("Player"):
		if not body.in_cutscene:
			start_transition()
		
func _ready():
	body_entered.connect(on_body_entered)

func _process(_delta):
	if player_entered:
		# Apparently calling this function right from on_body_entered breaks everything
		if not player.in_cutscene:
			SceneTransition.enter_scene(next_scene, next_start_position, false, false, true, "Down")
