uniform Image map;
uniform Image atlas;
uniform vec2 offset;

const int tile_width = 32;
const int tile_height = 16;
const int atlas_stride = 16;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    screen_coords += offset;
    vec2 uv = vec2(
        int((2*screen_coords.y + screen_coords.x) / 32),
        int((2*screen_coords.y - screen_coords.x) / 32)
    );
    vec2 tile_origin = vec2(
        (uv.x - uv.y) * tile_width,
        (uv.x + uv.y) * tile_height
    ) / 2;
    vec2 tile_uv = (screen_coords - tile_origin) + vec2(tile_width/2, 0);
    int tile_idx = int(ceil(Texel(map, uv/128).b)); // TODO: Do the index properly here
    vec2 tile_pixels = vec2(
        mod(tile_idx, atlas_stride) * tile_width,
        int(tile_idx / atlas_stride) * tile_height
    ) + tile_uv;
    vec2 scale = vec2(tile_width, tile_height) * atlas_stride;

    vec4 texturecolor = Texel(atlas, tile_pixels/scale);
    return texturecolor * color;
}
