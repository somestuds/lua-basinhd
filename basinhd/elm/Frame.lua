local Container = require('basinhd.elm.Container')
--- @class Frame: Container
local Frame = setmetatable({}, { __index = Container })
Frame.dragable = false

--- @param dragable boolean
function Frame:setDragable(dragable)
    self.dragable = dragable
    return self
end

return Frame
