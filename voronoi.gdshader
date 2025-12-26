shader_type canvas_item;

const int MAX_CELL_COUNT = 8;

uniform int cell_count = 0;
uniform vec2 centers[MAX_CELL_COUNT];
uniform float rotations[MAX_CELL_COUNT];
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
void fragment() {
    vec2 uv = UV;

    for (int i = 0; i < MAX_CELL_COUNT; i++) {
        if (i >= cell_count) {
            break;
        }
		
        vec2 pos = uv - centers[i];

        float cos_a = cos(-rotations[i]);
        float sin_a = sin(-rotations[i]);

        vec2 rotated = vec2(
            pos.x * cos_a - pos.y * sin_a,
            pos.x * sin_a + pos.y * cos_a
        );

        // Same logic you already had
        if (rotated.x > 0.0) {
            discard;
        }
    }

    // survived all cuts
    COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
}
