local BaseElement = require('basinhd.elm.BaseElement')

--- @class VisualElement: BaseElement
local VisualElement = setmetatable({}, { __index = BaseElement })
VisualElement.__index = VisualElement
VisualElement._className = 'VisualElement'

--- @type integer
VisualElement.width = 10
--- @type integer
VisualElement.height = 10
VisualElement.background = 0x000000
VisualElement.foreground = 0xFFFFFF
--- @protected
--- @type boolean
VisualElement._anchoredX = false
--- @protected
--- @type boolean
VisualElement._anchoredY = false
--- @type integer
VisualElement.anchorOffsetX = 0
--- @type integer
VisualElement.anchorOffsetY = 0

--- @generic T: VisualElement
--- @param self T
--- @param width integer
--- @param height integer
--- @return T
function VisualElement:setSize(width, height)
    self:setWidth(width)
    self:setHeight(height)
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param width integer
--- @return T
function VisualElement:setWidth(width)
    if width < 0 then
        self.width = self.width + width
    else
        self.width = width
    end
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param height integer
--- @return T
function VisualElement:setHeight(height)
    if height < 0 then
        self.height = self.height + height
    else
        self.height = height
    end
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param x integer
--- @param y integer
--- @param width integer
--- @param height integer
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

--- @generic T: VisualElement
--- @param self T
--- @param anchor horizontalScreenAnchor
--- @return T
function VisualElement:anchorToX(anchor)
    self._anchoredX = anchor ~= 'none'
    if self.parent and anchor ~= 'none' then
        self.x = Switch(anchor, {
            left = 1,
            center = 1 + (self.parent.width / 2) - (self.width / 2),
            right = 1 + self.parent.width - self.width
        })
    end
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param anchor verticalScreenAnchor
--- @return T
function VisualElement:anchorToY(anchor)
    self._anchoredY = anchor ~= 'none'
    if self.parent and anchor ~= 'none' then
        self.y = Switch(anchor, {
            top = 1,
            center = 1 + (self.parent.height / 2) - (self.height / 2),
            bottom = 1 + self.parent.height - self.height
        })
    end
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param x integer
--- @param y integer
--- @return T
function VisualElement:setAnchorOffset(x, y)
    self.anchorOffsetX = x
    self.anchorOffsetY = y
    return self
end

--- @generic T: VisualElement
--- @param self T
--- @param nineWayAnchor nineWayScreenAnchor
--- @return T
function VisualElement:anchorTo(nineWayAnchor)
    local xa, ya = table.unpack(Switch(nineWayAnchor, {
        topLeft = { 'left', 'top' },
        topMiddle = { 'center', 'top' },
        topRight = { 'right', 'top' },
        centerLeft = { 'left', 'center' },
        centerMiddle = { 'center', 'center' },
        centerRight = { 'right', 'center' },
        bottomLeft = { 'left', 'bottom' },
        bottomMiddle = { 'center', 'bottom' },
        bottomRight = { 'right', 'center' },
        _ = { 'left', 'top' }
    }))
    self:anchorToX(xa)
    self:anchorToY(ya)
    return self
end

--- @param x integer
--- @param y integer
--- @return boolean
function VisualElement:_positionInBounds(x, y)
    return self.x <= x and -1 + self.x + self.width >= x and self.y <= y and -1 + self.y + self.height >= y
end

--- @protected
function VisualElement:_fixDiscrepancies()
    --- @param element BaseElement
    local function getEndBoundsOf(element)
        if element then
            return -1 + element.x + element.width, -1 + element.y + element.height
        end
        return self.root.gpu_maxwidth, self.root.gpu_maxheight
    end

    if self.x <= 0 then
        self.width = self.width - (1 - self.x)
        self.x = 1
    end

    if self.y <= 0 then
        self.height = self.height - (1 - self.y)
        self.y = 1
    end

    local sbx, sby = getEndBoundsOf(self)
    local pbx, pby = getEndBoundsOf(self.parent)
    self.width = math.clamp(sbx, 1, pbx) - (self.x - 1)
    self.height = math.clamp(sby, 1, pby) - (self.y - 1)

    self.anchorOffsetX = math.clamp(self.anchorOffsetX, 1 - self.x,
        (self.parent and self.parent.width or self.root.gpu_maxwidth) - self.x)
    self.anchorOffsetY = math.clamp(self.anchorOffsetY, 1 - self.y,
        (self.parent and self.parent.height or self.root.gpu_maxheight) - self.y)

    self:_alignToParent(self._anchoredX and self.anchorOffsetX or 0, self._anchoredY and self.anchorOffsetY or 0)
end

function VisualElement:_postInit()
    BaseElement._postInit(self)
end

--- @return boolean
function VisualElement:_render()
    local render = BaseElement._render(self)
    if not render then return false end

    self:_fixDiscrepancies()
    if not self.visible or self.width <= 0 or self.height <= 0 then return false end
    self.root.gpu.filledRectangle(self._absoluteX, self._absoluteY, self.width, self.height, self.background)

    return true
end

return VisualElement
