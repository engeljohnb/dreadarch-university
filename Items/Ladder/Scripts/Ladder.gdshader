shader_type canvas_item;
uniform sampler2D trans_mask;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (UV.y > 0.5)
		COLOR.a = texture(TEXTURE, UV).a - (UV.y-0.5);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
