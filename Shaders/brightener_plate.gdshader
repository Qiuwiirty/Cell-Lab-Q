shader_type canvas_item;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	tex.rgba *= brightness;
	COLOR = tex;
}

