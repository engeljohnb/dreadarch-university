extends Area2D

signal player_nearby(_player)
signal player_went_away()

func on_body_entered(body):
	if body.is_in_group("Player"):
		player_nearby.emit(body)

func on_body_exited(_body):
	if _body.is_in_group("Player"):
		player_went_away.emit()
		
func _ready():
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
