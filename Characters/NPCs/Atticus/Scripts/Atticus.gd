extends NPC

var intro_dialogue = [
	{"speaker":"Atticus", "text":"Off to another dig site, are you?"},
	{"speaker":"Atticus", "text":"Your aptituded for field work is fitting. Commoners prefer manual labor over academic refinement."},
	{"speaker":"Player", "text":"Your aptitude for study is fitting. You're one to value what you read over what you see."}
]

func _ready():
	$AnimatedSprite2D.play("Idle Left")
	
func activate(_using_item = null, _count = 0):
	Dialogue.open_dialogue.emit(intro_dialogue)
