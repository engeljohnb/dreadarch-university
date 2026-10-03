extends Node

var weather_timer : float = 100.0
var cloud_density : float = 0.0#0.627
var rain_threshold : float = 0.8
var shine_threshold : float = 0.2
var is_raining : bool = false

func get_cloud_density() -> float:
	return cloud_density
	
func update_weather_timer(delta):
	weather_timer += delta

func get_cloud_density_at(time : float) -> float:
	var cloud_timer = time * 0.0075
	return ((1.0 + sin(cloud_timer - 7.0)) * 0.5) ** 2.75

func update_weather():
	cloud_density = get_cloud_density_at(weather_timer)
	is_raining = false
	if cloud_density >= rain_threshold:
		is_raining = true
	
func _process(delta):
	update_weather_timer(delta)
	update_weather()
