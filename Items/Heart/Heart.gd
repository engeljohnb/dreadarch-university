extends Area2D
var collected = false

func on_body_entered(body):
	if body.is_in_group("Player"):
		body.gain_life(1)
		collected = true
		$CollisionShape2D.set_deferred("disabled", true)
		visible = false
		$CollectedSound.play()
		
func _ready():
	$AnimatedSprite2D.play("default")
	body_entered.connect(on_body_entered)

func _process(_delta):
	if collected:
		if collected:
			if not $CollectedSound.playing:
				queue_free()
