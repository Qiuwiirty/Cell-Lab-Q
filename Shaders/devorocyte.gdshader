shader_type canvas_item;
//this code is borrowed from cell lab
const float scale = 50.0;
const float N = 19.0;
const float Nhat = N / (2.0 * PI);
const float MAX_R = 0.03 * scale;
const float R = MAX_R * 0.04;
const float H = MAX_R * 0.3;
const float HW = MAX_R * 0.1 / 2.0;
const float X = HW + R * 0.84712708838;
const float x1 = X - R * 0.98639392383;

uniform vec4 cell_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float cell_radius : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 centered_uv = UV - vec2(0.5);
	vec2 p = centered_uv * scale * 2.0;
	vec2 tp = centered_uv * 2.0;
	float d = length(p) - cell_radius * scale;
	float a = 2.0 * fract(Nhat * atan(tp.y, tp.x));
	if (a > 1.0) a = 2.0 - a;
    
	float x = (1.0 - a) * cell_radius * scale * PI / N;
	float h;
    
	if (x < x1 || x > X) {
		h = H * (1.0 - x / HW);
	} else {
	h = R - sqrt(R * R - (x - X) * (x - X));
	}
	if (d < h) {
		COLOR = vec4(cell_color.rgb, 1.0);
	} else {
		discard;
	}
}