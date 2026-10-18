extends Door
var timer = 0.0
var safe_to_climb = false

func activate(_using_item = null, _count = 0):
	player = get_tree().get_first_node_in_group("Player")
	if player.in_cutscene:
		return
	if player.get_crosshair_distance() > player.FIXED_CROSSHAIR_DISTANCE:
		var seq : EventSequence = EventSequence.new()
		var duration = player.global_position.distance_to(global_position) / player.SPEED
		seq.add_walk_event(global_position, duration)
		seq.ended.connect(start_transition)
		add_child(seq)
		seq.start_events()
		
func start_transition(_pos : Vector2 = global_position):
	player_entered = true
	player = get_tree().get_first_node_in_group("Player")
	var _direction = "Up"
	var arriving = false
	var _position = global_position
	var start_pos = player.global_position
	player.play_climb_cutscene(0.0,
		{"direction":_direction, "arriving":arriving,"position":_position,"start_pos":start_pos})
		
func on_body_entered(body):
	if not safe_to_climb:
		return
	if body.is_in_group("Player"):
		if not body.in_cutscene:
			start_transition()
func _ready():
	body_entered.connect(on_body_entered)

func _process(_delta):
	#This is because the player may collide with the ladder before the player's position is update,
	# Causing the player to immediately climb no matter where the start position is supposed to be
	if not safe_to_climb:
		timer += _delta
		if timer >= 0.25:
			safe_to_climb = true
	if player_entered:
		# Apparently calling this function right from on_body_entered breaks everything
		if not player.in_cutscene:
			SceneTransition.enter_scene(next_scene, next_start_position, false, false, true, "Up")
