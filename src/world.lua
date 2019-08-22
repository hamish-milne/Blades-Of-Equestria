
local g = love.graphics
local map_explored
local map_visible
local world = {}

function world.setup_actor_sight()
	local settings = {format='r8'}
	map_explored = g.newCanvas(image.map:getWidth(), image.map:getHeight(), settings)
	map_visible = g.newCanvas(image.map:getWidth(), image.map:getHeight(), settings)
	map_explored:setWrap('clampzero')
	map_visible:setWrap('clampzero')
	return map_explored, map_visible
end

function world.update_actor_sight()
	g.setBlendMode('add')
	g.setCanvas(map_visible)
	g.clear(0, 0, 0)
	g.setColor(1, 1, 1)
	local los_distance = 10
	for i,actor in ipairs(actors) do
		g.circle('fill', actor.pos.x, actor.pos.y, los_distance)
	end
	g.setCanvas(map_explored)
	g.draw(map_visible)
end

return world
