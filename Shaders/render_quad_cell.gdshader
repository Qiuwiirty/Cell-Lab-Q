shader_type canvas_item;
//MAKE VORONOI EFFECT CELLS! (Cell are just simple circle with radius of 15)
//For each cell assign this shader
const int MAX_CELL_COUNT = 8; //Maximum the voronoi this cell can handle (Usually 8)

uniform vec3 u_color = vec3(1.0,1.0,1.0);
uniform sampler2D decoration: filter_nearest, repeat_disable;
uniform float u_use_decoration: hint_range(0.0, 1.0, 1.0) = 0.0; //0.0 = Off 1.0 = On
uniform int cell_count = 0; //Current count collision with cells for the loops
uniform vec2 centers[MAX_CELL_COUNT]; //The midpoint intersections between this cells and the other cells, and use it for position of the slice
uniform vec2 rot_dirs[MAX_CELL_COUNT];
uniform float u_size_mult: hint_range(0.0, 1.0);
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

			vec2 dir = rot_dirs[i];

			vec2 rotated = vec2(
			    pos.x * dir.x + pos.y * dir.y,
			   -pos.x * dir.y + pos.y * dir.x
			);


			if (rotated.x > 0.0) {
				discard;
			}
		}
	}
	//Creating a simple circle cell 
	//o = outie (The outer layer circle of a cell)
	//i = innie (The inside layer circle of a cell)
	//n = nucleus (The small circle of a cell)
	//n on top i, i on top o. 'o' and 'n' have darker color while 'i' have white color
	vec2 diff = UV - vec2(0.5);
	float dist = dot(diff, diff);

	float o_radius = 0.5 * u_size_mult;
	//I decrease o_radius - 0.05, because in cell lab, the thickness of the darker, outline thingy is actually same all the same.
	//Affecting i_radius with u_size_mult directly (e.g. 0.45 * u_size_mult) can make the thickness of the outline incosistent.
	//Hence why I use o_radius - 0.05
	float i_radius = o_radius - 0.05;
	float n_radius = 0.08;
	
	float o_circle = step(dist, o_radius * o_radius);
	float i_circle = step(dist, i_radius * i_radius);
	float n_circle = step(dist, n_radius * n_radius);
	
	vec3 darker_color = u_color * 0.75;
	
	float outer_ring = o_circle - i_circle;
	float inner_ring = i_circle - n_circle;
	float nucleus    = n_circle;

	vec3 color =
		outer_ring * darker_color +
		inner_ring * u_color +
		nucleus    * darker_color;
	//(1.15 / (i_radius / 0.45)) is like that because: 1.15 is the scaling so it will look a little bit smaller. 
	//Why adjust the size with / (i_radius / 0.45) and not / u_size_mult? I use i_radius / 0.45 because i_radius itself is o_radius - 0.05 which isn't affected by u_size_mult directly
	//Using / u_size_mult could work, but when scaling, it will look little off and not scale neatly
	vec2 deco_uv = (UV - 0.5) * (1.15 / (i_radius / 0.45)) + 0.5;
	//This variable basically so there's no pixel bleeding 
	//SORRY FOR BAD EXPLANATION: (Pixel bleeding when there are no pixel to be used outside so it pick the closest or on the edge one, which probably is not transparent so gonna cause bleeding.)
	float inside =
		step(0.0, deco_uv.x) *
		step(0.0, deco_uv.y) *
		step(deco_uv.x, 1.0) *
		step(deco_uv.y, 1.0);
	vec3 final_color = color;

	if (u_use_decoration > 0.5) {
		vec4 deco_tex = texture(decoration, deco_uv) * inside;
		final_color = mix(color, deco_tex.rgb, deco_tex.a);
	}

	COLOR = vec4(final_color, o_circle);

	//Literally just copy the background and then render it (INEFFICIENT). Unused.
	//This used when you don't render the object
	//COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
}
