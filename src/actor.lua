
local actor = {}

function actor:aggregate_effects()
    -- TODO: return table/iterator of aggregated effects
end

function actor:inflict(effect)
    table.insert(self.effects, effect)
end

function actor:apply_stat_mods(name, base)
    local value = base
    for i,effect in ipairs(self.effects) do
        if effect[k] then
            if type(effect[k]) == 'number' then
                value = value + effect[k]
            else
                value = effect[k](actor, value)
            end
        end
    end
end

function actor.__index(t, k)
    return t:apply_stat_mods(k, t.base[k])
end

function actor:has_effect(effect)
    for i,v in ipairs(self.effects)
        if v.effect == effect
            return true
        end
    end
    return false
end

function actor:damage()
