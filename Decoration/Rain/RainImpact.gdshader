shader_type canvas_item;
uniform int animation_track_id = 0;
uniform sampler2D animation_track_1;
uniform sampler2D animation_track_2;
uniform sampler2D animation_track_3;

void fragment() {
	vec4 color = vec4(0);
	switch (animation_track_id)
	{
		case 0:
			color = texture(animation_track_1, UV);
			break;
		case 1:
			color = texture(animation_track_2, UV);
			break;
		case 2:
			color = texture(animation_track_3, UV);
			break;
	}
	COLOR = color;
}