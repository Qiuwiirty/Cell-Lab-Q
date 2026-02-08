shader_type canvas_item;
//MAKE VORONOI EFFECT CELLS! (Cell are just simple circle with radius of 15)
//For each cell assign this shader
const int MAX_CELL_COUNT = 8; //Maximum the voronoi this cell can handle (Usually 8)

uniform int cell_count = 0; //Current count collision with cells for the loops
uniform vec2 centers[MAX_CELL_COUNT]; //The midpoint intersections between this cells and the other cells, and use it for position of the slice
uniform float rotations[MAX_CELL_COUNT]; //The rotation to the other cells to make the slice effect
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 screen_size;

void fragment() {
	if(cell_count != 0)
	{
		vec2 uv = SCREEN_UV;

		// aspect correction
		float aspect = screen_size.x / screen_size.y;
		uv.x *= aspect;

		for (int i = 0; i < MAX_CELL_COUNT; i++) {
			if (i >= cell_count) break;

			vec2 c = centers[i];
			c.x *= aspect;

			vec2 pos = uv - c;

			float cos_a = cos(-rotations[i]);
			float sin_a = sin(-rotations[i]);

			vec2 rotated = vec2(
				pos.x * cos_a - pos.y * sin_a,
				pos.x * sin_a + pos.y * cos_a
			);

			if (rotated.x > 0.0) {
				discard;
			}
		}
	}
	//Literally just copy the background and then render it. Inefficient and NEED TO BE CHANGED
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
}
