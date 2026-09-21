shader_type canvas_item;
uniform sampler2D animation_frames[3];

const vec2 scale = vec2(0.008333, 0.0148148)*8.0;

void vertex() {
	// Called for every vertex the material is visible on.
}
float rand(vec2 value) 
{
    return fract(sin(dot(value.xy, vec2(13,80))) * 4000.0);
}

void fragment() {
	vec2 positions[64];
	vec4 color = vec4(0.0);
	for (int i=0; i<64; ++i)
	{
		int x_i = i % 8;
		int y_i = i / 8;
		float x = mix(0.0, -16.0, float(x_i)/8.0);
		float y = mix(0.0, -16.0, float(y_i)/8.0);
		int r = int(round(rand(vec2(x,y)))) % 3;
		positions[i] = vec2(x, y);
		vec2 uv = positions[i] + (UV*scale);
		color *= texture(animation_frames[r], uv);
	}
	COLOR = color;
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
