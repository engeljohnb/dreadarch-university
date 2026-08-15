extends RayCast2D

@onready var icon = $InteractionIcon
var using_item : Variant = null
var using_item_count = 1
var positive_color : Color = Color(0.2,0.85,0.2)
var negative_color : Color = Color(0.85,0.2,0.2)
var _timer := 0.0
var _blinking := false
var _blink_duration := 0.5
var _icon_state := false

func check_for_interactable():
	if is_colliding(): 
		var col = get_collider()
		# IDk it randomly crashed once bc col was null. I think it's because it intersects with
		# ONe of the enemy's projectiles right as the enemy's killed -- freeing all the projectiles.
		if col == null:
			return
		# TODO: Would col is Interactable work?
		if col.is_in_group("Interactable"):
			_icon_state = true
			if not get_parent().in_dialogue:
				if "activate" in col:
					if not using_item == null:
						col.activate(using_item, using_item_count)
					else:
						col.activate()
				using_item = null
		else:
			_icon_state = false
	else:
		_icon_state = false
				
func _process(_delta):
	if Input.is_action_just_pressed("Interact"):
		icon.position = target_position
		check_for_interactable()
		_blinking = true
	if _blinking:
		if _timer >= _blink_duration:
			_timer = 0.0
			_blinking = false
		blink_icon(_icon_state)
		_timer += _delta
	else:
		icon.modulate.a = 0.0
		

	
func blink_icon(state : bool):
	if state:
		icon.modulate = positive_color
	else:
		icon.modulate = negative_color
	var padink = Utils.padink(_timer, _blink_duration, 0.3, 1.5, 2.0, 0.0, 0.66)
	icon.modulate.a = padink
