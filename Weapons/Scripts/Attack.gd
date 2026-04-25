class_name Attack

# Specifies behavior for attacks.

enum Types
{
	PROJECTILE = 0,
	DROP_OBSTACLE
}

var num_weapons : int = 1
var weapon_type : int = 0
var weapon_node : Node2D

func activate(attacker : Variant, direction : Vector2 = attacker.facing):
	# It's necessary to know who's launching it because the weapon needs to ignore
	#  its creator's hitbox.
	assert("get_hitbox" in attacker)
	weapon_node.set_parent_hitbox(attacker.get_hitbox())
	attacker.add_sibling(weapon_node)
	weapon_node.position = attacker.position
	assert("activate" in weapon_node)
	weapon_node.call_deferred("activate", Utils.nearest_cardinal_direction(direction))
	if "no_collide" in attacker:
		for immunity in attacker.no_collide:
			if weapon_type == immunity:
				assert("add_collision_exception_with" in attacker)
				attacker.add_collision_exception_with(weapon_node)
				
	
func transform_into(_weapon_type : int, _num_weapons : int = 1) -> Attack:
	match _weapon_type:
		Weapon.Types.TALONS:
			weapon_node = load("res://Weapons/Projectiles/Talons/CrowProjectile.tscn").instantiate()
		Weapon.Types.ORBITER:
			weapon_node = load("res://Weapons/Projectiles/Orbiter/SlackProjectile.tscn").instantiate()
		Weapon.Types.SLIME_TRAIL:
			weapon_node = load("res://Weapons/Obstacles/SlimeTrail/SlimeTrail.tscn").instantiate()
	num_weapons = _num_weapons
	weapon_type = _weapon_type
	weapon_node.type = _weapon_type
	return self
	
func transform_into_talons_attack(_num_weapons : int = 1) -> Attack:
	weapon_node = load("res://Weapons/Projectiles/Talons/CrowProjectile.tscn").instantiate()
	num_weapons = _num_weapons
	weapon_type = Weapon.Types.TALONS
	return self
	
func transform_into_orbiter_attack(_num_weapons : int = 1) -> Attack:
	weapon_node = load("res://Weapons/Projectiles/Orbiter/SlackProjectile.tscn").instantiate()
	num_weapons = _num_weapons
	weapon_type = Weapon.Types.ORBITER
	return self
