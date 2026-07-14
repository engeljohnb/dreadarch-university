extends Node2D
# Right now this only handles the sound components on enemies.

# Why here instead of letting enemies handle their own sounds?
#  Because it's ridiculously loud when two or three enemies do the same
#  action at the same time. Having each sound component be one shared instance
#  makes it so the sound is only played once at a time even if multiple enemies are doing
#  the same action.

var sound_components : Dictionary[int, EnemySoundComponent]

func create_sound_component(type : int):
	var sc : EnemySoundComponent = EnemySoundComponent.create()
	match type:
		Enemy.Types.CROW:
			sc.transform_into_crow_sound_component()
		Enemy.Types.SLACK:
			sc.transform_into_slack_sound_component()
		Enemy.Types.GLOP:
			sc.transform_into_glop_sound_component()
	return sc
			
			
func _ready():
	if not get_orphan_node_ids().is_empty():
		for id in get_orphan_node_ids():
			var inst = instance_from_id(id)
			if is_instance_valid(inst):
				inst.free()
	for child in get_children():
		assert(child is Enemy)
		var sc = sound_components.get(child.type)
		if sc == null:
			sound_components[child.type] = create_sound_component(child.type)
			sc = sound_components[child.type]
			call_deferred("add_sibling", sc)
		child.sound_component = sc
			
func _process(_delta):
	for child in get_children():
		assert(child is Enemy)
		child.sound_component.update(child.current_action, child.get_action_length(), child.global_position)
