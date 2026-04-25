extends RigidBody2D

class_name Weapon

var parent_hitbox : Hitbox
const _my_scene = "res://Weapons/Weapon.tscn"
var death_cutscene = load("res://Utils/DeathCutscene.tscn")
var type : int = 0

enum Types
{
	# NOTE: Not all of these are strictly Weapons. Some of them are Obstacles.
	TALONS = 0,
	ORBITER,
	SLIME_TRAIL
}
func death():
	death_cutscene = death_cutscene.instantiate()
	add_sibling(death_cutscene)
	death_cutscene.position = position
	death_cutscene.duration = 1.0
	death_cutscene.play(0.0, self)
	queue_free()
	
static func create():
	return load(_my_scene).instantiate()

# This weapon shouldn't trigger the hitbox of the actor that created it, 
#   but since projectiles are usually siblings instead of children,
#   it's not easy to tell who created it. It needs to be
#   set manually by the creator. It's the best I could think of
func set_parent_hitbox(_hitbox : Hitbox):
	parent_hitbox = _hitbox
	parent_hitbox.ignore.append(self)
	
func activate(_direction : Vector2):
	push_warning("activate function not impmlemented by Weapon subclass")
