extends Area2D
signal hit(body)

var hit_group = "Weapons"

func on_body_entered(body):
	if (body.is_in_group(hit_group) and (body.get_parent() != get_parent())):
		hit.emit(body)

func _ready():
	body_entered.connect(on_body_entered)
