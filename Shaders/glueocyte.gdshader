shader_type canvas_item;

uniform vec3  cell_color : source_color = vec3(0.5, 0.5, 0.5);
uniform float cell_rot  = 0.0; //for now it's unused
uniform vec2  cell_move = vec2(0.0);

const float cell_radius = 1.0;
const float N     = 33.0;
const float Nhat  = N / (2.0 * PI);
const float MAX_R = 0.03 * 50.0;
const float R_C   = MAX_R * 0.02;
const float H     = MAX_R * 0.4;
const float HW    = MAX_R * 0.1 / 4.0;
const float X_VAL = HW + R_C * 0.93945122136;
const float x1    = X_VAL - R_C * 0.99805257848;

void fragment() {
	float margin = 0.625;
	vec2 uv = (UV * 2.0 - 1.0) / margin;
	
	float d = length(uv) - cell_radius;
	
	// Wobble pass 1
	float side = (cell_rot + dot(cell_move, vec2(-uv.y, uv.x)) / cell_radius)
	             * d / cell_radius * 30.0;
	d = sqrt(d * d + side * side * cell_radius * cell_radius);
	
	// Wobble pass 2 (same as original — run twice for stability)
	side = (cell_rot + dot(cell_move, vec2(-uv.y, uv.x)) / cell_radius)
	       * d / cell_radius * 30.0;
	d = sqrt(d * d + side * side * cell_radius * cell_radius);
	
	float a = 2.0 * fract(Nhat * (atan(uv.y, uv.x) - side));
	if (a > 1.0) a = 2.0 - a;
	
	float x = (1.0 - a) * PI / N;
	float h;
	if (x < x1 || x > X_VAL) {
		h = H * (1.0 - x / HW);
	} else {
		h = R_C - sqrt(max(0.0, R_C * R_C - (x - X_VAL) * (x - X_VAL)));
	}
	
	float edge_dist = d * cell_radius;
	
	COLOR.rgb = cell_color;
	COLOR.a = (edge_dist >= 0.0 && edge_dist < h) ? 1.0 : 0.0;
}