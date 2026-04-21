extends Node2D
class_name EnemyDeathCutscene

var cutscene_timer = 0.0
var cutscene_duration = 1.0
var cutscene_speed = 2.66
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
	else:
		deathlight.modulate = Color(1,0,0,)
		cutscene_timer += delta
		var cutscene_percent = cutscene_timer/cutscene_speed
		deathlight.energy = 1.0/cutscene_percent
		if cutscene_timer >= cutscene_duration:
			if _actor == self:
				get_parent().call_deferred("queue_free")
			else:
				actor.queue_free()
			call_deferred("queue_free")

func _process(_delta):
	if playing:
		play(_delta)
