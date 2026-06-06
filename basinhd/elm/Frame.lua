local Container = require('basinhd.elm.Container')
--- @class Frame: Container
local Frame = setmetatable({}, { __index = Container })
Frame.__index = Frame
Frame._className = 'Frame'

Frame.dragable = false
Frame._touchStartCoordinates = {}
Frame._isDragging = false

--- @param dragable boolean
function Frame:setDragable(dragable)
    self.dragable = dragable
    return self
end

--- @param x number
--- @param y number
function Frame:onTouchStarted(x, y)
    Log.warn('Not Implemented Yet')
end

--- @protected
function Frame:_postInit()
    Container._postInit(self)
    self._touchStartCoordinates = {}
end

return Frame
