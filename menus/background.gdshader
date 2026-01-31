shader_type canvas_item;

uniform float sway_x = 4.0;    // pixels
uniform float sway_y = 3.0;    // pixels
uniform float sway_speed = 0.6;

void vertex() {
    float t = TIME * sway_speed;

    vec2 offset = vec2(
        sin(t),
        cos(t)
    );

    VERTEX.xy += offset * vec2(sway_x, sway_y);
}
