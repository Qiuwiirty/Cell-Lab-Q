shader_type canvas_item;

uniform float N : hint_range(1., 10.) = 5.0;
uniform int MAX_IT : hint_range(1, 20) = 9;
// d_scale replaces the original yscale — 0.01 is the correct value
uniform float d_scale : hint_range(0.001, 1.0) = 0.01;
uniform vec3 color: source_color;

float GiveCx(float x, float y) {
	return (y*y*y*y - 4.0*y*y*y + (2.0*x*x+2.0)*y*y + (4.0-4.0*x*x)*y + x*x*x*x + 6.0*x*x - 3.0)
		  /(4.0*y*y*y*y - 16.0*y*y*y + (8.0*x*x+24.0)*y*y + (-16.0*x*x-16.0)*y + 4.0*x*x*x*x + 8.0*x*x + 4.0);
}

float GiveCy(float x, float y) {
	return -(2.0*x*y - 2.0*x)
		   /(y*y*y*y - 4.0*y*y*y + (2.0*x*x+6.0)*y*y + (-4.0*x*x-4.0)*y + x*x*x*x + 2.0*x*x + 1.0);
}

void fragment() {
	// center UV, p is offset from cell center
	vec2 p = (UV - 0.5) * 2.0;
	float cell_r = 0.675; // radius in UV space, leaving slight margin

	float dist = length(p) - cell_r;

	// discard deep interior (hollow out the inside of the ring)
	if (dist < -0.05 * cell_r) {
		discard;
	}

	float Nhat = N / (2.0 * PI);

	// N-fold angle fold
	float a = 2.0 * fract(atan(p.y, p.x) * Nhat);
	if (a > 1.0) a = 2.0 - a;

	vec2 c = vec2(GiveCx(1.563 + a/3.0, dist * d_scale),
				  GiveCy(1.563 + a/3.0, dist * d_scale));
	vec2 z = c;

	for (int i = 0; i < MAX_IT; i++) {
		z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
		z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
		z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
		z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
		if (dot(z,z) > 4.0) { z = vec2(2.0, 2.0); break; }
	}

	if (dot(z,z) > 4.0) {
		discard;
	} else {
		COLOR.rgb = color;
		COLOR.a = 1.0;
	}
}