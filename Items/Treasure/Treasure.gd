extends Area2D

@onready var sprite = $AnimatedSprite2D
var timer = 0.0
var falling_animation_duration = 1.0
var falling = true
var wait_for_attack = false
var attack_finished = false
var attacking_body : CharacterBody2D
func on_body_entered(body):
	if body is TileMapLayer:
		if not (body.get_parent() is ParallaxLayer):
			falling = false
	if body is CharacterBody2D:
		if ("attacking" in body) and (not attack_finished):
			if body.attacking:
				attacking_body = body
				wait_for_attack = true
				return
		elif ("attacking" in body.get_parent()) and (not attack_finished):
			if body.get_parent().attacking:
				attacking_body = body.get_parent()
				wait_for_attack = true
				return
		Collectible.item_collected.emit(Collectible.TREASURE, 1)
		Collectible.sonds[Collectible.TREASURE].play()
		queue_free()

	
func _ready():
	body_entered.connect(on_body_entered)
	area_entered.connect(on_body_entered)
	$AnimatedSprite2D.play("default")
	
func play_falling_animation(delta):
	timer += delta
	scale = lerp(Vector2(1,1), Vector2(), timer/falling_animation_duration)
	if timer >= falling_animation_duration:
		queue_free()

func _process(_delta):
	if wait_for_attack:
		if not attacking_body.attacking:
			wait_for_attack = false
			attack_finished = true
	if falling:
		play_falling_animation(_delta)
