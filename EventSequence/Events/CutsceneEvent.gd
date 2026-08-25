class_name CutsceneEvent
extends Event


@export var cutscene : StringName
@export var target : Variant = "Player"
@export var one_time : bool = false
func start():
	if target is String:
		if target == "Player":
			target = get_tree().get_nodes_in_group("Player")[0]
	if target is CharacterBody2D:
		if target.get(cutscene):
			# I can't just use _set_finished here because it expects an argument,
			#  but the cutscene_ended signal returns the ended cutscene.
			target.cutscene_ended.connect(func(_cutscene):_finished = true)
		else:
			Error.error("Invalid CutsceneEvent target.")
	target.call(cutscene, 0.0)
	
func end():
	if one_time:
		queue_free()
	else:
		_started = false
