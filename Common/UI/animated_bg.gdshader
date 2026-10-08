shader_type canvas_item;

uniform float scroll_speed : hint_range(0.0, 2.0) = 1.55;

void fragment() {
	vec2 uv = UV;
	uv.y = fract(uv.y + TIME * scroll_speed);
	COLOR = texture(TEXTURE, uv);
}