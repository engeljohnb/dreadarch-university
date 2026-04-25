extends Collectible

func on_collected(_body : Variant):
	var player = get_tree().get_nodes_in_group("Player")[0]
	player.gain_life()
	
func init():
	is_inventory_item = false
	
func play_falling_animation(delta):
	timer += delta
	scale = lerp(Vector2(1,1), Vector2(), timer/falling_animation_duration)
	if timer >= falling_animation_duration:
		queue_free()

func _process(_delta):
	if wait_for_attack:
		if not attacking_body.attacking:
			wait_for_attack = false
			attack_finished = true
	if falling:
		play_falling_animation(_delta)
