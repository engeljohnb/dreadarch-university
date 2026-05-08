extends Node2D
class_name Attack

# Specifies behavior for attacks. Attacks are **ONE TIME USE** only. Freed on activate.
#  This is because I don't think I need persistent attacks, and it fixes a weird bug that's
#  been plaguing me.

enum Types
{
	PROJECTILE = 0,
	DROP_OBSTACLE
}


var num_weapons : int = 1
var weapon_type : int = 0
#var weapon_node : Weapon
static func create() -> Attack:
	var _node = preload("res://Weapons/Attack.tscn")
	return _node.instantiate()

func activate(attacker : Variant, direction : Vector2 = attacker.facing):
	# It's necessary to know who's launching it because the weapon needs to ignore
	#  its creator's hitbox.
	for i in range(0, num_weapons):
		var weapon_node = Weapon.create_instance(weapon_type)
		weapon_node.type = weapon_type
		var dir = direction
		if num_weapons > 1:
			var increment = (PI/8.0)
			var angle = (increment*i) - ((increment*num_weapons) / 2.0)
			dir = direction.rotated(angle)
		assert("get_hitbox" in attacker)
		weapon_node.set_parent_hitbox(attacker.get_hitbox())
		weapon_node.set_parent(attacker)
		# Add as an uncle node so the weapon isn't counted under the Enemies node.
		attacker.get_parent().add_sibling(weapon_node)
		weapon_node.position = attacker.position
		if "no_collide" in attacker:
			for immunity in attacker.no_collide:
				if weapon_type == immunity:
					assert("add_collision_exception_with" in attacker)
					attacker.add_collision_exception_with(weapon_node)
		weapon_node.activate(dir)
	call_deferred("free")
	
func transform_into(_weapon_type : int, _num_weapons : int = 1) -> Attack:
	#weapon_node = Weapon.create_instance(_weapon_type)
	num_weapons = _num_weapons
	weapon_type = _weapon_type
	#weapon_node.type = _weapon_type
	return self
	
func transform_into_talons_attack(_num_weapons : int = 1) -> Attack:
	#weapon_node = Weapon.create_instance(Weapon.Types.TALONS)
	num_weapons = _num_weapons
	weapon_type = Weapon.Types.TALONS
	return self
	
func transform_into_orbiter_attack(_num_weapons : int = 1) -> Attack:
	#weapon_node = Weapon.create_instance(Weapon.Types.ORBITER)
	num_weapons = _num_weapons
	weapon_type = Weapon.Types.ORBITER
	return self
