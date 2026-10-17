extends Door
@onready var north_sprite = $North
@onready var south_sprite = $South


func on_body_entered(body):
	if body.is_in_group("Player"):
		if not body.in_cutscene:
			player = body
			match direction:
				"North":
					var pos = Vector2(global_position.x, global_position.y + north_sprite.position.y)
					start_transition(pos)
				"South":
					start_transition()
		
func _ready():
	body_entered.connect(on_body_entered)
	match direction:
		"North":
			north_sprite.visible = true
		"South":
			north_sprite.visible = false

func _process(_delta):
	if player_entered:
		# Apparently calling this function right from on_body_entered breaks everything
		if not player.in_cutscene:
			var pos : Vector2
			match direction:
				"North":
					pos = Vector2(next_start_position.x, next_start_position.y + north_sprite.position.y + 100.0)
				"South":
					pos = Vector2(next_start_position.x, next_start_position.y - north_sprite.position.y - 240.0)
			SceneTransition.enter_scene(next_scene, pos, true)
	
