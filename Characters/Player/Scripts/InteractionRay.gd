extends Area2D

@onready var icon = $InteractionIcon
const default_alpha = 0.66
var using_item : Variant = null
var using_item_count = 1
var positive_color : Color = Color(0.2,0.85,0.2)
var negative_color : Color = Color(0.85,0.2,0.2)
var _timer := 0.0
var _blinking := false
var _blink_duration := 0.5
var _icon_state := false
var _use_icon : Sprite2D
var enabled = true

func set_use_icon(item : Variant):
	if ItemCollection.is_document(item):
		item = ItemCollection.SCROLL_FRAGMENT
	if item == null:
		if _use_icon != null:
			_use_icon.queue_free()
	else:
		_use_icon = Sprite2D.new()
		_use_icon.texture = ItemCollection.textures[item]
		_use_icon.modulate.a = 0.66
		$InteractionIcon.add_child(_use_icon)
	
func check_for_interactable():
	if (not has_overlapping_areas()) and not (has_overlapping_bodies()):
		_icon_state = false
		return
	var interactable = null
	if has_overlapping_bodies():
		for i in get_overlapping_bodies():
			if i.is_in_group("Interactable"):
				interactable = i
	if has_overlapping_areas():
		for i in get_overlapping_areas():
			if i.is_in_group("Interactable"):
				interactable = i
	if interactable == null:
		return
	if interactable.is_in_group("Interactable"):
		if enabled:
			interactable.activate(using_item, using_item_count)
		_icon_state = true
	else:
		_icon_state = false

				
func check_for_collectible():
	var has_areas = has_overlapping_areas()
	var has_bodies = has_overlapping_bodies()
	if (not has_areas) and not (has_bodies):
		_icon_state = false
	if not has_areas:
		return
	var area = get_overlapping_areas()[0]
	if area is Collectible:
		area.collect()
		_icon_state = true

func should_update_state():
	return (not _blinking) and (not get_parent().in_dialogue) and (not get_parent().in_cutscene)
	
func _process(_delta):
	if should_update_state():
		icon.self_modulate = Color.WHITE
		icon.self_modulate.a = default_alpha
		if Input.is_action_just_pressed("Interact"):
			set_use_icon(null)
			# I still want the animation to play when a notification pops up
			if not get_tree().paused:
				check_for_interactable()
				check_for_collectible()
			else:
				return
			# Here because there's one part when meeting Aurelia
			#  when the player sits, and I don't want them to be able 
			#  to click while sitting, and this is the only way to check
			#  without breaking the cursor in other situations.
			if not get_parent()._waiting_to_stand:
				_blinking = true
	if _blinking:
		if _timer >= _blink_duration:
			_timer = 0.0
			_blinking = false
		blink_icon(_icon_state)
		_timer += _delta

func blink_icon(state : bool):
	if state:
		icon.self_modulate = positive_color
	else:
		icon.self_modulate = negative_color
	var padink = Utils.padink(_timer, _blink_duration, 0.3, 1.5, 2.0, 0.0, 0.66)
	icon.self_modulate.a = padink
