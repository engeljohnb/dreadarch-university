shader_type canvas_item;

void fragment(){
	float lod = 0.25;
	vec4 color = texture(TEXTURE, UV);
	vec4 _modulate = vec4(0.19, 0.11, 0.19, 1.0);
	COLOR = vec4(1.0 - color.rgb, color.a)*_modulate;
}
