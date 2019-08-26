local stats = {}

function stats:health()
    return math.min(self.base.constitution, 1) * 10
end

function stats:base_ap() return 2 end

function stats:base_energy() return 0 end

return stats
