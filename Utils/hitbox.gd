extends Area2D
signal hit(body)

# For some nodes it's easiest to have the weapon as a sibling, others it's
# beter as a child. So hecking if the weapon and this hitbox share a parent
# isn't a good way to keep actors from hitting themselves. This is the
# best way I could think of -- just set the weapon when the calling node 
# creates the weapon.
var my_weapon = null

func on_body_entered(body):
	if (body != my_weapon) and (body.get_parent() != get_parent()):
		hit.emit(body)

func _ready():
	body_entered.connect(on_body_entered)
