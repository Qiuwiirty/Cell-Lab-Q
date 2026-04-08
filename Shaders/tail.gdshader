shader_type canvas_item;
//borrowed from cell lab
uniform float t = 0.0;
uniform float cell_radius = 0.5;
uniform vec4 color : source_color = vec4(0.4, 0.6, 1.0, 1.0);

const float scale = 50.0;
//const float EW = 0.002 * scale; 
const float END = 0.7;
const float R = 0.1;
const float TAIL_R = 4.0;

void fragment() {
	vec2 tp = vec2(UV.x * TAIL_R, (UV.y - 0.5) * TAIL_R);
    
	vec2 p = vec2(tp.x + cell_radius * scale, tp.y);
	float d = length(p);
    
	float cr = cell_radius * scale;
    
    // wiggle wiggle wiggle
	float ww = (TAIL_R - tp.x) * 0.1 * (d - cr) / cr;
	float my = sin(-t + tp.x * 4.0) * ww;
	float k = 4.0 * cos(-t + tp.x * 4.0) * ww;
	float w = (1.0 - tp.x / (TAIL_R * END)) * 0.3 * (1.0 + 0.5 * k * k);
    
	float rim = (d - cr) / cr;
	if (rim < R) {
		w += R - R * sqrt(1.0 - (1.0 - rim / R) * (1.0 - rim / R));
	}
    
	if (abs(tp.y - my) < w && tp.x / (TAIL_R * END) < 1.0) {
		COLOR = vec4(color.rgb, 1.0);
	} else {
		COLOR = vec4(0.0);
	}
}