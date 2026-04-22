extends RigidBody2D

class_name Weapon

var parent_hitbox : Hitbox
var death_cutscene = load("res://Utils/DeathCutscene.tscn")

func death():
	death_cutscene = death_cutscene.instantiate()
	add_sibling(death_cutscene)
	death_cutscene.position = position
	death_cutscene.duration = 1.0
	death_cutscene.play(0.0, self)
	queue_free()

# This weapon shouldn't trigger the hitbox of the actor that created it, 
#   but since projectiles are usually siblings instead of children,
#   it's not easy to tell who created it. It needs to be
#   set manually by the creator. It's the best I could think of
func set_parent_hitbox(_hitbox : Hitbox):
	parent_hitbox = _hitbox
	parent_hitbox.ignore.append(self)
	
