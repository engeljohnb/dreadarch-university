shader_type canvas_item;
uniform sampler2D noise;
uniform float spotlight_size;

void fragment() {
	float scale = 0.0155;
	vec2 uv = UV*scale;
	float dist_from_center = distance(uv,vec2(0.5,0.5));
	float alpha = texture(noise, uv).a;
	float spotlight = smoothstep(0.0, spotlight_size, dist_from_center+(alpha/4.0));
	// To change it so there's no faint noise in the BG, make it dist_from_center instead of dist_from_center*alpha
	float spotlight2 = smoothstep(0.0, spotlight_size, dist_from_center*(alpha*1.5));
	vec4 c = vec4(0.05,0.05,0.05,1.0);
	c.a = step(0.2, smoothstep(alpha, 1.0, spotlight)) + spotlight2;
	COLOR = c;
}
