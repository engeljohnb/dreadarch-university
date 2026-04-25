shader_type canvas_item;
uniform float time;

mat2 rotate2(float angle)
{
    return mat2(vec2(cos(angle),-sin(angle)), vec2(sin(angle),cos(angle)));
}

/*float inside_circles()
{
	float circle
}*/

void vertex() {
	UV -= 0.5;
	UV *= rotate2(time);
	UV += 0.5;
	// Called for every vertex the material is visible on.
}
void fragment() {
    vec3 color = vec3(0.0);
	float offset = time;
	
	vec2 _uv = (UV - 0.5) * rotate2(sin(time*0.33));
	vec2 second_square_coords = _uv * rotate2(time);
	second_square_coords += 0.5;

	float x = (UV).x;
	float y = (UV).y;
	float _x = second_square_coords.x;
	float _y = second_square_coords.y;
	
	float size = 0.05;
	
    float left = step(0.5-size,x);
    float bottom = step(0.5-size,y); 
	float right = abs(step(0.5+size,x) - 1.0);
	float top = abs(step(0.5+size,y) - 1.0);
	
	float _left = step(0.5-size, _x);
	float _bottom = step(0.5-size, _y);
	float _right = abs(step(0.5+size, _x) - 1.0);
	float _top = abs(step(0.5+size, _y) - 1.0);

  //  color = vec3( left * bottom * top * right);
//	vec3 _color = vec3(_left * _bottom * _top * _right);

	
	color = vec3(mix(left, _left, 0.11)*
				 mix(bottom, _bottom, 0.9)*
				 mix(top, _top, 0.99)*
				 mix(right, _right, 0.04));
    COLOR = vec4(color,color.x);

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
