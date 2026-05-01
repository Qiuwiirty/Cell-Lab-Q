shader_type canvas_item;

uniform sampler2D rho_lut : filter_linear, repeat_disable;
uniform vec4 cell_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float cell_radius : hint_range(0.0, 0.4753) = 20.0;
uniform float death_progress : hint_range(0.0, 35.0) = 0.0;
//At death progress 35, it's truly dissapear
//And at 0.4753, it can fit all the effect without dissapear
float rho(float r2, float st) {
	return texture(rho_lut, vec2(r2 * 0.22596, st * 0.285212)).r;
}

void fragment() {
	vec2 offset = (UV - vec2(0.5)) * 2.0 / cell_radius;
	float ds = dot(offset, offset);
	
	float st = death_progress * 0.105185;
	float Ri = 1.0;
	
	const float ratio = 0.4;
	vec3 out_rgb = (ratio * 0.5 + (1.0 - ratio)) * cell_color.rgb;
	float out_a  = (ratio + 0.5 * (1.0 - ratio)) * rho(ds, st * Ri);
	
	COLOR = vec4(out_rgb, out_a);
}