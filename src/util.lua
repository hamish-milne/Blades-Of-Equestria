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
