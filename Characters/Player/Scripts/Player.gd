extends CharacterBody2D

# This node is just a huge mess. Several other systems were overhauled
#   and refactored to make them cleaner, but the player is
#   far too coupled to too many systems. Sorry, it just ended up this way.

signal died()
signal lost_life(damage)
signal gained_life(life)
signal gained_temporary_life(life)
signal item_equipped(item, count)
@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var hitbox = $Hitbox
@onready var blinker = $Blinker
@onready var light = $PointLight2D
@onready var attack_sound = $AttackSound
@onready var sprite = $AnimatedSprite2D
@onready var step_sound = $StepSound
@onready var camera = $Camera2D


const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)
const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const SPEED = 400.0

var level = 1
var attack_damage = 1
var inventory = {"Scroll Fragment" = []}
var dead = false
var in_cutscene = false
var current_cutscene = null
var cutscene_timer = 0.0
var cutscene_duration = 0.0
var life = 3
var total_life = 3
var temporary_life = 0
var _attack_fx = load("res://Characters/Player/PlayerAttackFX.tscn")
var attack_fx = null
var facing : Vector2
var prev_facing = Vector2(0,1)
var direction_changed = false
var moving = false
var equipped = ItemCollection.GOLDEN_DAGGER
var attacking = false
var won = false
var door_cutscene = {"position": Vector2(), "player_start_pos": Vector2(), "arriving": false, "min_scale": 0.8}
var climb_cutscene = {"position" : Vector2(), "start_pos" : Vector2(), "arriving" : false, "direction":""}
var outside_door_cutscene = {"reverse":false}
var in_dialogue = false
var direction_priority
# Why have golden_dagger_equipped when I can just check equipped == ItemCollection.GOLDEN_DAGGER?
# Becaues everything breaks in the AnimationTree state machine when the advance condition
# is equipped == ItemCollection.GOLDEN_DAGGER. I don't know why but having this variable instead makes it work.
var golden_dagger_equipped = true
var hard_step_sound = load("res://Assets/Sounds/Student/StepSound.ogg")
var soft_step_sound = load("res://Assets/Sounds/Student/SoftStepSound.ogg")
var grass_step_sound = load("res://Assets/Sounds/Student/GrassSteps.ogg")
var cutscene_just_ended = false
var level_up_dialogue = [
	{
		"text":"I should take these back up to the library. I bet I could translate them if I had some dictionaries.",
		"speaker":"Player"
	}
]
func zero_inventory():
	inventory = {
		ItemCollection.SCROLL_FRAGMENT : [], 
		ItemCollection.TREASURE : int(0),
		ItemCollection.TALONS: int(0), 
		ItemCollection.GOLDEN_DAGGER : int(0)
		}

func init_for_newgame():
	zero_inventory()
	life = 3
	total_life = 3
	position = Vector2()
	
func on_scroll_fragment_translated(scroll_fragment):
	for scroll in inventory[ItemCollection.SCROLL_FRAGMENT]:
		if scroll["latin_text"] == scroll_fragment["latin_text"]:
			scroll["translated"] = true
	
func on_item_collected(item, count, _should_play_sound):
	if item is Dictionary:
		match item["type"]:
			ItemCollection.SCROLL_FRAGMENT:
				if count > 0:
					item["collected"] = true
					if inventory[ItemCollection.SCROLL_FRAGMENT].is_empty():
						ItemCollection.prompt_to_read_scroll_fragment()
					elif inventory[ItemCollection.SCROLL_FRAGMENT].size() == ItemCollection.fragments_to_level_up-1:
						Dialogue.open_dialogue.emit(level_up_dialogue)
					inventory[ItemCollection.SCROLL_FRAGMENT].append(item)				
				elif count < 0:
					inventory[ItemCollection.SCROLL_FRAGMENT].erase(item)
				return
	if item == ItemCollection.HEART:
		gain_life(1)
		return
	elif not inventory.get(item):
		inventory[item] = count
	else:
		inventory[item] += count
	if (inventory[item] is int) or (inventory[item] is float):
		if inventory[item] <= 0:
			inventory[item] = 0
	if item == ItemCollection.GOLDEN_DAGGER:
		on_inventory_action_chosen("Equip", "", 1)
		if count < 0:
			inventory[ItemCollection.GOLDEN_DAGGER] = 0
		else:
			inventory[ItemCollection.GOLDEN_DAGGER] = 1
		
func direction_just_released():
	return (Input.is_action_just_released("Left")
		or Input.is_action_just_released("Right")
		or Input.is_action_just_released("Up")
		or Input.is_action_just_released("Down"))
	
func direction_just_pressed():
	return (Input.is_action_just_pressed("Left")
		or Input.is_action_just_pressed("Right")
		or Input.is_action_just_pressed("Up")
		or Input.is_action_just_pressed("Down"))
		
func direction_held():
	return (Input.is_action_pressed("Left")
	or Input.is_action_pressed("Right")
	or Input.is_action_pressed("Up")
	or Input.is_action_pressed("Down"))
	
func play_outside_door_cutscene(delta, reverse = false):
	if delta == 0.0:
		init_cutscene(play_outside_door_cutscene, 1.0)
		var animation_name = "Walk"
		if equipped == ItemCollection.GOLDEN_DAGGER:
			animation_name = animation_name + " Knife"
		animation_name = animation_name + " " + Utils.nearest_cardinal_direction(facing, true)
		if reverse:
			modulate.a = 0.0
			outside_door_cutscene["reverse"] = true
		var playback = anim_tree["parameters/playback"]
		playback.travel("End")
		$AnimatedSprite2D.play(animation_name)
	else:
		cutscene_timer += delta
		var dir = Utils.nearest_cardinal_direction(facing, true)
		var speed = SPEED*0.5
		if outside_door_cutscene["reverse"]:
			speed = speed
		match dir:
			"Left":
				position.x -= speed*delta
			"Right":
				position.x += speed*delta
			"Up":
				position.y -= speed*delta
			"Down":
				position.y += speed*delta
			dir:
				position.x += speed*delta
		if outside_door_cutscene["reverse"]:
			modulate.a = (cutscene_timer/cutscene_duration)
		else:
			modulate.a = 1.0 - (cutscene_timer/cutscene_duration)
		if cutscene_timer >= cutscene_duration:
			if outside_door_cutscene["reverse"]:
				modulate.a = 1.0
			else:
				modulate.a = 0.0
			end_cutscene()
			outside_door_cutscene["reverse"] = false

func init_cutscene(cutscene : Callable, duration : float):
	var playback = anim_tree["parameters/playback"]
	playback.travel("End")
	in_cutscene = true
	cutscene_timer = 0.0
	cutscene_duration = duration
	current_cutscene = cutscene

func get_held_direction_name():
	if Input.is_action_pressed("Left"):
		return "Left"
	if Input.is_action_pressed("Right"):
		return "Right"
	if Input.is_action_pressed("Up"):
		return "Up"
	if Input.is_action_pressed("Down"):
		return "Down"
	else:
		return "None"
		
func has_knife_equipped():
	return (equipped == ItemCollection.GOLDEN_DAGGER)
	
func end_cutscene(to_idle = true, direction = facing):
	in_cutscene = false
	cutscene_timer = 0.0
	cutscene_duration = 0.0
	current_cutscene = null
	sprite.stop()
	update_direction()
	update_direction()
	if direction != facing:
		facing = direction
	update_animation_blend_positions()
	var playback = anim_tree["parameters/playback"]
	if to_idle:
		playback.travel("Idle")
	if door_cutscene["arriving"]:
		cutscene_just_ended = true

func is_cutscene_over():
	return cutscene_timer >= cutscene_duration
	
func play_door_cutscene_walk_animation(dir, arriving):
	match dir:
			"North":
				if equipped == ItemCollection.GOLDEN_DAGGER:
					sprite.play("Walk Knife Up")
				else:
					sprite.play("Walk Up")
				if arriving:
					door_cutscene["min_scale"] = 1.2
			"South":
				if equipped == ItemCollection.GOLDEN_DAGGER:
					sprite.play("Walk Knife Down")
				else:
					sprite.play("Walk Down")
				if not arriving:
					door_cutscene["min_scale"] = 1.2
			"West":
				if equipped == ItemCollection.GOLDEN_DAGGER:
					sprite.play("Walk Knife Left")
				else:
					sprite.play("Walk Left")
			"East":
				if equipped == ItemCollection.GOLDEN_DAGGER:
					sprite.play("Walk Knife Right")
				else:
					sprite.play("Walk Right")
					
func door_cutscene_update(delta):
	cutscene_timer += delta
	if door_cutscene["arriving"]:
		modulate.a = cutscene_timer
	else:
		modulate.a = 1.0 - cutscene_timer
	if (door_cutscene["direction"] == "West") or (door_cutscene["direction"] == "East"):
		if door_cutscene["arriving"]:
			var target_position = Vector2(door_cutscene["position"].x - hitbox.shape.get_rect().size.x+60.0, door_cutscene["position"].y)
			global_position = lerp(SceneTransition.player_start_position, target_position, cutscene_timer)
			scale = lerp(Vector2(1.0,1.0)*door_cutscene["min_scale"], Vector2(1.0,1.0), cutscene_timer)
		else:
			var x_difference = (door_cutscene["position"].x - door_cutscene["player_start_pos"].x)
			var x_total = door_cutscene["player_start_pos"].x + x_difference
			var target_pos = Vector2(x_total, door_cutscene["player_start_pos"].y)
			#scale = lerp(Vector2(1.0,1.0), Vector2(1.0,1.0)*door_cutscene["min_scale"],  cutscene_timer)
			global_position = lerp(door_cutscene["player_start_pos"], target_pos, cutscene_timer)
	elif (door_cutscene["direction"] == "North") or (door_cutscene["direction"] == "South"):
		if door_cutscene["arriving"]:
			var target_position = Vector2(door_cutscene["position"].x, door_cutscene["position"].y - hitbox.get_shape().get_rect().size.y+60.0)
			global_position = lerp(SceneTransition.player_start_position, target_position, cutscene_timer)
			scale = lerp(Vector2(1.0,1.0)*door_cutscene["min_scale"], Vector2(1.0,1.0), cutscene_timer)
		else:
			scale = lerp(Vector2(1.0,1.0), Vector2(1.0,1.0)*door_cutscene["min_scale"],  cutscene_timer)
			global_position = lerp(door_cutscene["player_start_pos"], door_cutscene["position"], cutscene_timer)

func play_door_cutscene(delta, door_position = Vector2(), dir = "North", arriving = false):
	if delta == 0.0:
		init_cutscene(play_door_cutscene, 1.0)
		door_cutscene["arriving"] = arriving
		door_cutscene["min_scale"] = 0.8
		modulate.a = 0
		door_cutscene["position"] = door_position
		door_cutscene["player_start_pos"] = global_position
		door_cutscene["direction"] = dir
		play_door_cutscene_walk_animation(dir, arriving)
	else:
		door_cutscene_update(delta)
		if is_cutscene_over():
			if door_cutscene["arriving"]:
				scale = Vector2(1.0,1.0)
				modulate.a = 1.0
				var held_direction = get_held_direction_name()
				if held_direction != "None":
					if has_knife_equipped():
						sprite.play("Walk Knife " + get_held_direction_name())
					else:
						sprite.play("Walk " + get_held_direction_name())
				end_cutscene(true, facing)
			else:
				end_cutscene(false)
	
func play_climb_cutscene(delta, _climb_cutscene = {}):
	if delta == 0.0:
		init_cutscene(play_climb_cutscene, 1.75)
		var direction = _climb_cutscene["direction"]
		var arriving = _climb_cutscene["arriving"]
		climb_cutscene = _climb_cutscene
		climb_cutscene["played_climb_down"] = false
		if direction == "Down":
			if not arriving:
				sprite.play("Climb Down Transition")
			else:
				z_index = 2
				sprite.play("Climb Down")
				climb_cutscene["start_pos"].y -= 215.0
				global_position.y -= 215.0
		else:
			sprite.play_backwards("Climb Down")
			if arriving:
				climb_cutscene["start_pos"].y += 45.0
			else:
				z_index = 2
		current_cutscene = play_climb_cutscene
		global_position.x = climb_cutscene["position"].x
		climb_cutscene["start_pos"].x = climb_cutscene["position"].x
		step_sound.stop()
		var playback = anim_tree["parameters/playback"]
		playback.travel("End")
	else:
		cutscene_timer += delta
		if not climb_cutscene["arriving"]:
			if climb_cutscene["direction"] == "Down":
				global_position = lerp(climb_cutscene["start_pos"], climb_cutscene["position"], cutscene_timer*1.25)
				if cutscene_timer >= 0.75:
					if (sprite.animation != "Climb Down"):
						sprite.play("Climb Down")
					sprite.modulate.a = lerp(1.0, 0.0, cutscene_timer-0.75)
					global_position.y += 25.0*delta
				if is_cutscene_over():
					z_index = 0
					end_cutscene()
					return
			else:
				global_position.y -= 135.0*delta
				sprite.modulate.a = 1.0 - (cutscene_timer/1.75)
				sprite.modulate.a = lerp(1.0, 0.0, cutscene_timer/2.0)
				if cutscene_timer > 1.75:
					z_index = 0
					end_cutscene()
					return
		else:
			if climb_cutscene["direction"] == "Up":
				global_position = lerp(climb_cutscene["start_pos"], climb_cutscene["position"], cutscene_timer*1.25)
				sprite.modulate.a = lerp(0.0, 1.0, cutscene_timer/2.0)
				if cutscene_timer > 1.0:
					sprite.play_backwards("Climb Down Transition")
					global_position.y -= 25 * (cutscene_timer - 1.0)
					if is_cutscene_over():
						z_index = 0
						end_cutscene(true, Utils.UP)
			else:
				sprite.play("Climb Down")
				z_index = 2
				global_position.y += 135.0 * delta 
				sprite.modulate.a = (cutscene_timer/1.75)
				if is_cutscene_over():
					z_index = 0
					end_cutscene(true, Utils.LEFT)

func play_victory_cutscene(delta):
	if delta == 0.0:
		won = true
		init_cutscene(play_victory_cutscene, 3.0)
		$AnimatedSprite2D.play("Idle Down")
		$StepSound.stop()
	cutscene_timer += delta
	if cutscene_timer >= cutscene_duration:
		end_cutscene()

func reset_direction_changed():
	direction_changed = false

func update_direction():
	direction_changed = false
	if moving:
		if Input.is_action_just_pressed("Left"):
			direction_priority = "Left"
			direction_changed = true
		if Input.is_action_just_pressed("Right"):
			direction_priority = "Right"
			direction_changed = true
		if Input.is_action_just_pressed("Up"):
			direction_priority = "Up"
			direction_changed = true
		if Input.is_action_just_pressed("Down"):
			direction_priority = "Down"
			direction_changed = true
		if direction_just_released():
			direction_changed = true
	var movement_direction = Vector2()
	if Input.is_action_pressed("Left"):
		if direction_priority == "Left":
			movement_direction += LEFT*2
		else:
			movement_direction += LEFT
	if Input.is_action_pressed("Right"):
		if direction_priority == "Right":
			movement_direction += RIGHT*2.0
		else:
			movement_direction += RIGHT
	if Input.is_action_pressed("Up"):
		if direction_priority == "Up":
			movement_direction += UP*2.0
		else:
			movement_direction += UP
	if Input.is_action_pressed("Down"):
		if direction_priority == "Down":
			movement_direction += DOWN*2.0
		else:
			movement_direction += DOWN
	movement_direction = movement_direction.normalized()
	if movement_direction.is_zero_approx():
		moving = false
		facing = prev_facing
	else:
		moving = true
		facing = movement_direction
	$InteractionRay.target_position = 45*facing

func update_animation_blend_positions():
	anim_tree.set("parameters/Walk/Walk/blend_position", facing)
	anim_tree.set("parameters/Walk/Walk Knife/blend_position", facing)
	anim_tree.set("parameters/Attack/Attack/blend_position", facing)
	anim_tree.set("parameters/Attack/Throw/blend_position", facing)
	anim_tree.set("parameters/Idle/Idle/blend_position", facing)
	anim_tree.set("parameters/Idle/Idle Knife/blend_position", facing)

func get_hitbox():
	return $Hitbox
	
func throw_projectile():
	match equipped:
		ItemCollection.TALONS:
			Attack.new().transform_into_talons_attack().activate(self)
		ItemCollection.ORBITER:
			Attack.new().transform_into_orbiter_attack().activate(self)
	var equip_dagger = false
	if inventory[equipped] == 1:
		if inventory[ItemCollection.GOLDEN_DAGGER] > 0:
			equip_dagger = true
	ItemCollection.item_collected.emit(equipped, -1, false)
	if equip_dagger:
		on_inventory_action_chosen("Equip", ItemCollection.GOLDEN_DAGGER, 1)

func update_attack_state():
	if equipped == ItemCollection.GOLDEN_DAGGER:
		if attacking and (not attack_fx):
			attacking = false
			return
		if Input.is_action_just_pressed("Attack") and (not attacking):
			attack_sound.play()
			attacking = true
			attack_fx = _attack_fx.instantiate()
			attack_fx.change_direction(facing)
			hitbox.ignore.append(attack_fx)
			add_child(attack_fx)
	else:
		if Input.is_action_just_pressed("Attack") and (not attacking):
			if not equipped.is_empty():
				if inventory[equipped] > 0:
					attacking = true

func reset_attack_state():
	if attack_fx:
		remove_child(attack_fx)
		attack_fx = null
	attacking = false
	var state_machine = anim_tree["parameters/playback"]
	state_machine.travel("Idle")
	if inventory.get(equipped):
		if inventory[equipped] is int:
			if inventory[equipped] < 0:
				inventory[equipped] = 0
				equipped = ""

func update_position(delta):
	if attacking:
		return
	if direction_held():
		if not $StepSound.playing:
			$StepSound.play()
	else:
		$StepSound.stop()
	if moving:
		position += SPEED * facing * delta
	move_and_slide()

func death():
	if attack_fx:
		attack_fx.visible = false
		attack_fx.queue_free()
	$AnimatedSprite2D.play("Idle Down")
	attacking = false
	dead = true
	died.emit()
	
func hit(_body):
	# Check for i-frames
	if in_cutscene:
		return
	if not blinker.blinking:
		if temporary_life > 0:
			temporary_life -= 1
		else:
			life -= 1
		lost_life.emit(1)
		blinker.blink(0.5)
	if life <= 0:
		death()
	
func on_blinker_flip(state):
	if state:
		set_modulate(Color(1.6, 1.6, 1.6))
	else:
		set_modulate(Color(1,1,1))

func _ready():
	get_tree().paused = true
	blinker.flip.connect(on_blinker_flip)
	inventory[ItemCollection.GOLDEN_DAGGER] = 0
	ItemCollection.item_collected.emit(ItemCollection.GOLDEN_DAGGER, 1, true)
	on_inventory_action_chosen("Equip", ItemCollection.GOLDEN_DAGGER, 1)

func on_inventory_action_chosen(action, item, count):
	match action:
		"Use":
			$InteractionRay.temp_message = "Z to " + action
			$InteractionRay.using_item = item
			$InteractionRay.using_item_count = count
			if $InteractionRay.message_showing:
				$InteractionRay.message.text = "Z to " + action
		"Equip":
			match item:
				ItemCollection.TALONS:
					equipped = ItemCollection.TALONS
					golden_dagger_equipped = false
				ItemCollection.GOLDEN_DAGGER:
					equipped = ItemCollection.GOLDEN_DAGGER
					golden_dagger_equipped = true
				item:
					equipped = ""
					golden_dagger_equipped = false
			if inventory.get(item):
				if (inventory[item] is int) or (inventory[item] is float):
					item_equipped.emit(item, inventory[item])
			else:
				item_equipped.emit(item, 1)
		"Drink":
			match item:
				ItemCollection.NECTAR:
					gain_life(1, true)
			ItemCollection.item_collected.emit(item, -1, true)
					
func gain_life(_life, temporary = false):
	if temporary:
		life = total_life
		gained_life.emit(total_life - life)
		temporary_life += _life
		gained_temporary_life.emit(_life)
	else:
		life += 1
		if life >= total_life:
			life = total_life
		gained_life.emit(_life)
	
func one_or_no_equippable_items():
	var num_equippables = 0
	for key in inventory:
		if (key in ItemCollection.equippable):
			if (inventory[key] is float) or (inventory[key] is int):
				if inventory[key] > 0:
					num_equippables += 1
					if num_equippables > 1:
						return false
	if num_equippables <= 1:
		return true

func change_equipment_quick(direction : String):
	if one_or_no_equippable_items():
		return
	var target_index = 0
	var found_next_item = false
	var desired_item = ""
	while (not found_next_item):
		for i in range(0, ItemCollection.equippable.size()):
			if equipped == ItemCollection.equippable[i]:
				target_index = i
		if direction == "Left":
			target_index -= 1
		if direction == "Right":
			target_index += 1
			if target_index >= ItemCollection.equippable.size():
				target_index = 0
		var item = ItemCollection.equippable[target_index]
		if (inventory[item] is float) or (inventory[item] is int):
			if inventory[item] > 0:
				found_next_item = true
				desired_item = item
	on_inventory_action_chosen("Equip", desired_item, 1)

func toggle_light():
	if light.energy == 3.0:
		light.energy = 1.0
		modulate = Color(1.3,1.3,1.3)
	else:
		light.energy = 3.0
		modulate = Color(1,1,1)
func turn_down_light():
	light.energy = 1.0
	modulate = Color(1.3,1.3,1.3)
func turn_up_light():
	light.energy = 3.0
	modulate = Color(1,1,1)
func update_equipment():
	if Input.is_action_just_pressed("ChangeEquipmentLeft"):
		change_equipment_quick("Left")
	if Input.is_action_just_pressed("ChangeEquipmentRight"):
		change_equipment_quick("Right")
	if equipped == "":
		return
	if (inventory.get(equipped) is int) or (inventory[equipped] is float):
		if inventory[equipped] <= 0:
			if equipped == ItemCollection.GOLDEN_DAGGER:
				golden_dagger_equipped = false
			inventory[equipped] = 0

func get_step_sound(sound_name):
	match sound_name:
		"Hard":
			return hard_step_sound
		"Soft":
			return soft_step_sound
			
func update_step_sound(sound_source):
	# In case the player processes after the scene has been freed.
	if (not sound_source):
		return
	if sound_source is TileMapLayer:
		var tilemap = sound_source
		var map = tilemap.local_to_map(tilemap.to_local(global_position))
		var data = tilemap.get_cell_tile_data(map)
		if not data:
			return
		var sound_name = data.get_custom_data("Sound")
		var stream = get_step_sound(sound_name)
		if stream != step_sound.stream:
			step_sound.stream = stream
			match sound_name:
				"Soft":
					step_sound.volume_db = -17.0
				"Hard":
					step_sound.volume_db = -8.0
	elif (sound_source is String) or (sound_source is StringName):
		var sound_name = sound_source
		match sound_name:
			"Grass":
				if not (step_sound.stream == grass_step_sound):
					step_sound.stream = grass_step_sound
					step_sound.volume_db = -24.0

# These are here because of a bug every time the player goes through a door,
#  when they press and hold a direction key after the scene switches
#  but before the cutscene finishes 
#
# At the end of the cutscene, instead of the walk animation updating to the player's new direction,
#  something somewhere is changing the sprite's animation back to whatever
#  was needed for the door cutscene. And whatever it is keeps trying for several
#  frames, so just putting it right at the end of the cutscene doesn't work.
# 
# I've tried so hard to figure out what's messing up the animation. I give up.
#  I'm doing this cludge and I'll think about actually fixing it if it
#  causes other problems.
var stupid_counter = 0
func stupid_post_door_cutscene_correction():
	if stupid_counter < 4:
		stupid_counter += 1
	else:
		var held_direction = get_held_direction_name()
		if held_direction != "None":
			if has_knife_equipped():
				sprite.play("Walk Knife " + held_direction)
			else:
				sprite.play("Walk " + held_direction)
		stupid_counter = 0
		cutscene_just_ended = false
		
func _process(delta):
	if not in_dialogue:
		if not in_cutscene:
			if Input.is_action_just_pressed("GainLifeCheat"):
				gain_life(1)
			update_direction()
			update_equipment()
			update_attack_state()
			update_position(delta)
			update_animation_blend_positions()
			prev_facing = facing
		else:
			if current_cutscene:
				current_cutscene.call(delta)
		if cutscene_just_ended:
			stupid_post_door_cutscene_correction()
