shader_type canvas_item;

uniform sampler2D noise_tex;
uniform float radius = 0.4;
uniform float speed = 1.5;

void fragment() {
    vec2 centered = UV - 0.5;
    float dist = length(centered);

    // Circular mask
    if (dist > radius) {
        discard;
    }

    // Rotate UVs over time
    float a1 = TIME * speed;
    float a2 = -TIME * speed * 1.3;

    mat2 rot1 = mat2(vec2(cos(a1), -sin(a1)),
                     vec2(sin(a1),  cos(a1)));
    mat2 rot2 = mat2(vec2(cos(a2), -sin(a2)),
                     vec2(sin(a2),  cos(a2)));

    float n =
        texture(noise_tex, rot1 * centered + 0.5).r +
        texture(noise_tex, rot2 * centered + 0.5).g;

    if (n > 0.5) {
        COLOR = vec4(0.0, 0.8, 0.2, 1.0);
    } else {
        COLOR = vec4(0.0, 0.5, 0.1, 0.4);
    }
}
