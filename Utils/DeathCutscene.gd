extends Node2D
class_name EnemyDeathCutscene

var timer = 0.0
var duration = 1.0
var speed = 2.66
var playing = false
var _actor : Variant = self
func play(delta = 0.0, actor = self):
	playing = true
	var deathlight = $DeathLight
	if (delta == 0.0):
		deathlight.visible = true
		deathlight.energy = 1.0
		deathlight.modulate = Color(1,0,0,)
		if actor != self:
			actor.visible = false
			_actor = actor
		$AudioStreamPlayer2D.play()
	else:
		deathlight.modulate = Color(1,0,0,)
		timer += delta
		var percent = timer/speed
		deathlight.energy = 1.0/percent
		if timer >= duration:
			queue_free()

func _process(_delta):
	if playing:
		play(_delta)
