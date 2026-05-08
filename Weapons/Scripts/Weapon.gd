extends RigidBody2D

class_name Weapon

var parent : Variant
var parent_hitbox : Hitbox
var type : int = 0

enum Types
{
	# NOTE: Not all of these are strictly Weapons. Some of them are Obstacles.
	TALONS = 0,
	ORBITER,
	SLIME_TRAIL
}

static var _weapon_scenes : Dictionary[int, PackedScene] = {
	Weapon.Types.TALONS : load("res://Weapons/Projectiles/Talons/CrowProjectile.tscn"),
	Weapon.Types.ORBITER : load("res://Weapons/Projectiles/Orbiter/SlackProjectile.tscn"),
	Weapon.Types.SLIME_TRAIL : load("res://Weapons/Obstacles/SlimeTrail/SlimeTrail.tscn")
}

func death():
	var death_cutscene = preload("res://Utils/DeathCutscene.tscn")
	death_cutscene = death_cutscene.instantiate()
	add_sibling(death_cutscene)
	death_cutscene.position = position
	death_cutscene.duration = 1.0
	death_cutscene.play(0.0, self)
	queue_free()
	
static func create() -> PackedScene:
	return preload("res://Weapons/Weapon.tscn")

# This weapon shouldn't trigger the hitbox of the actor that created it, 
#   but since projectiles are usually siblings instead of children,
#   it's not easy to tell who created it. It needs to be
#   set manually by the creator. It's the best I could think of
func set_parent_hitbox(_hitbox : Hitbox):
	parent_hitbox = _hitbox
	parent_hitbox.ignore.append(self)
	
# In addition to the parent's hibox ignoring the weapon, the weapon's hitbox
#  needs to ignore the parent, so setting both is necesary.
func set_parent(_parent : Variant):
	parent = _parent
	
func activate(_direction : Vector2):
	Error.error("activate function not impmlemented by Weapon subclass")
	
static func create_instance(_type : int) -> Variant:
	var pck_scene = _weapon_scenes.get(_type)
	if pck_scene == null:
		Error.error("Invalid weapon ID: " + str(_type))
		return null
	return pck_scene.instantiate()
