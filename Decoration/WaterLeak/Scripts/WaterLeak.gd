extends Node2D

@export var num_segments : int
@export var source : bool
@export var style : String = "01"

var _seg = load("res://Decoration/WaterLeak/WaterLeakSegment/WaterLeakSegment.tscn")
var segments = []

func on_splash_finished():
	for segment in segments:
		segment.visible = true
	match style:
		"01":
			$Splash01.play()
	
func on_splash(segment):
	var segment_index = 0
	for i in range(0, segments.size()):
		if segments[i] == segment:
			segment_index = i
			break
	for i in range(segment_index+1, segments.size()):
		segments[i].visible = false
	
func _ready():
	#var start_pos = -(num_segments*64)
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
	if segments.size() > 1:
		segments[-1].segment_type = "Finish"
	for seg in segments:
		add_child(seg)
		seg.sprite.animation_finished.connect(on_splash_finished)
