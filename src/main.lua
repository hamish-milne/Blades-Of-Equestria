

function love.load()
    -- Set up the canvas
    love.graphics.setDefaultFilter("nearest", 'nearest', 0)
    width, height = love.graphics.getDimensions()
    scale = 4
    canvas = love.graphics.newCanvas(width/scale, height/scale)

    -- Load assets
    pony = love.graphics.newImage("pony.png")
    pony_back = love.graphics.newImage("pony-back.png")

    font = love.graphics.newFont(10, "mono")
    love.graphics.setFont(font)
    grass = love.graphics.newImage("grass.png")
    grass_dry = love.graphics.newImage("grass-dry.png")
    dirt_rocks = love.graphics.newImage("dirt-rocks.png")
    cobble = love.graphics.newImage("cobble.png")

    button_normal = love.graphics.newImage("button.png")
    button_down = love.graphics.newImage("button-down.png")
    button_hover = love.graphics.newImage("button-hover.png")

    tiles = {grass, grass_dry, cobble, dirt_rocks}
    tile_array = love.graphics.newArrayImage({"grass.png", "grass-dry.png"})

    -- 2y + x = 16* (ax + ax + ay - ay) = 32 ax
    -- 2y - x = 16* (ax - ax + ay + ay) = 32 ay

    ground_shader = love.graphics.newShader [[

uniform ArrayImage atlas;
uniform vec2 offset;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = vec2(
        int((2*screen_coords.y + screen_coords.x) / 32),
        int((2*screen_coords.y - screen_coords.x) / 32)
    );
    // TODO: tile type
    vec2 tile_origin = vec2(
        (uv.x - uv.y) * 16,
        (uv.x + uv.y) * 8
    );
    vec2 tile_uv = screen_coords - tile_origin;
    
    vec4 texturecolor = Texel(atlas, vec3(tile_uv.x/32 + 0.5, tile_uv.y/16, 0));
    return texturecolor * color;
}

    ]]

    ground_shader:send("atlas", tile_array)
end

function love.update()
    -- Input handling (TODO: Touchscreen pos as well)
    cx, cy = love.mouse.getPosition()
    cx = math.floor(cx / scale)
    cy = math.floor(cy / scale)
    down = love.mouse.isDown(1)
end

function drawTile(tile, x, y)
    love.graphics.draw(tile, (x * 32) + ((y % 2) * 16), y * 8)
end

function love.mousereleased( x, y, button, istouch, presses )
    released = button
end

function love.draw()
    --love.graphics.setBlendMode("add")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(50/255, 168/255, 82/255)
    love.graphics.setColor(1, 1, 1)


    -- Draw tiles
    -- love.math.setRandomSeed(0)
    -- for y=-1,36 do for x=-1,13 do
    --     drawTile(tiles[love.math.random(1)], x, y)
    -- end end
    love.graphics.setShader(ground_shader)
    love.graphics.rectangle("fill", 0, 0, canvas:getWidth(), canvas:getHeight())
    love.graphics.setShader()

    -- Draw pony
    for i,actor in ipairs(actors) do draw_actor(actor) end

    if button(20, 100, 'A') then add_to_console("Clicked") end

    draw_console()

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, scale)

    -- Reset flags
    released = false
end

function button(x, y, text)
    love.graphics.setColor(1, 1, 1)
    local width = 24
    local height = 24
    local hover = (cx >= x and cx <= (x + width)) and (cy >= y and cy <= (y + height))
    love.graphics.setLineWidth(2)
    love.graphics.draw(hover and (down and button_down or button_hover) or button_normal, x, y)
    love.graphics.print(text, x + 4, y)
    return hover and released
end

console_text = ''

function draw_text(text, x, y, wrap)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(text, x+1, y+1, wrap)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(text, x, y, wrap)
end

function draw_console()
    draw_text(console_text, 20, 20, 200);
end

function add_to_console(line)
    console_text = console_text..line..'\n'
end

function draw_actor(actor)
    love.graphics.setColor(unpack(actor.color))
    x = (actor.x - actor.y) * 16
    y = (actor.x + actor.y) * 8

    r = math.floor(actor.rotation / 90) % 4
    love.graphics.push()
    love.graphics.translate(x, y);
    if r % 2 == 1 then love.graphics.scale(-1, 1) end
    love.graphics.draw(pony,  - (pony:getWidth() / 2),  - pony:getHeight())
    love.graphics.pop()
    draw_text(actor.name, x - 40, y - 45, 100)
end

actors = {}
function create_actor(actor)
    table.insert(actors, actor)
end

create_actor {
    name = 'I am a pony!',
    color = {0.8, 0.6, 1},
    x = 8,
    y = 3,
    rotation = 90
}

create_actor {
    name = 'I am a pony too!',
    color = {0.6, 0.8, 1},
    x = 13,
    y = 4,
    rotation = 0
}
