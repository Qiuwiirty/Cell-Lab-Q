shader_type canvas_item;

uniform sampler2D tex1;
uniform float angle1;
uniform float angle2;
uniform vec3 color: source_color;

const float scale = 50.0;
const float NR = 0.005 * scale;
const float EW = 0.002 * scale;
const float EWH = 0.001 * scale;

const float pos = -0.6;
const float amount = 0.1;

const float EPS = 0.0001;

float Power(float x){ return x * x; }

void fragment() {
	vec4 col = COLOR;
	col.a *= scale;

	vec2 p = (UV * 2.0 - 1.0) * scale;
	vec2 tp = vec2(UV.x, UV.y * scale);

	vec2 phiTrig = vec2(cos(angle1), sin(angle1));
	vec2 phiTrig2 = vec2(cos(angle2), sin(angle2));

	float ds = dot(p, p);
	if (ds > col.a * col.a) {
		discard;
	}

	float safe_ds = max(ds, EPS);

	float srr = max(
		ds / ((col.a - EW) * (col.a - EW)),
		EW / max(EWH, col.a - tp.y)
	);

	vec2 stc = p * max(tp.y / sqrt(safe_ds), 1.0) / col.a;

	float x = dot(stc, phiTrig);
	float y = dot(stc, vec2(phiTrig.y, -phiTrig.x));

	if (dot(stc - phiTrig * 0.55, stc - phiTrig * 0.55) * col.a * col.a > NR * NR && srr < 1.0) {
		float denom = dot(stc + phiTrig * pos, stc + phiTrig * pos);
		denom = max(denom, EPS);
		float r = sqrt(dot(stc, stc)) + amount / denom;
		if (r < 0.9) {
			float d = Power(pos + x) + Power(y);
			d = max(d, EPS);
			float grad = sqrt(
				Power(x / sqrt(max(Power(x) + Power(y), EPS)) -
				(2.0 * amount * (pos + x)) / (d * d)) +
				Power(y) * Power(
				1.0 / sqrt(max(Power(x) + Power(y), EPS)) -
				2.0 * amount / (d * d))
			);
			float inner = 0.9 - 0.08 * grad;
			if (r < inner) {
				vec2 dir1 = p / col.a + phiTrig * 0.3;
				vec2 dir = vec2(
					dir1.x * phiTrig2.x + dir1.y * phiTrig2.y,
					dir1.x * phiTrig2.y - dir1.y * phiTrig2.x
				);
				float len_dir = max(length(dir), EPS);
				float s = r * r / (inner * inner);
				float tr = (1.0 - s) + s * r / (inner * len_dir);
				COLOR.rgb = color * 0.75;
				vec2 tex_uv = vec2(0.5) + 0.5 * dir * tr;
				float tex_val = texture(tex1, tex_uv).b;
				COLOR.a = tex_val > 0.2 ? 0.7 : 0.0;
			} else {
				COLOR.rgb = 0.5 * color;
				COLOR.a = 1.0;
			}
		} else {
			discard;
		}
	} else {
		discard;
	}
}