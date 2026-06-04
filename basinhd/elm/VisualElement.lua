local BaseElement = require('basinhd.elm.BaseElement')

--- @class VisualElement: BaseElement
local VisualElement = setmetatable({}, { __index = BaseElement })
VisualElement.__index = VisualElement
VisualElement._className = 'VisualElement'

VisualElement.width = 1
VisualElement.height = 1
VisualElement.background = 0x000000
VisualElement.foreground = 0xFFFFFF

--- @generic T: VisualElement
--- @param self T
--- @param width number
--- @param height number
--- @return T
function VisualElement:setSize(width, height)
    self:setWidth(width)
    self:setHeight(height)
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param width number
--- @return T
function VisualElement:setWidth(width)
    self.width = width
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param height number
--- @return T
function VisualElement:setHeight(height)
    self.height = height
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @return T
function VisualElement:setPositionAndSize(x, y, width, height)
    self:setSize(width, height)
    self:setPosition(x, y)
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param background string|integer
--- @return T
function VisualElement:setBackground(background)
    self.background = colors.hexToInteger(background)
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param foreground string|integer
--- @return T
function VisualElement:setForeground(foreground)
    self.foreground = colors.hexToInteger(foreground)
    return self
end

-- --- @param anchor horizontalScreenAnchor
-- function VisualElement:anchorToX(anchor)
--     if self.parent then
--         local x, y, w, h = self.parent:_fixDescrepencies()
--         self.x = self.parent:_localXToScreenX(x, -1 - self.w)
--         self.y
--     end
-- end

--- @protected
function VisualElement:_fixDescrepencies()
    local x, y, w, h = self.x, self.y, self.width, self.height

    x, y = BaseElement._alignChildToParent(self.parent, x, y)

    if self.x <= 0 then
        w = self.width - (1 - self.x)
        x = 1
    end
    if self.y <= 0 then
        h = self.height - (1 - self.y)
        y = 1
    end
    w = math.clamp(-1 + self.x + self.width, 1, self.parent and -1 + self.parent.x + self.parent.width or self.glw) -
        (self.x - 1)
    h = math.clamp(-1 + self.y + self.height, 1, self.parent and -1 + self.parent.y + self.parent.height or self.glh) -
        (self.y - 1)

    return x, y, w, h
end

--- @return number, number, number, number
function VisualElement:_render()
    local x, y, w, h = self:_fixDescrepencies()
    if not self.visible or w <= 0 or h <= 0 then return 0, 0, 0, 0 end
    _G.gpu.filledRectangle(x, y, w, h, self.background)
    return x, y, w, h
end

return VisualElement
