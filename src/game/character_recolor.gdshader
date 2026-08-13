shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform sampler2D mask_texture : hint_default_black;

vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + 1.0e-10)), d / (q.x + 1.0e-10), q.x);
}

vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	float m = texture(mask_texture, UV).r;

	vec3 target = rgb_to_hsv(color.rgb);
	vec3 origin = rgb_to_hsv(src.rgb);
	vec3 swapped = hsv_to_rgb(vec3(target.x, origin.y, origin.z));

	COLOR = vec4(mix(src.rgb, swapped, m), src.a);
}
