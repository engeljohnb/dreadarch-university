extends Area2D

signal player_nearby(player)

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_nearby.emit(body)
