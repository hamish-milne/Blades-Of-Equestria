local vector = require 'vector'
local vec = require 'vector-light'
local world = require 'world'
local palette = require 'palette'

local g = love.graphics;

image = {
    __index = function(t, k)
        -- TODO: Register asset
        local img = g.newImage('images/'..k..'.png')
        rawset(t, k, img)
        return img
    end
}
setmetatable(image, image)

shader = {
    __index = function(t, k)
        -- TODO: Register asset
        local s = love.graphics.newShader(love.filesystem.newFileData('shaders/'..k..'.glsl'))
        rawset(t, k, s)
        return s
    end
}
setmetatable(shader, shader)

function love.resize(w, h)
    width = w / scale
    height = h / scale
    canvas = g.newCanvas(width, height)
end

function love.load()
    -- Set up the canvas
    scale = 2
    g.setDefaultFilter('nearest', 'nearest', 0)
    love.resize(g.getDimensions())
    g.setLineStyle('rough')

    font = g.newFont(10, "mono")
    g.setFont(font)
    -- TODO: Palette index for map

    ground_shader = shader.ground
    local map_data = love.image.newImageData('images/map.png')
    local vga_palette = palette('vga-13h.gpl')
    vga_palette:convert(map_data)
    local map_image = love.graphics.newImage(map_data)
    ground_shader:send('map', map_image)
    ground_shader:send('atlas', image.tiles)
    ground_shader:send('scale', g.getDPIScale())
    local map_explored, map_visible = world.setup_actor_sight()
    ground_shader:send('explored', map_explored)
    ground_shader:send('visible', map_visible)

    selection_shader = shader.outline
    selection_shader:send('size', {32, 32})
end

function love.update(dt)
    -- Input handling (TODO: Touchscreen pos as well)
    cx, cy = love.mouse.getPosition()
    cx = math.floor(cx / scale)
    cy = math.floor(cy / scale)
    down = love.mouse.isDown(1)
    mouse_uv = vector(to_uv(cx, cy))

    for i,actor in ipairs(actors) do
        actor:ai(dt)
    end

    -- Screen borders
    local border_px = 10
    screen_border(0, 0, width, border_px, vector(0, -1))
    screen_border(0, 0, border_px, height, vector(-1, 0))
    screen_border(width-border_px, 0, border_px, height, vector(1, 0))
    screen_border(0, height-border_px, width, border_px, vector(0, 1))
    ground_shader:send("offset", {screen_offset.x, screen_offset.y})

end

function drawTile(tile, x, y)
    love.graphics.draw(tile, (x * 32) + ((y % 2) * 16), y * 8)
end

function love.mousereleased( x, y, button, istouch, presses )
    released = button
end

function consume_click(require_button)
    if released and (not require_button or released == require_button) then
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

screen_offset = vector(0, 0)

function love.draw()

    world.update_actor_sight()
	g.setBlendMode('alpha')

    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1)


    -- Draw tiles
    love.graphics.setShader(ground_shader)
    love.graphics.rectangle("fill", 0, 0, canvas:getWidth(), canvas:getHeight())
    love.graphics.setShader()

    love.graphics.print("Scale: "..love.graphics.getDPIScale(), 0, 0)

    -- Begin world objects
    love.graphics.push()
    love.graphics.translate(-screen_offset.x, -screen_offset.y)

    -- Draw world UI elements
    for i,actor in ipairs(player_party) do
        if actor.moving and actor.selected then
            local a = vector(to_screen(actor.target:unpack()))
            local b = vector(to_screen(actor.pos:unpack()))

            love.graphics.setColor(1, 0, 0)
            love.graphics.circle('fill', a.x, a.y, 3)
            love.graphics.setLineWidth(3)
            dashLine(a, b, 10, 4, 0);
            love.graphics.setColor(1, 1, 1)
            love.graphics.setLineWidth(2)
            love.graphics.circle('line', a.x, a.y, 3)
            love.graphics.setLineWidth(1)
            dashLine(a, b, 10-2, 4+2, 1)
        end
    end

    -- Draw pony
    for i,actor in ipairs(actors) do draw_actor(actor) end

    love.graphics.pop()
    -- End world objects

    if button(20, 100, image.icon_sword) then add_to_console("Clicked") end

    draw_console()

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, scale)

    -- Reset flags
    if consume_click() then
        for i,actor in ipairs(player_party) do
            if actor.selected then
                actor.target = mouse_uv
                actor.moving = true
            end
        end
    end
end

function mouse_hover(x, y, width, height)
    local tx, ty = love.graphics.inverseTransformPoint(cx, cy)
    return (tx >= x and tx <= (x + width)) and (ty >= y and ty <= (y + height))
end

function screen_border(x, y, width, height, velocity)
    if mouse_hover(x, y, width, height) then
        velocity:mulInplace(3)
        screen_offset:addInplace(velocity)
    end
end

function button(x, y, icon)
    love.graphics.setColor(1, 1, 1)
    local width = 24
    local height = 24
    local hover = mouse_hover(x, y, width, height)
    love.graphics.setLineWidth(2)
    love.graphics.draw(hover and (down and image.button_down or image.button_hover) or image.button, x, y)
    love.graphics.draw(icon, x, y)
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

function to_screen(x, y)
    local x1 = (x - y) * 16
    local y1 = (x + y) * 8
    return x1, y1
end

function to_uv(x, y)
    local x1 = x + screen_offset.x
    local y1 = y + screen_offset.y
    return (2*y1 + x1) / 32, (2*y1 - x1) / 32
end

function draw_actor(actor)
    love.graphics.setColor(unpack(actor.color))
    local x, y = to_screen(actor.pos:unpack())

    local r = math.deg(actor.angle + 45)
    if r < 0 then r = r + 360 end
    r = math.floor(r / 90) % 4
    love.graphics.push()
    love.graphics.translate(x, y);
    if r % 2 == 1 then love.graphics.scale(-1, 1) end
    local sprite = r < 2 and image.pony or image.pony_back
    love.graphics.translate(- (sprite:getWidth() / 2),  - sprite:getHeight())
    local hover = mouse_hover(0, 0, sprite:getWidth(), sprite:getHeight())
    if actor.selected or hover then
        love.graphics.setShader(selection_shader)
        selection_shader:send('outline_color',
            (actor.selected and hover) and {1, 0, 0, 1} or {0, 1, 0, 1}
        )
    end
    if hover and consume_click() then
        actor.selected = not actor.selected
    end
    love.graphics.draw(sprite)
    love.graphics.setShader()
    love.graphics.pop()
    draw_text(actor.name, x - 40, y - 45, 100)
end

actors = {}
player_party = {}
function create_actor(actor)
    table.insert(actors, actor)
end

function create_player_actor(actor)
    table.insert(actors, actor)
    table.insert(player_party, actor)
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
        self.pos:addInplace(delta)
    end
end

create_player_actor {
    name = 'I am a pony!',
    color = {0.8, 0.6, 1},
    pos = vector(8, 3),
    target = vector(16, 3),
    moving = true,
    ai = actor_ai,
}

create_player_actor {
    name = 'I am a pony too!',
    color = {0.6, 0.8, 1},
    pos = vector(13, 4),
    target = vector(13, 10),
    moving = true,
    ai = actor_ai
}

create_actor {
    name = 'I am NPC',
    color = {0.8, 0.3, 0.1},
    pos = vector(20, 20),
    ai = actor_ai,
    angle = 0
}
