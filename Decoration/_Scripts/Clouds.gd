extends PointLight2D
class_name CloudShadow

var wind_speed : float = 5.0
var wind_direction : Vector2 = Vector2(1.0,1.0)
var _prev_player_pos := Vector2()
var max_cloud_density : float = 0.66
var min_cloud_density : float = 0.33
var middle_color : Color = Color(0.647, 0.647, 0.647)


func _ready():
	var noise : NoiseTexture2D = texture
	var cd = randf()#WorldTimers.cloud_density
	var colors : PackedColorArray = texture.color_ramp.get_colors()
	if cd > max_cloud_density:
		colors.set(2, Color.TRANSPARENT)
	elif cd < min_cloud_density:
		colors.set(0, Color.WHITE)
		colors.set(1, Color.WHITE)
	else:
		colors.set(1, middle_color)
	noise.color_ramp.set_colors(colors)
	#gradient.set_offsets([0.0, WorldTimers.cloud_density, 1.0])
	#gradient.set_offsets([0.0, randf_range(WorldTimers.min_cloud_density, WorldTimers.max_cloud_density), 1.0])

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
	_prev_player_pos = player_pos

func disable():
	visible = false
func enable():
	visible = true
