shader_type canvas_item;
//MAKE VORONOI EFFECT CELLS! (Cell are just simple circle with radius of 20x20)
const int MAX_CELL_COUNT = 8; //Maximum the voronoi this cell can handle (Usually 8)

uniform int cell_count = 0; //Current count collision with cells for the loops
uniform vec2 centers[MAX_CELL_COUNT]; //The midpoint intersections between this cells and the other cells, and use it for position of the slice
uniform float rotations[MAX_CELL_COUNT]; //The rotation to the other cells to make the slice effect
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
void fragment() {
    for (int i = 0; i < MAX_CELL_COUNT; i++) {
        if (i >= cell_count) {
            break;
        }

        vec2 pos = UV - centers[i];
		//Math stuff that make the slicing work (I don't understand it :P)
        float cos_a = cos(-rotations[i]);
        float sin_a = sin(-rotations[i]);

        vec2 rotated = vec2(
            pos.x * cos_a - pos.y * sin_a,
            pos.x * sin_a + pos.y * cos_a
        );

        // Slice it
        if (rotated.x > 0.0) {
            discard;
        }
    }

    // survived all cuts
    COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
}
