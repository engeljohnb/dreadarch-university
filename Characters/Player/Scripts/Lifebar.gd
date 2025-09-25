extends Node2D

var _segment = load("res://Characters/Player/LifebarSegment.tscn")
var total_life = 3
var life = 3
var temporary_life = 0
var rects = []
var outline_segs = []
var full_color = Color(0.6, 0.2, 0.15)
var temporary_life_color = Color(0.9, 0.8, 0.3)
var empty_color = Color(0.5,0.5,0.5)

func _ready():
	var viewport_size = get_viewport_rect().size
	position = viewport_size/10.0

func set_life_total(lt, _life = lt):
	for rect in rects:
		rect.queue_free()
	for seg in outline_segs:
		seg.queue_free()
	outline_segs = []
	rects = []
	
	total_life = lt
	life = _life - temporary_life
	var seg_count = lt+temporary_life+1
	var left_segment = _segment.instantiate()
	var right_segment = _segment.instantiate()
	right_segment.position.x += (seg_count - 2) * 40
	outline_segs.append(left_segment)
	left_segment.play("Left")
	right_segment.play("Right")
	seg_count -= 2
	
	for i in range(0, seg_count):
		var middle_segment = _segment.instantiate()
		middle_segment.position.x += (i*40)
		middle_segment.play("Middle")
		outline_segs.append(middle_segment)
	for i in range(0, lt+temporary_life):
		var rect = ColorRect.new()
		if i >= life:
			rect.color = empty_color
		else:
			rect.color = full_color
		if i >= lt:
			rect.color = temporary_life_color
		rect.position = Vector2(-20,-20)
		rect.size = Vector2(40,40)
		rect.position.x += (i*40)
		rect.z_index = -1
		add_child(rect)
		rects.append(rect)
	outline_segs.append(right_segment)
	for segment in outline_segs:
		add_child(segment)

func deduct_damage(damage):
	if temporary_life > 0:
		temporary_life -= damage
		set_life_total(total_life, total_life+temporary_life)
	else:
		life -= damage
		for i in range(0, damage):
			rects[life+i].color = empty_color
	
func gain_temporary_life(_life):
	life = total_life
	temporary_life += _life
	set_life_total(total_life, total_life+temporary_life)
	
func gain_life(_life):
	life += _life
	if life >= total_life:
		life = total_life
	for i in rects.size():
		if i >= life:
			rects[i].color = empty_color
		else:
			rects[i].color = full_color
		rects[i].queue_redraw()
			
