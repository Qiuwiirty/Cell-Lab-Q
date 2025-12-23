shader_type canvas_item;

const int cellCount = 4;

uniform vec2 u_cells[cellCount];
uniform vec3 u_colors[cellCount];
uniform float u_radii[cellCount];

float circleSDF( in vec2 fragCoord, in vec2 center, in float radius )
{
    // negative inside and positive outside
    return  distance(center, fragCoord) - radius;
}

// This runs for every pixel
void fragment()
{
    // Initialise cells
    // In the actual program, you should have a buffer containing the cell info    

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
    // Make it pretty
    float inside = smoothstep(0., 1., 0.2 - squishSDF * 20.);
    float membrane = smoothstep(0., 1.1, 1. + squishSDF * 3.);
    float cytoplasm = pow(smoothstep(0., 2.5, 1. - cellSDF * 0.5), 2.);
    float nucleus = smoothstep(0., 1., (-cellSDF - 0.8) * 20.);
    vec3 color = u_colors[closest];
    //vec3 color = vec3(1, 1, 1);
    //vec3 test = (0.2 + step(highestRatio, -cellSDF)) * color;
    
    // Output to screen
    COLOR = (nucleus + (cytoplasm + membrane) * inside) * vec4(color, 1.);
    //fragColor = vec4(-squishSDF) * vec4(color, 1.);
}