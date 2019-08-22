uniform vec4 outline_color;
uniform vec2 size;

float check(Image tex, vec2 coords, vec2 dir)
{
    return Texel(tex, coords + (dir / size)).a;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    if (texturecolor.a > 0) {
        return texturecolor * color;
    }
    float surround_alpha =
        check(tex, texture_coords, vec2( 0,  1)) +
        check(tex, texture_coords, vec2( 1,  0)) +
        check(tex, texture_coords, vec2( 1,  1)) +
        check(tex, texture_coords, vec2( 0, -1)) +
        check(tex, texture_coords, vec2(-1,  0)) +
        check(tex, texture_coords, vec2(-1, -1)) +
        check(tex, texture_coords, vec2(-1,  1)) +
        check(tex, texture_coords, vec2( 1, -1));
    if (surround_alpha > 0) {
        return outline_color;
    }
    return vec4(0, 0, 0, 0);
}
