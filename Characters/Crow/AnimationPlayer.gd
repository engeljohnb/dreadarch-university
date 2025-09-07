extends AnimationPlayer

var current_action = ""
var idle_timer = 0.0
var aggro_animation_initiated = false

func set_animation_finished(callable):
	for connection in animation_finished.get_connections():
		animation_finished.disconnect(connection["callable"])
	animation_finished.connect(callable)

func disconnect_animation_finished():
	for connection in animation_finished.get_connections():
		animation_finished.disconnect(connection["callable"])

func vec_to_name(direction):
	var x = direction.x
	var y = direction.y
	if (abs(x) > abs(y)):
		if (x < 0):
			return "Left"
		else:
			return "Right"
	else:
		if (y < 0):
			return "Up"
		else:
			return "Down"

func on_attack_animation_finished(animation_name):
	var crow = get_parent()
	if animation_name.contains("Attack") and not animation_name.contains("Prepare"):
		crow.attacking = false
		current_action = ""
		for connection in animation_finished.get_connections():
			animation_finished.disconnect(connection["callable"])
		if not crow.moving:
			set_animation("Idle")
		else:
			set_animation("Walk")

func on_prepare_attack_animation_finished(animation_name):
	if animation_name.contains("Prepare Attack"):
		var new_animation_name = "Attack " + vec_to_name(get_parent().facing)
		play(new_animation_name)
		#animation_player.current_action = animation_name
		if not animation_finished.is_connected(on_attack_animation_finished):
			set_animation_finished(on_attack_animation_finished)
			
func on_aggro_animation_finished(animation_name):
	var crow = get_parent()
	if animation_name.contains("Aggro"):
		if not crow.moving:
			set_animation("Idle")
		else:
			set_animation("Walk")
		disconnect_animation_finished()
	
func set_animation(animation_name):
	var crow = get_parent()
	var player_position = Vector2()
	if crow.player:
		player_position = crow.player.global_position
	var final_name = animation_name
	match animation_name:
		"Walk": 
			if not current_action == "Walk":
				final_name = "Walk " + vec_to_name(crow.facing) + " Transition"
				current_action = "Walk"
			else:
				final_name = ""
		"Idle":
			if not current_action == "Idle":
				final_name = "Idle " + vec_to_name(crow.facing)
				current_action = "Idle"
			else:
				final_name = ""
				idle_timer += get_process_delta_time()
				if idle_timer >= crow.max_idle_time:
					idle_timer = 0.0
					if not player_position.is_zero_approx():
						if crow.global_position.distance_to(player_position) < crow.attack_range:
								crow.attacking = true
		"Attack":
			if not current_action == "Attack":
				final_name = "Prepare Attack " + vec_to_name(crow.facing)
				if not animation_finished.is_connected(on_prepare_attack_animation_finished):
					if animation_finished.is_connected(on_attack_animation_finished):
						animation_finished.disconnect(on_attack_animation_finished)
					animation_finished.connect(on_prepare_attack_animation_finished)
				current_action = "Attack"
			else: 
				final_name = ""
		"Aggro":
			if not current_action == "Aggro":
				final_name = "Aggro " + vec_to_name(crow.facing)
				if not animation_finished.is_connected(on_aggro_animation_finished):
					set_animation_finished(on_aggro_animation_finished)
			else:
				final_name = ""
	if not final_name.is_empty():
		play(final_name)

func update_animation(direction_changed, moving, attacking):
	var crow = get_parent()
	if direction_changed:
		current_action = ""
	if not moving and not attacking:
		set_animation("Idle")
	if attacking:
		set_animation("Attack")
	if moving and not attacking:
		set_animation("Walk")
	if (crow.global_position.distance_to(crow.prev_position) < 0.1) and (not crow.attacking):
		set_animation("Idle")

		

		
