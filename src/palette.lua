

local palette = {}
palette.__index = palette

local function new_palette(t, path)
    local indices = {}
    for line in love.filesystem.lines(path) do
        local r, g, b = line:match("%s*(%d+)%s+(%d+)%s+(%d+)%s+%w+")
        if r ~= nil then
            table.insert(indices, {tonumber(r)/255, tonumber(g)/255, tonumber(b)/255})
        end
    end
    return setmetatable(indices, palette)
end

function palette:map(r, g, b)
    for i,c in ipairs(self) do
        if c[1] == r and c[2] == g and c[3] == b then
            return i
        end
    end
    return false
end

function palette:convert(image)
    image:mapPixel(function (x, y, r, g, b, a)
        local idx = self:map(r, g, b) or 1
        return (idx - 1)/255, 0, 0, 1
    end)
end

return setmetatable(palette, {
    __call = new_palette
})
