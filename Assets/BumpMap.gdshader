shader_type canvas_item;

uniform sampler2D bump_map;
uniform float strength : hint_range(0.0, 5.0) = 1.0;
uniform float baseline = 0.66;
uniform vec4 modulate = vec4(1.0);
/*void fragment ()
{
	COLOR = texture(bump_map, UV);
}*/
void light() 
{
    vec4 base_color = texture(TEXTURE, UV);

    float mask = texture(bump_map, UV).r;

    float brightness =  baseline + mask * strength;
    vec3 brightened_color = base_color.rgb * brightness;

    LIGHT = vec4(clamp(brightened_color, 0.0, 1.0), base_color.a) * modulate;
}