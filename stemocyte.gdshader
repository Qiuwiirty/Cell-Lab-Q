shader_type canvas_item;

const float SCALE = 50.0;
const float NR    = 0.005 * SCALE;
const float EW    = 0.002 * SCALE;
const float EWH   = 0.001 * SCALE;

uniform float u_tp           : hint_range(0.0, 50.0) = 0.0;
uniform float red_substance  : hint_range(0.0, 5.0)  = 0.75;
uniform float blue_substance : hint_range(0.0, 5.0)  = 0.75;
uniform float u_Phi          : hint_range(0.0, 6.28) = 0.0;
uniform float width          : hint_range(0.1, 5.0)  = 1.0;

void fragment() {
	vec4  col = COLOR;
	col.a    *= SCALE;
	
	vec2  p   = (UV * 2.0 - 1.0) * SCALE;
	float tp  = u_tp;
	float r1  = red_substance;
	float r2  = blue_substance;
	float Phi = u_Phi;
	
	float ds  = dot(p, p);
	float srr = max(
		ds / ((col.a - EW) * (col.a - EW)),
		EW / max(EWH, col.a - tp)
	);
	
	vec2  stc = p * max(tp / sqrt(max(ds, 0.0001)), 1.0);
	float r   = length(stc);
	
	if (r > col.a) { discard; }
	
	float rho   = log((col.a - NR) / max(r - NR, 0.0001));
	float theta = atan(stc.x, stc.y) + Phi;
	if (theta >  PI) theta -= 2.0 * PI;
	if (theta < -PI) theta += 2.0 * PI;
	
	vec2  p2 = vec2(rho - r2, theta / width);
	float a  = theta > 0.0 ? theta - PI : theta + PI;
	vec2  p1 = vec2(rho - r1, a / width);
	
	if (ds < 64.0) { discard; }
	
	if (ds > NR * NR) {
		if (srr < 1.0) {
			if (r1 > 0.0001 && dot(p1, p1) / (r1 * r1) < 1.0) {
				COLOR = vec4(col.rgb * 0.75 + vec3(0.3, 0.0, 0.0), 1.0);
			} else if (r2 > 0.0001 && dot(p2, p2) / (r2 * r2) < 1.0) {
				COLOR = vec4(col.rgb * 0.75 + vec3(0.0, 0.0, 0.3), 1.0);
			} else {
				discard;
			}
		} else {
			discard;
		}
	} else {
		discard;
	}
}
