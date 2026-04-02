shader_type canvas_item; uniform sampler2D t: hint_screen_texture, filter_linear_mipmap;
void fragment(){COLOR = vec4(textureLod(t, SCREEN_UV, 3.0).rgb, 1.0);}
//code borrowed from some godot forums online. this might be slightly expensive but probably the best it can get