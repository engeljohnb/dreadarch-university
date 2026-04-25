extends StaticBody2D

class_name Obstacle
# Obstacles have properties of both Weapons or Interactables, depending on context.
#  For example, SlimeTrail:
		# Does damage when player touches it (Weapon)
		# Player can use an empty bottle on it (Interactable) and collect it.
# Most graceful way I could come up with to make that happen is to just make
#  the object two objects.
# Why not just make it a Weapon? Bc Weapons are RigidBodies, and Obstacles need to be StaticBodies
var parent_hitbox : Hitbox
var type : int = 0


func activate(_direction : Vector2):
	push_warning("activate function not implemented by Obstacle subclass")

func set_parent_hitbox(_hitbox : Hitbox):
	parent_hitbox = _hitbox
	_hitbox.ignore.append(self)
