shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec3 tint;
// = vec3(0.1, 0, 0);

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = (COLOR.rgb + tint.rgb) / 2.0;
}