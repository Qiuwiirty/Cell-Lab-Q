shader_type canvas_item;
//not borrowed from cell lab
uniform float radius = 0.5;
void fragment() {
	vec2 offset = UV - vec2(0.5, 0.5);
	float dist_squared = dot(offset, offset); 
	if (dist_squared < 0.08 * 0.08) //make a hole for nucleus
	{
		discard;
	}
	if (dist_squared < radius * radius) 
	{
		COLOR = vec4(0.55,0.4,0.3, 0.5);
	} else 
	{
		COLOR = vec4(0.0);
	}
}