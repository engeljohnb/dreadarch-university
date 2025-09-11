extends CharacterBody2D

@export var direction: String
@onready var animation_player = $AnimationPlayer
@onready var search_area = $SearchArea
@onready var deathlight = $DeathLight
@onready var hitbox = $Hitbox
@onready var death_sound = $DeathSound

var player = null
var aggrod = false
var time_between_attacks = 1.5
var attack_timer = 0.0
var cutscene_timer = 0.0
var death_cutscene_duration = 0.5
var dead = false
var _weapon = load("res://Characters/Slack/Projectile/SlackProjectile.tscn")

func on_hit(_body):
	death_sound.play()
	for weapon in hitbox.ignore:
		if weapon:
			weapon.queue_free()
			weapon.set_deferred("disabled", true)
	dead = true
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	deathlight.visible = true

func on_player_nearby(_player):
	player = _player
	aggrod = true
	attack()

func on_player_went_away():
	aggrod = false
	animation_player.play("Idle")
	
func launch_projectile():
	var projectile = _weapon.instantiate()
	add_child(projectile)
	projectile.position = Vector2()
	projectile.global_position = global_position
	projectile.launch((player.global_position - global_position).normalized(), player)
	hitbox.ignore.append(projectile)
		
func _ready():
	if direction == "Right":
		$AnimatedSprite2D.scale.x = -$AnimatedSprite2D.scale.x
		$StupidShadow.scale.x = -$StupidShadow.scale.x
	animation_player.play("Idle")
	search_area.player_nearby.connect(on_player_nearby)
	search_area.player_went_away.connect(on_player_went_away)
	hitbox.hit.connect(on_hit)
	
func attack():
	animation_player.play("Attack")
	
func play_death_cutscene(delta):
		deathlight.modulate = Color(1,0,0,)
		cutscene_timer += delta
		var cutscene_percent = cutscene_timer/death_cutscene_duration
		deathlight.energy = 1.0/cutscene_percent
		if cutscene_timer >= death_cutscene_duration:
			queue_free()

func _process(_delta):
	if aggrod:
		attack_timer += _delta
		if attack_timer >= time_between_attacks:
			attack_timer = 0
			attack()
	if dead:
		play_death_cutscene(_delta)
		
