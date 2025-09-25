shader_type canvas_item;

// Uniforms for customization
uniform sampler2D noise_texture : repeat_enable;
uniform sampler2D portrait;
uniform vec3 smoke_color : source_color = vec3(0.8);
uniform float distortion_speed : hint_range(0.0, 5.0) = 0.2;
uniform float density : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // Pre-calculate time-based offsets
    float time_offset_1 = TIME * distortion_speed * 0.1;
    float time_offset_2 = TIME * distortion_speed * 0.2;
    
    // Sample noise with distortion
    vec4 noise = texture(noise_texture, UV + time_offset_1);
    
    // Create distorted UV and sample final noise
    vec2 distorted_uv = UV + noise.rg * 0.1 - 0.05 + time_offset_2;
    float final_noise = texture(noise_texture, distorted_uv).r;
    
    float smoke_alpha = final_noise * density;
	float portrait_alpha = texture(portrait, UV).a;
	vec3 portrait_color = texture(portrait, UV).rgb;
	float average_alpha = (smoke_alpha+portrait_alpha)/2.0;
	float offset = 0.5;
	vec3 average_color = (smoke_color*texture(portrait, UV).rgb)/2.0;
	float final_alpha = mix(average_alpha, 0.0, max( max(abs(1.0-UV.x), abs(0.75-UV.y)), max(abs(UV.x), abs(UV.y))));
    // Output color

	COLOR = vec4(average_color, final_alpha);
}