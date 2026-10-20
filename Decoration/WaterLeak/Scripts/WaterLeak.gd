extends Node2D

@export var num_segments : int
@export var finish : bool
@export var source : bool
@export var style : String = "01"
@export var only_from_below : bool = false

var _seg = load("res://Decoration/WaterLeak/WaterLeakSegment/WaterLeakSegment.tscn")
var segments = []

func on_splash_finished():
	for segment in segments:
		segment.visible = true
	match style:
		"01":
			$Splash01.play()
	
func begin_splash(segment):
	var player = get_tree().get_nodes_in_group("Player")[0]
	player.play_water_splash_cutscene(0.0)
	segment.play_splash_animation()
	var segment_index = 0
	for i in range(0, segments.size()):
		if segments[i] == segment:
			segment_index = i
			break
	for i in range(segment_index+1, segments.size()):
		segments[i].visible = false
		
func on_splash(segment):
	if Utils.player_in_touching_distance():
		begin_splash(segment)
	else:
		var seq : EventSequence = EventSequence.new()
		var target_position = Vector2()
		if only_from_below:
			target_position = segments[-1].global_position + (Vector2(0.0, 50.0))
		else:
			var p_player = Utils.player_position
			var t_left = segments[-1].global_position + Vector2(50.0, 0.0)
			var t_right = segments[-1].global_position - Vector2(50.0, 0.0)
			var d_left = p_player.distance_to(t_left)
			var d_right = p_player.distance_to(t_right)
			if d_left > d_right:
				target_position = t_right
			else:
				target_position = t_left
		var duration = Utils.get_walk_duration(target_position)
		seq.add_walk_event(target_position, duration)
		seq.ended.connect(begin_splash.bind(segment))
		add_child(seq)
		seq.start_events()
		
func _ready():
	for i in range(0, num_segments):
		var seg = _seg.instantiate()
		segments.append(seg)
		seg.style = style
		seg.segment_type = "Middle"
		seg.splashed.connect(on_splash)
	for i in range(0, num_segments):
		segments[-(i+1)].position.y -= (i*64)
	if source:
		segments[0].segment_type = "Source"
	if finish:
		if segments.size() > 1:
			segments[-1].segment_type = "Finish"
	for seg in segments:
		add_child(seg)
		seg.sprite.animation_finished.connect(on_splash_finished)
