shader_type canvas_item;

const float M_PI = 3.1415926535897932384626433832795;
const float N = 9.0;
const float Nhat = N / (2.0 * M_PI);
const float MAX_R = 0.5;
const float d1overd2 = 1.075;
const float n = 2.0;
const float d2 = M_PI / (n - 1.0 + 2.0 * d1overd2);
const float d1 = d2 * d1overd2;
const float spikeLength = MAX_R * 0.5;
const float factor = spikeLength / (1.0 / (d1 - d2) + 1.0 / (2.0 * d1 - d2 - (d1 - d2)));

uniform vec4 cell_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float cell_radius : hint_range(0.1, 1.0) = 0.4;

void fragment() {
	// Remap UV from [0,1] to [-1,1] centered local space
	vec2 p = (UV - 0.5) * 2.0;
	
	float lp = length(p);
	float d = lp - cell_radius + 0.0001;

	if (d < 0.0) {
		discard;
	}
	float phi = atan(p.y, p.x);
	float phif = floor(phi * Nhat) * (1.0 / Nhat);
	float a = 2.0 * Nhat * (phi - phif);
	
	float x = (1.0 - a) * cell_radius * M_PI / N;
	float angle = atan(d, x);
	if (angle > 0.5 * M_PI) {
	angle = M_PI - angle;
	}
	if (angle > d1) {
		angle = fract((angle - d1) / d2) * d2 + d1 - d2;
	}
	
	float ml = (1.0 / angle + 1.0 / (2.0 * d1 - d2 - angle)) * factor;
	
	COLOR.rgb = cell_color.rgb;
	COLOR.a = (x * x + d * d < ml * ml) ? 1.0 : 0.0;
}