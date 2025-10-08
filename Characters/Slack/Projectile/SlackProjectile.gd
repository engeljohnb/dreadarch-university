extends RigidBody2D

var facing = Vector2(0,-1)
var launch_velocity = facing
var player = null
var impulse_timer = 0.0
var time_between_impulses = 0.33
var prev_position : Vector2
var prev_facing : Vector2
var direction_change_counter = 0.0
var dead = false
var cutscene_timer = 0
var death_cutscene_duration = 0.5
@onready var hitbox = $CollisionShape2D
@onready var deathlight = $DeathLight


func _on_body_entered(body):
	if (body.name != "Slack") and not (body is TileMapLayer):
		$AnimatedSprite2D.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		$DeathSound.play()
		deathlight.visible = true
		dead = true
	
func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func launch(direction, _player):
	player = _player
	position += 75*direction
	facing = -(player.global_position - global_position).normalized()
	
	apply_impulse(direction*200.0)
	if Utils.nearest_cardinal_direction(direction) == Utils.RIGHT:
		$AnimatedSprite2D.scale.x = -$AnimatedSprite2D.scale.x
	#else:
	#	$AnimatedSprite2D.rotate(Utils.RIGHT.angle_to(direction))
	$AnimatedSprite2D.play("default")

func play_death_cutscene(delta):
		deathlight.modulate = Color(1,0,0,)
		cutscene_timer += delta
		var cutscene_percent = cutscene_timer/death_cutscene_duration
		deathlight.energy = 1.0/cutscene_percent
		if cutscene_timer >= death_cutscene_duration:
			queue_free()
			
func _physics_process(_delta):
	if dead:
		position = prev_position
		play_death_cutscene(_delta)
	else:
		facing = (player.global_position - global_position).normalized()
		impulse_timer += _delta
		direction_change_counter += abs(prev_facing.angle_to(facing))
		if abs(direction_change_counter) >= PI:
			direction_change_counter = 0
			$AnimatedSprite2D.scale.x = -$AnimatedSprite2D.scale.x
		if impulse_timer >= time_between_impulses:
			impulse_timer = 0.0
			apply_impulse(facing * 35.0)
		prev_position = global_position
		prev_facing = facing
