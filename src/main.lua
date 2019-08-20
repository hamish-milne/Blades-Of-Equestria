local vector = require("vector")

function love.load()
    -- Set up the canvas
    love.graphics.setDefaultFilter("nearest", 'nearest', 0)
    love.graphics.setLineStyle('rough')
    width, height = love.graphics.getDimensions()
    scale = 2
    canvas = love.graphics.newCanvas(width/scale, height/scale)

    -- Load assets
    pony = love.graphics.newImage("pony.png")
    pony_back = love.graphics.newImage("pony-back.png")

    font = love.graphics.newFont(10, "mono")
    love.graphics.setFont(font)
    -- TODO: Palette index for map
    map = love.graphics.newImage("map.png")

    button_normal = love.graphics.newImage("button.png")
    button_down = love.graphics.newImage("button-down.png")
    button_hover = love.graphics.newImage("button-hover.png")

    tile_array = love.graphics.newArrayImage({"grass.png", "grass-dry.png", "dirt-rocks.png"})
    ground_shader = love.graphics.newShader [[

uniform Image map;
uniform ArrayImage atlas;
uniform vec2 offset;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = vec2(
        int((2*screen_coords.y + screen_coords.x) / 32),
        int((2*screen_coords.y - screen_coords.x) / 32)
    );
    vec2 tile_origin = vec2(
        (uv.x - uv.y) * 16,
        (uv.x + uv.y) * 8
    );
    vec2 tile_uv = screen_coords - tile_origin;
    
    vec4 texturecolor = Texel(atlas, vec3( tile_uv.x/32 + 0.5, tile_uv.y/16, Texel(map, uv/128).b ) );
    return texturecolor * color;
}

    ]]

    ground_shader:send("map", map)
    ground_shader:send("atlas", tile_array)
end

function love.update(dt)
    -- Input handling (TODO: Touchscreen pos as well)
    cx, cy = love.mouse.getPosition()
    cx = math.floor(cx / scale)
    cy = math.floor(cy / scale)
    down = love.mouse.isDown(1)

    for i,actor in ipairs(actors) do
        actor:ai(dt)
    end
end

function drawTile(tile, x, y)
    love.graphics.draw(tile, (x * 32) + ((y % 2) * 16), y * 8)
end

function love.mousereleased( x, y, button, istouch, presses )
    released = button
end

function consume_click()
    if released then
        released = false
        return true
    end
    return false
end

function dashLine( p1, p2, dash, gap, offset )
    local dy, dx = p2.y - p1.y, p2.x - p1.x
    local an, st = math.atan2( dy, dx ), dash + gap
    local len	 = math.sqrt( dx*dx + dy*dy )
    local nm	 = ( len - dash ) / st
    love.graphics.push()
    love.graphics.translate( p1.x, p1.y )
    love.graphics.rotate( an )
    for i = 0, nm do
        love.graphics.line( i * st + offset, 0, i * st + dash + offset, 0 )
    end
    --love.graphics.line( nm * st + offset, 0, nm * st + dash + offset,0 )
    love.graphics.pop()
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(50/255, 168/255, 82/255)
    love.graphics.setColor(1, 1, 1)


    -- Draw tiles
    love.graphics.setShader(ground_shader)
    love.graphics.rectangle("fill", 0, 0, canvas:getWidth(), canvas:getHeight())
    love.graphics.setShader()

    -- Draw world UI elements
    -- TODO: Do this for player party
    if actors[1].moving then
        local px, py = to_screen(actors[1].target)
        local sx, sy = to_screen(actors[1].pos)
        local a = vector(px, py)
        local b = vector(sx, sy)

        love.graphics.setColor(1, 0, 0)
        love.graphics.circle('fill', px, py, 3)
        love.graphics.setLineWidth(3)
        dashLine(a, b, 10, 4, 0);
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(2)
        love.graphics.circle('line', px, py, 3)
        love.graphics.setLineWidth(1)
        dashLine(a, b, 10-2, 4+2, 1);
    end

    -- Draw pony
    for i,actor in ipairs(actors) do draw_actor(actor) end

    if button(20, 100, 'A') then add_to_console("Clicked") end

    draw_console()

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, scale)

    -- Reset flags
    if consume_click() then
        local uv = vector(
            (2*cy + cx) / 32,
            (2*cy - cx) / 32
        );
        actors[1].target = uv
        actors[1].moving = true
    end
end

function button(x, y, text)
    love.graphics.setColor(1, 1, 1)
    local width = 24
    local height = 24
    local hover = (cx >= x and cx <= (x + width)) and (cy >= y and cy <= (y + height))
    love.graphics.setLineWidth(2)
    love.graphics.draw(hover and (down and button_down or button_hover) or button_normal, x, y)
    love.graphics.print(text, x + 4, y)
    return hover and consume_click()
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

function to_screen(vec)
    local x = (vec.x - vec.y) * 16
    local y = (vec.x + vec.y) * 8
    return x, y
end

function draw_actor(actor)
    love.graphics.setColor(unpack(actor.color))
    local x, y = to_screen(actor.pos)

    local r = math.deg(actor.angle + 45)
    if r < 0 then r = r + 360 end
    r = math.floor(r / 90) % 4
    love.graphics.push()
    love.graphics.translate(x, y);
    if r % 2 == 1 then love.graphics.scale(-1, 1) end
    local sprite = r < 2 and pony or pony_back
    love.graphics.draw(sprite,  - (sprite:getWidth() / 2),  - sprite:getHeight())
    love.graphics.pop()
    draw_text(actor.name, x - 40, y - 45, 100)
end

actors = {}
function create_actor(actor)
    table.insert(actors, actor)
end

function actor_ai(self, dt)
    if self.moving then
        local velocity = 4
        local delta = self.target - self.pos
        if delta:len() < 1e-3 then
            self.moving = false
        else
            self.angle = math.atan2(delta.x, delta.y)
        end
        delta:trimInplace(velocity * dt)
        self.pos.x = self.pos.x + delta.x
        self.pos.y = self.pos.y + delta.y
    end
end

create_actor {
    name = 'I am a pony!',
    color = {0.8, 0.6, 1},
    pos = vector(8, 3),
    target = vector(16, 3),
    moving = true,
    ai = actor_ai,
}

create_actor {
    name = 'I am a pony too!',
    color = {0.6, 0.8, 1},
    pos = vector(13, 4),
    target = vector(13, 10),
    moving = true,
    ai = actor_ai
}
