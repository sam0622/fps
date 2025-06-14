shader_type canvas_item;

uniform vec4 background_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float overlay_progress : hint_range(0.0, 1.0); // 0 = full overlay, 1 = no overlay
uniform float overlay_alpha : hint_range(0.0, 1.0) = 0.5; // 0 = no darkening, 1 = full black

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 final_color = mix(background_color, tex_color, tex_color.a);

	float cutoff = 1.0 - overlay_progress;

	if (UV.y >= cutoff) {
		final_color.rgb = mix(final_color.rgb, vec3(0.0), overlay_alpha); // darken
	}

	COLOR = final_color;
}
