shader_type canvas_item;
render_mode blend_add;
uniform vec4 u_color : source_color = vec4(1.0, 0.9, 0.7, 1.0);
uniform float u_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float u_falloff : hint_range(0.1, 10.0) = 2.0; // higher = sharper fade

void fragment() {
    vec2 p = UV - vec2(0.5);
    float dist = length(p) * 2.0; // 0 at center, 1 at edge
    
    float light = pow(1.0 - clamp(dist, 0.0, 1.0), u_falloff) * u_intensity;
    
    COLOR = vec4(u_color.rgb * light, light);
}