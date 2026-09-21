extends PointLight2D
class_name CloudShadow

var wind_speed : float = 5.0
var wind_direction : Vector2 = Vector2(1.0,1.0)
var _prev_player_pos := Vector2()
var middle_color : Color = Color(0.647, 0.647, 0.647)


func update():
	var colors : PackedColorArray = texture.color_ramp.get_colors()
	energy = lerp(0.0, 0.75, 1.0 - WorldTimers.cloud_density)
	
	if WorldTimers.is_raining:
		colors.set(0, Color.WHITE)
		colors.set(1, Color.WHITE)
		colors.set(2, Color.WHITE)
		energy = 0.01
		return
	var noise : NoiseTexture2D = texture
	var cd = WorldTimers.cloud_density
	var _color = lerp(Color.WHITE, Color.TRANSPARENT, cd)
	colors.set(1, Color.TRANSPARENT)
	colors.set(2, _color)
	noise.color_ramp.set_offset(1, clamp(WorldTimers.cloud_density, 0.1, 0.9))
	var mc = lerp(Color.WHITE, middle_color,  WorldTimers.cloud_density)
	colors.set(1, mc)
	noise.color_ramp.set_colors(colors)

func _process(_delta):
	if texture == null:
		return
	if texture is not NoiseTexture2D:
		return
	var player_pos = Utils.player_position
	var player_disp = player_pos - _prev_player_pos
	player_disp /= Vector2(960.0/512.0, 540.0/512.0)
	var noise : FastNoiseLite = texture.noise
	var displacement : Vector2 = wind_direction * wind_speed * _delta
	noise.offset.x += displacement.x + player_disp.x
	noise.offset.y += displacement.y + player_disp.y
	update()
	_prev_player_pos = player_pos

func disable():
	visible = false
func enable():
	visible = true
