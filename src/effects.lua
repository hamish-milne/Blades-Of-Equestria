local set = require 'set'
local bitser = require 'bitser'
local Effect = Class{
    init = function(self, duration, magnitude)
        duration = duration
        magnitude = magnitude
    end
}

local effects = {}
setmetatable(effects, {
    __newindex = function(t, k, v)
        v.__includes = {Effect}
        local class = Class(v)
        rawset(t, k, class)
        bitser.registerClass(class, k)
    end
})

effects.health_up = {
    health = function(self, actor, value)
        return value * (1 + 0.1 * self.magnitude)
    end
}

effects.defence_up = {
    defence = function(self, actor, value)
        return value + 5 * self.magnitude
    end
}

effects.defence_down = {
    defence = function(self, actor, value)
        return value - 5 * self.magnitude
    end
}

effects.poison = {
    turn_end = function(self, actor, value)
        actor:damage(5 * self.magnitude, set('poison', 'dot'))
    end
}

effects.burn = {
    turn_end = function(self, actor, value)
        actor:damage(5 * self.magnitude, set('fire', 'dot'))
    end
}

effects.freeze = {}

effects.stun = {}

effects.charm = {}

effects.invisible = {}

effects.regenerate = {
    turn_end = function(self, actor)
        actor:heal(5 * self.magnitude)
    end
}

effects.shock = {
    turn_end = function(self, actor)
        for other in actor:allies_in_range(3) do
            other:damage(5 * self.magnitude, set('electric', 'dot'))
        end
    end
}

effects.drain = {
    turn_end = function(self, actor)
        actor:energy_cost(1)
    end
}

return effects
