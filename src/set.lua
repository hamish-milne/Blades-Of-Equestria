local set = Class{
    init = function(...)
        for i=1,select('#', ...) do
            self[select(i, ...)] = true
        end
    end
}

return set
