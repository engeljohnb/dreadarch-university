extends Node2D

signal dead()
var _segment = load("res://Characters/Player/LifebarSegment.tscn")
var total_life = 3
var life = 3
var rects = []

func set_life_total(lt):
	total_life = lt
	life = lt
	var seg_count = lt+1
	
	var left_segment = _segment.instantiate()
	var right_segment = _segment.instantiate()
	right_segment.position.x += (seg_count - 2) * 40
	add_child(left_segment)
	add_child(right_segment)
	left_segment.play("Left")
	right_segment.play("Right")
	seg_count -= 2
	
	for i in range(0, seg_count):
		var middle_segment = _segment.instantiate()
		middle_segment.position.x += (i*40)
		middle_segment.play("Middle")
		add_child(middle_segment)
	
	for i in range(0, lt):
		var rect = ColorRect.new()
		rect.color = Color(0.6,0.1,0.05, 0.8)
		rect.position = Vector2(-20,-20)
		rect.size = Vector2(40,40)
		rect.position.x += (i*40)
		rect.z_index = -1
		add_child(rect)
		rects.append(rect)

func on_hit():
	for i in range(life-1, total_life):
		rects[i].color = Color(0.5,0.5,0.5)
	life -= 1
	if life <= 0:
		dead.emit()
