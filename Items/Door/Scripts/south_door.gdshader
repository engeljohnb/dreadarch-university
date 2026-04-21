shader_type canvas_item;
uniform sampler2D mask;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 muv = UV;
	muv.y = 1.0 - muv.y;
	COLOR = texture(TEXTURE, UV);
	COLOR.a = texture(mask, muv).a;
//	if (COLOR.a < 1.0)
//	{
//		COLOR.a = 0.0;
//	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
