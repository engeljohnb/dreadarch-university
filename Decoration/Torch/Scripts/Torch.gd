extends AnimatedSprite2D
var timer = 0.0

func _ready():
	play("default")
	
func _process(_delta):
	timer += _delta
	$PointLight2D.energy = 1.5 + (sin(timer*20.0)/5.0)
	if timer >= 60.0:
		timer = 0.0
