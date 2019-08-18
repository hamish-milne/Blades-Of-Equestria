

function love.load()
    love.graphics.setDefaultFilter("nearest", 'nearest', 0)
    image = love.graphics.newImage("pony.png")
    width, height = love.graphics.getDimensions()
    scale = 2
    canvas = love.graphics.newCanvas(width/scale, height/scale)

    
    grass = love.graphics.newImage("grass.png")
    grass_dry = love.graphics.newImage("grass-dry.png")
    dirt_rocks = love.graphics.newImage("dirt-rocks.png")
    cobble = love.graphics.newImage("cobble.png")

    tiles = {grass, grass_dry, dirt_rocks, cobble}

end

function love.update()
    -- Input handling (TODO: Touchscreen pos as well)
    cx, cy = love.mouse.getPosition()
    cx = math.floor(cx / scale)
    cy = math.floor(cy / scale)
    click = love.mouse.isDown(1)
end

function drawTile(tile, x, y)
    love.graphics.draw(tile, (x * 32) + ((y % 2) * 16), y * 8)
end

--function love.mousereleased()

function love.draw()
    --love.graphics.setBlendMode("replace")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(50/255, 168/255, 82/255)
    love.graphics.setColor(1, 1, 1)


    -- Draw tiles
    love.math.setRandomSeed(0)
    for y=1,20 do for x=1,10 do
        drawTile(tiles[love.math.random(2)], x, y)
    end end
    

    -- Draw pony
    love.graphics.setColor(0.8, 0.6, 1)
    love.graphics.draw(image, 100, 20)
    
    button(100, 100, 'a')

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, scale)
end

function button(x, y, text)
    local width = 16
    local height = 16
    local hover = (cx >= x and cx <= (x + width)) and (cy >= y and cy <= (y + height))
    local c1 = {255/255, 241/255, 186/255}
    local c2 = {204/255, 157/255, 104/255}
    local c3 = {1, 1, 0}
    love.graphics.setLineWidth(2)
    love.graphics.setColor(unpack(hover and c3 or c1))
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(unpack(c2))
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.print(text, x + 3, y)
end

function create_actor(actor)

end

create_actor {
    name = ''
}

