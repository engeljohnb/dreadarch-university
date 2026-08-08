shader_type canvas_item;

uniform float max_distance_from_center;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float scale = 0.0155;
	vec2 uv = UV*scale;
	float dist_from_center = distance(UV,vec2(0.5,0.5)); 
	
	if (dist_from_center > max_distance_from_center)
	{
		COLOR.a = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
