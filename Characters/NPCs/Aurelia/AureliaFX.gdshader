shader_type canvas_item;
uniform float spotlight_size;
uniform float spotlight_2_scale;
uniform int distance_from_center_xp;
uniform float max_distance_from_center;
uniform bool inverted;
uniform sampler2D noise;

void fragment() {
	float scale = 0.0155;
	vec2 uv = UV*scale;
	float dist_from_center = distance(uv,vec2(0.5,0.5));
	if (inverted)
	{
		dist_from_center = 1.0 - dist_from_center;
	}
	float alpha = texture(noise, uv).a;
	float spotlight = smoothstep(0.0, spotlight_size, dist_from_center+(alpha/4.0));
	// To change it so there's no faint noise in the BG, make it dist_from_center instead of dist_from_center*alpha
	float radius = dist_from_center;
	for (int i = 0; i < distance_from_center_xp; ++i)
	{
		radius *= radius;
	}
	float spotlight2 = smoothstep(0.0, spotlight_size, radius*(alpha*spotlight_2_scale));
	vec4 c = vec4(0.05,0.05,0.05,1.0);
	c.a = step(0.2, smoothstep(alpha, 1.0, spotlight)) + spotlight2;
	if (dist_from_center > max_distance_from_center)
	{
		c.a = 0.0;
	}
	COLOR = c;
}
