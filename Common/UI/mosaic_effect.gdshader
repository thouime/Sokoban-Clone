shader_type canvas_item;


uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float block_size : hint_range(1.0, 256.0) = 1.0;
uniform float fade : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 block = vec2(block_size) / vec2(1024.0, 576.0);
	vec2 uv = (floor(SCREEN_UV / block) + 0.5) * block;
	vec4 col = texture(screen_tex, uv);
	COLOR = vec4(mix(col.rgb, vec3(0.0), fade), 1.0);
}
