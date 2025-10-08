extends Node2D
var frame_timer = 0.0
var timer = 0.0
var frame_rate = 1.0/12.0
var player = null
var cut = false
var camera : Camera2D
var wind_speed = 0.0

func on_body_entered(body):
	if cut:
		return
	if body.is_in_group("Weapons"):
		$AnimatedSprite2D.play("Cut")
		$AnimatedSprite2D.animation_finished.connect(queue_free)
		cut = true
	
func _ready():
	camera = get_tree().get_nodes_in_group("Player")[0].camera
	$AnimatedSprite2D.animation = "default"
	$AnimatedSprite2D.frame = randi() % 4
	$Area2D.body_entered.connect(on_body_entered)
	$AnimatedSprite2D.scale.x = max(randf() + 0.75, 1.3)
	$AnimatedSprite2D.scale.y = max(randf() + 0.75, 1.3)
	wind_speed = 0.065 + (randf()/100.0)
	
func update_skew():
	#skew = sin(timer+position.x)*0.075
	skew = sin(timer+position.x)*wind_speed
	
func player_in_grass():
	if not player:
		player = get_tree().get_nodes_in_group("Player")[0]
	if abs(player.global_position.distance_to(global_position) - 16.0) < 16.0:
		return true
	return false
	
func skew_for_player():
	skew = (0.25 - (player.global_position.angle_to(global_position)*0.25))
	
func in_viewport():
	var viewport = camera.get_viewport()
	var pos = camera.get_target_position() - (viewport.size/2.0)
	var rect = Rect2(pos, viewport.size)
	return (rect.has_point(global_position))
	
func _process(delta):
	if not in_viewport():
		return
	if player_in_grass():
		skew_for_player()
		return
	timer += delta
	frame_timer += delta
	if frame_timer >= frame_rate:
		frame_timer = 0.0
		update_skew()
