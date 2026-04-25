extends Weapon

var facing = Vector2(0,-1)
var launch_velocity = facing
var player = null
var impulse_timer = 0.0
var time_between_impulses = 0.33
var prev_position : Vector2
var prev_facing : Vector2
var direction_change_counter = 0.0
var dead = false
var ignore = []
@onready var hitbox = $CollisionShape2D

func _on_body_entered(body):
	if not (body is TileMapLayer):
		dead = true

	
func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func activate(direction):
	player = get_tree().get_nodes_in_group("Player")[0]
	position += 75*direction
	facing = -(player.global_position - global_position).normalized()
	
	apply_impulse(direction*200.0)
	if Utils.nearest_cardinal_direction(direction) == Utils.RIGHT:
		$AnimatedSprite2D.scale.x = -$AnimatedSprite2D.scale.x
	$AnimatedSprite2D.play("default")

			
func _physics_process(_delta):
	if player == null:
		player = get_tree().get_nodes_in_group("Player")[0]
	if dead:
		position = prev_position
		death()
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
