extends NPC

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var intro_dialogue = [
	{"speaker":"Atticus", "text":"Off to another dig site, are you?"},
	{"speaker":"Atticus", "text":"Your aptituded for field work is fitting. Commoners prefer manual labor over academic refinement."},
	{"speaker":"Player", "text":"Your aptitude for study is fitting. You're one to value what you read over what you see."}
]

var default_dialogue = [
	{
		"speaker":"Atticus",
		"text":"Do you need help reaching the top shelf?"
		}
]

var sequence : Array[StringName] = ["left_foot", "book", "left_foot", "right_foot"]
var _current_index : int = 0
var _idle_duration : float = 3.5
var _timer : float = 0.0
var _transitioning := false

func _ready():
	sprite.play("Idle Up LeftFoot")
	sprite.animation_finished.connect(_end_transition)

func _process(delta):
	if not _transitioning:
		if _timer >= _idle_duration:
			_timer = 0.0
			transition()
		_timer += delta

func activate(_using_item = null, _count = 0):
	if not check_status("introduced"):
		Dialogue.open_dialogue.emit(intro_dialogue)
		status["introduced"] = true
	else:
		Dialogue.open_dialogue.emit(default_dialogue)
	
func get_transition(current_state : StringName, next_state : StringName) -> Callable:
	match current_state:
		"left_foot":
			match next_state:
				"book":
					return take_book
				"right_foot":
					return shift_to_right
		"book":
			return return_book
		"right_foot":
			return shift_to_left
	Error.error("Invalid Atticus transition sequence.")
	return shift_to_left

func transition():
	_transitioning = true
	var next_index := (_current_index + 1) % sequence.size()
	var next_state : StringName = sequence[next_index]
	get_transition(sequence[_current_index], next_state).call()
	_current_index = next_index
	
func play_idle_animation():
	var state = sequence[_current_index]
	match state:
		"left_foot":
			sprite.play("Idle Up LeftFoot")
		"right_foot":
			sprite.play("Idle Up RightFoot")
		"book":
			sprite.play("Examine Book")
	
func _end_transition():
	_transitioning = false
	_idle_duration = randf_range(2.0,3.5)
	play_idle_animation()
	
func return_book():
	sprite.play("Return to Shelf")

func shift_to_left():
	sprite.play_backwards("Shift")

func shift_to_right():
	sprite.play("Shift")
	
func take_book():
	sprite.play("Pull From Shelf")
