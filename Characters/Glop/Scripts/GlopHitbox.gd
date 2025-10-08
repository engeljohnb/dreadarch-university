extends Area2D
signal hit(body)

# For some nodes it's easiest to have the weapon as a sibling, others it's
# beter as a child. So hecking if the weapon and this hitbox share a parent
# isn't a good way to keep actors from hitting themselves. This is the
# best way I could think of -- just set the weapon when the calling node 
# creates the weapon.
var my_weapon = null
var my_weapons = []
var ignore = []
@onready var shape = $CollisionShape2D.shape

func on_body_entered(body):
	#Glops can't be hurt by other glops.
	if "glop_weapon" in body:
		return
	if body.is_in_group("Weapons"):
		if "dead" in body.get_parent():
			if body.get_parent().dead:
				return
		if body in ignore:
			return
		if my_weapon:
			if (body != my_weapon): 
				hit.emit(body)
		if not my_weapons.is_empty():
			if not (body in my_weapons):
				hit.emit(body)
		else:
			if (body.get_parent() != get_parent()):
				hit.emit(body)

func _ready():
	body_entered.connect(on_body_entered)
	area_entered.connect(on_body_entered)
