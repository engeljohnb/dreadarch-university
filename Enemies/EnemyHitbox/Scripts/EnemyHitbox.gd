extends Area2D
class_name EnemyHitbox

var ignore = []
func _on_body_entered(body):
	if body.is_in_group("Weapons"):
		if body not in ignore:
			get_parent().hit(body)
	
func _ready():
	body_entered.connect(_on_body_entered)
