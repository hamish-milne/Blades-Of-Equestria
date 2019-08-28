local skills = {}
local effects = require 'effects'

skills.hoof_strike = {
    target = {foe = 1},
    range = 1,
    cost = 1,
    test = function(self, actor, target)
        return actor:roll(target, 'melee', nil)
    end,
    on_hit = function(self, actor, target)
        target:damage(actor.strength)
    end
}

skills.melancholy = {
    filter = 'foe',
    area = 5,
    cost = 2,
    test = function(self, actor, target)
        return actor:roll(target, 'mental', nil)
    end,
    on_hit = function(self, actor, target)
        target:inflict(effects.defence_down(math.ceil(actor.personality / 5), 3))
    end
}

skills.joyful_song = {
    filter = 'ally',
    area = 5,
    cost = 4,
    on_hit = function(self, actor, target)
        local mag = math.ceil(actor.personality / 5)
        local dur = 3
        target:inflict(effects.regenerate(mag, dur))
        target:inflict(effects.attack_up(mag, dur))
        target:inflict(effects.defence_up(mag, dur))
    end
}

skills.encourage = {
    filter = 'ally',
    area = 4,
    cost = 2,
    on_hit = function(self, actor, target)
        local mag = math.ceil(actor.personality / 4)
        local dur = 2
        target:inflict(effects.attack_up(mag, dur))
    end
}

skills.comfort = {
    target = {ally = 1},
    range = 1,
    cost = 1,
    on_hit = function(self, actor, target)
        target:heal(actor.personality)
    end
}

return skills