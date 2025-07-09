extern vec2 position;
extern number maxDistance;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    if(screen_coords.y > position.y) {
        return color;
    }

    float dist = position.y - screen_coords.y;
    float fade = clamp(1 - dist/maxDistance, 0, 1);
    return vec4(color.rgb, color.a*fade);
}