shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float progress : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	if (uv.y > progress) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		uv.y = uv.y / max(progress, 0.0001);
		COLOR = texture(screen_tex, uv);
	}
}