shader_type canvas_item;

const float M_PI = 3.1415926535897932384626433832795;
const float scale = 50.0;
const float NR = 0.005 * scale;
const float EW = 0.002 * scale;
const float EWH = 0.001 * scale;
const float ratio = 2.0 * sin(M_PI / 3.0);
const float N = 6.0;
const float iN = N * ratio * 0.5 / M_PI;
const float L2 = 0.4;
const float L1 = 0.08 * 0.7;

uniform vec4 cell_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float cell_radius : hint_range(0.1, 2.5) = 2.0;
uniform float tp : hint_range(0.0, 2.5) = 1.5;
uniform vec4 aux = vec4(0.0, 0.0, 0.0, 0.0); //Edit the X and W to adjust its color
uniform vec4 aux2 = vec4(0.0, 0.0, 0.0, 0.0); // aux2.x = S2, aux2.w = S3

void fragment() {
	vec2 p = (UV - 0.5) * 2.0 * cell_radius;
	float ds = dot(p, p);
	if (ds > cell_radius * cell_radius) {
		discard;
	}
	float srr = max(ds / ((cell_radius - EW) * (cell_radius - EW)),
					EW / max(EWH, cell_radius - tp));
	vec2 stc = p * max(tp / sqrt(ds), 1.0);
	float r = length(stc);
	float rho = (r - NR) / (cell_radius - NR - EW) - 0.5;
	float theta = (atan(p.x, p.y) + aux.z) * (N * 0.5 / M_PI);
	float part = floor(theta);
	vec2 p1 = vec2(rho, (theta - part - 0.5) * 2.0);
	float minr = dot(p1, p1);
	if (ds > NR * NR) {
		if (minr < L2 * L2) {
			float comp = max(L2 - L1 / r, 0.0);
	if (minr < comp * comp) {
		float mpart = mod(part, 2.0);
		float f;
		vec3 signal_color;
		bool inner = rho < 0.0;
		if (mpart == 0.0) {
			if (inner) {
				f = aux.x;
				signal_color = f > 0.0 ? vec3(0.83, 0.7, 0.0) : vec3(0.83, 0.0, 0.7);
			} else {
				f = aux2.x;
				signal_color = f > 0.0 ? vec3(1.0, 0.4, 0.1) : vec3(0.4, 0.1, 1.0);
			}
		} else {
			if (inner) {
				f = aux.w;
				signal_color = f > 0.0 ? vec3(0.42, 0.7, 1.0) : vec3(0.7, 1.0, 0.42);
			} else {
				f = aux2.w;
				signal_color = f > 0.0 ? vec3(1.0, 0.2, 0.5) : vec3(0.2, 1.0, 0.5);
			}
		}
	COLOR.rgb = mix(vec3(1.0), signal_color, abs(f));
	COLOR.a = 1.0;
	} else {
				COLOR.rgb = cell_color.rgb * 0.5;
				COLOR.a = 1.0;
			}
		} else {
			discard;
		}
	} else {
		discard;
	}
}