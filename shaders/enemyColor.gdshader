shader_type canvas_item;

uniform vec4 color_base = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_oscil = vec4(1.0, 1.0, 1.0, 1.0);
uniform float oscil_speed = 1.0;
uniform float amplify = 1.0;

float easeInOutQuart(float x) {
    return x < 0.5 ? 8.0 * x * x * x * x : 1.0 - pow(-2.0 * x + 2.0, 4.0) / 2.0;
}

void fragment() {
    float oscillation = sin(TIME * oscil_speed * 2.0 * 3.14159);
    float normalized_oscillation = (oscillation + 1.0) * 0.5;
    float eased_oscillation = easeInOutQuart(normalized_oscillation);
    vec4 final_color = mix(color_base, color_oscil, eased_oscillation);

    COLOR = texture(TEXTURE, UV) * final_color;
}