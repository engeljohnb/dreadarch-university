extends Node

var weather_timer = 0.0
var cloud_density : float = 0.627

func get_cloud_density() -> float:
	return cloud_density
	
func update_weather_timer(delta):
	weather_timer += delta
	
func update_weather():
	if weather_timer >= 5.0*60.0:
		weather_timer = 0.0
		cloud_density = randf()
	
func _process(delta):
	update_weather_timer(delta)
	update_weather()
