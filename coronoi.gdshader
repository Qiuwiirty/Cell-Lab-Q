shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
//void vertex() {
	// Called for every vertex the material is visible on.
//}

//void fragment() {
	//COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
//}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
const int cellCount = 4;

uniform vec2 u_cells[cellCount];
uniform float u_radii[cellCount];

float circleSDF( in vec2 fragCoord, in vec2 center, in float radius )
{
    // negative inside and positive outside
    return  distance(center, fragCoord) - radius;
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
        vec2 displacement = FRAGCOORD.xy - center;
        float distSq = dot(displacement, displacement) - radius * radius;
        
        if (distSq < closestDistSq) //this is inefficient, later ill change this to math instead of if
        {   
            closest = i;
            closestDistSq = distSq;
        }
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
        float ratio = dot(FRAGCOORD.xy - u_cells[closest], weightedMidpoint) / dot(weightedMidpoint, weightedMidpoint);
        ratio = mix(-1., 0., -ratio);

        if (ratio > highestRatio)
        {   
            other = i;
            highestRatio = ratio;
        }
    }
    
    // Calculate the SDF of the cell
    float radius = u_radii[closest];
    float cellSDF = circleSDF(FRAGCOORD.xy, u_cells[closest], radius) / radius;
    float squishSDF = max(cellSDF, highestRatio);
    float inside_mask = step(squishSDF, 0.0);

    vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec4 group = texture(TEXTURE, UV);

    // Inside → show CanvasGroup
    // Outside → passthrough
    COLOR = mix(bg, group, inside_mask);
}