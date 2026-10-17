extends Door


func on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		start_transition()
	
func _ready():
	body_entered.connect(on_body_entered)

func _process(_delta):
	if player_entered:
		if not player.in_cutscene:
			SceneTransition.enter_scene(next_scene, next_start_position, true)
