uniform Image map;
uniform Image atlas;
uniform vec2 offset;
uniform float scale;

const float tile_width = 32.0;
const float tile_height = 16.0;
const float atlas_stride = 16.0;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    screen_coords /= scale;
    screen_coords += offset;
    vec2 uv = vec2(
        floor((2.0*screen_coords.y + screen_coords.x) / 32.0),
        floor((2.0*screen_coords.y - screen_coords.x) / 32.0)
    );
    vec2 tile_origin = vec2(
        (uv.x - uv.y) * tile_width,
        (uv.x + uv.y) * tile_height
    ) / 2.0;
    vec2 tile_uv = (screen_coords - tile_origin) + vec2(tile_width/2.0, 0);
    float tile_idx = ceil(Texel(map, uv/128.0).b); // TODO: Do the index properly here
    vec2 tile_pixels = vec2(
        floor(mod(tile_idx, atlas_stride)) * tile_width,
        floor(tile_idx / atlas_stride) * tile_height
    ) + tile_uv;
    vec2 scale = vec2(tile_width, tile_height) * atlas_stride;

    vec4 texturecolor = Texel(atlas, tile_pixels/scale);
    return texturecolor * color;
}
