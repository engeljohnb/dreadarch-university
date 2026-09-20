shader_type canvas_item;
uniform sampler2D noise;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}
void fragment() {
	vec2 uv = UV/vec2(960.0/4.0, 540.0/4.0);
	vec3 base_color = texture(SCREEN_TEXTURE, uv).rgb;
	float shadow_strength = texture(noise, uv).r;
	vec3 color = mix(base_color, base_color * shadow_strength, 0.33);
	COLOR = vec4(color, 1.0);
}

void light() {
	/*vec2 uv = UV/vec2(960.0/4.0, 540.0/4.0);
	LIGHT *= texture(noise, uv);*/
}
