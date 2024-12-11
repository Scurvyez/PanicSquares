shader_type canvas_item;

uniform vec4 color_base = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_collect_mid = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_lp = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool enable_collect_lerp = false;
uniform bool enable_lp_lerp = false;
uniform float lerp_time : hint_range(0.0, 1.0) = 0.0; // Progress of lerp (0.0 to 1.0)

void fragment() {
    vec4 color_final = color_base;

    if (enable_collect_lerp) {
        // Use a sine wave to smoothly oscillate between sprite_color and color_end
        float t = sin(lerp_time * 3.14159); // Oscillates between 0 and 1
        color_final = mix(color_base, color_collect_mid, t);
    }
	if (enable_lp_lerp) {
		float t = sin(lerp_time * 3.14159);
        color_final = mix(color_base, color_lp, t);
	}

    COLOR = texture(TEXTURE, UV) * color_final;
}
