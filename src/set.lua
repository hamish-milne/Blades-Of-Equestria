Class = require 'class'

local set = Class{
    init = function(self, ...)
        for i=1,select('#', ...) do
            self[select(i, ...)] = true
        end
    end
}

return set
