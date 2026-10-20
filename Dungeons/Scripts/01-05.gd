extends Room
var crow_spawned = false
func spawn_crow():
	var crow = preload("res://Enemies/Crow/Crow.tscn").instantiate()
	$Enemies.add_child(crow)
	crow.position = Vector2(447.0, -331.0)
	crow.default_idle = true
	var aurelia = get_node_or_null("NPCs/Aurelia")
	if aurelia:
		crow.died.connect(aurelia.trigger_transformation)
		crow.died.connect(func (): $Decorations/Decoration/CollisionShape2D.disabled = true)

func _process(_delta):
	if Tutorial.messages_shown[ItemCollection.GOLDEN_DAGGER]:
		if not crow_spawned:
			if not Dialogue.dialogue_open():
				spawn_crow() 
				crow_spawned = true
