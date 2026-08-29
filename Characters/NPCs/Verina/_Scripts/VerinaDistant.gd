extends NPC

var _cutscene_timer := 0.0
var _in_cutscene := false
var _moving_right := false
	
func _ready():
	if StoryState.state["seen_by_verina"]:
		queue_free()
	else:
		StoryState.state["seen_by_verina"] = true
		$AnimatedSprite2D.play("Idle")

func activate(_using_item = null, _count = 0):
	StoryState.state["seen_by_verina"] = true
	activate_event_sequence()
	
func activate_event_sequence():
	var seq = EventSequence.new()
	seq.add_cutscene_event("play_wave_cutscene")
	seq.add_cutscene_event("play_run_cutscene", self, true)
	add_child(seq)
	seq.start_events()

func play_run_cutscene(_delta : float):
	$AnimatedSprite2D.play("Run")
	_in_cutscene = true
	
func _process(delta):
	if _in_cutscene:
		if _cutscene_timer >= (1.0/12.0)*4.0:
			_moving_right = true
		if _moving_right:
			position.x -= (600.0)*delta
			$AnimatedSprite2D.modulate.a -= delta*15.0
		if _cutscene_timer >= (1.0/12.0)*27.0:
			cutscene_ended.emit(play_run_cutscene)
			queue_free()
		_cutscene_timer += delta
	
