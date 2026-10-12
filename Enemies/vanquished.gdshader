shader_type canvas_item;


uniform sampler2D bump_map;
uniform float strength : hint_range(0.0, 5.0) = 1.0;
uniform float baseline = 0.66;
uniform vec4 modulate = vec4(1.0);

uniform float dissolve_value : hint_range(0.0, 1.0);
uniform float mix_ratio : hint_range(0, 1.0);
uniform sampler2D dissolve_noise;
uniform sampler2D dissolve_gradient;

vec3 invert(vec3 x)
{
	return vec3(1.0 - x.r, 1.0 - x.g, 1.0 - x.b);
}

void fragment() {
	vec4 main_texture = texture(TEXTURE, UV);
	vec4 a = texture(dissolve_noise, UV);
	vec4 b = texture(dissolve_gradient, UV);
	//b.rgb = invert(b.rgb);
	vec4 noise_texture = mix(a,b, mix_ratio);
	main_texture.a *= floor(dissolve_value + min(1, noise_texture.x));
	main_texture.rgb = mix(main_texture.rgb, vec3(0), 2.75 - (dissolve_value*2.0));
	COLOR = main_texture;
}

void light() 
{
    vec4 base_color = texture(TEXTURE, UV);

    float mask = texture(bump_map, UV).r;

    float brightness =  baseline + mask * strength;
    vec3 brightened_color = base_color.rgb * brightness;

    LIGHT = vec4(clamp(brightened_color, 0.0, 1.0), base_color.a) * modulate;
}