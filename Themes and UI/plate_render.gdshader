shader_type canvas_item;

const int cellCount = 4;

//All cells' decorations is here (image for simplicity)
//Currently it is just one but I WILL add new
uniform sampler2D u_green_floaters: filter_nearest;

uniform vec2 u_cells[cellCount];
uniform vec3 u_colors[cellCount];
uniform float u_radii[cellCount];
//xy-zw
uniform vec4 u_deco_rects[cellCount];
varying vec2 world_pos;

float circleSDF( in vec2 fragCoord, in vec2 center, in float radius )
{
    // negative inside and positive outside
    return  distance(center, fragCoord) - radius;
}

void vertex()
{
	//This will adjust to camera's rotation, position, etc..
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

// This runs for every pixel
void fragment()
{
    // First we determine the closest cell to the pixel
    float closestDistSq = 1e10;
    int closest = -1;
    for (int i = 0; i < cellCount; ++i)
    {
        
        vec2 center = u_cells[i];
        float radius = u_radii[i];

        // Using distance squared to have straight boundaries
        // Dotting itself gives length squared for cheap
        vec2 displacement = world_pos - center;
        float distSq = dot(displacement, displacement) - radius * radius;
        
		float isCloser = step(distSq, closestDistSq); // 1 if distSq <= closestDistSq

		closestDistSq = mix(closestDistSq, distSq, isCloser);
		closest        = int(mix(float(closest), float(i), isCloser));

    }
    
    // Then we find out the closest cell boundary to the pixel
    int other = -1;
    float highestRatio = -1.;
    for (int i = 0; i < cellCount; ++i)
    {
        // This finds the projection of the frag's displacement onto the cells' midpoint vector
        // Which is essentially the ratio of the pixel's closeness to the cells
        // This is used to draw the membrane boundary deforming properly
        vec2 displacement = (u_cells[closest] - u_cells[i]);
        float weight = (dot(displacement, displacement) // distance squared
                     + pow(u_radii[closest], 2.)
                     - pow(u_radii[i], 2.))
                     / (2. * length(displacement));
        vec2 weightedMidpoint = normalize(displacement) * weight;
        float ratio = dot(world_pos - u_cells[closest], weightedMidpoint) / dot(weightedMidpoint, weightedMidpoint);
        ratio = mix(-1., 0., -ratio);

        if (ratio > highestRatio)
        {   
            other = i;
            highestRatio = ratio;
        }
    }
    
    // Calculate the SDF of the cell
	vec2 cell_center = u_cells[closest];
    float radius = u_radii[closest];
    float cellSDF = circleSDF(world_pos, cell_center, radius) / radius;
    float squishSDF = max(cellSDF, highestRatio);
    // Make it (NOT) pretty
	float inside     = step(0.0, 0.2 - squishSDF * 20.);
	float dist_to_center = distance(world_pos, u_cells[closest]);
	float dist_to_edge = abs(dist_to_center - radius);
	float membrane = step(dist_to_edge, 1.5);
	float cytoplasm  = step(0.0, 1. - cellSDF * 0.5) * 0.3;
	float nucleus = step(dist_to_center, 2.25);
	
    vec3 color = u_colors[closest];
    //vec3 color = vec3(1, 1, 1);
    //vec3 test = (0.2 + step(highestRatio, -cellSDF)) * color;
    //Adding cells decoration
	vec2 cell_local = (world_pos - cell_center) / radius;

	float deco_scale = 1.25;

	// mask in cell-local space
	float local_mask =
	    step(abs(cell_local.x), 1.0 / deco_scale) *
	    step(abs(cell_local.y), 1.0 / deco_scale);

	// build UV
	vec2 cell_uv = cell_local * 0.5 + 0.5;
	cell_uv = (cell_uv - 0.5) * deco_scale + 0.5;

	vec4 green_floaters = texture(u_green_floaters, cell_uv);
	green_floaters.a *= inside * local_mask;

    // The cell's part first. Reason I am doing this so it will easier to work adding the decorations on top
    vec3 base_color =
    (nucleus + (cytoplasm + membrane) * inside) * color;
	
	//Mix decorations
	base_color = mix(
	    base_color,
	    green_floaters.rgb,
	    green_floaters.a
	);
	// Output to screen
	COLOR = vec4(base_color, 1.0);

    //fragColor = vec4(-squishSDF) * vec4(color, 1.);
}