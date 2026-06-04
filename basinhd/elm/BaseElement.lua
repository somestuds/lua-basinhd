require('basinhd.util')

--- @class BaseElement
local BaseElement = {}
BaseElement.__index = BaseElement
BaseElement._className = 'BaseElement'
--- @protected
--- @type number
BaseElement._definitionPeriod = 0

BaseElement.x = 1
BaseElement.y = 1
BaseElement.z = 1
BaseElement.visible = true

--- @generic T : BaseElement
--- @param self T
--- @param x number
--- @param y number
--- @return T
function BaseElement:setPosition(x, y)
    self:setX(x)
    self:setY(y)
    return self
end

--- @generic T : BaseElement
--- @param self T
--- @param x number
--- @return T
function BaseElement:setX(x)
    self.x = x
    return self
end

--- @generic T : BaseElement
--- @param self T
--- @param y number
--- @return T
function BaseElement:setY(y)
    self.y = y
    return self
end

--- @generic T : BaseElement
--- @param self T
--- @param visible boolean
--- @return T
function BaseElement:setVisible(visible)
    self.visible = visible
    return self
end

--- @protected
--- @param sx number
--- @param x number
--- @return number
function BaseElement._localXToScreenX(sx, x)
    return (sx - 1) + x
end

--- @protected
--- @param sy number
--- @param y number
--- @return number
function BaseElement._localYToScreenY(sy, y)
    return (sy - 1) + y
end

--- @protected
--- @param parent BaseElement?
--- @param x number
--- @param y number
--- @return number, number
function BaseElement._alignChildToParent(parent, x, y)
    if parent then
        return -1 + parent.x + x, -1 + parent.y + y
    else
        return x, y
    end
end

--- @generic T : BaseElement
--- @param self T
--- @param parent? BaseElement
--- @return T
function BaseElement:new(parent)
    local new = setmetatable({}, { __index = self })
    new.__index = new

    local bounds = _G.gpu.getBounds()
    new.glw, new.glh = bounds.getW(), bounds.getH()
    new.parent = parent
    new._definitionPeriod = os.epoch('utc') / 1000

    local postInit = new._postInit
    if postInit ~= nil and type(postInit) == 'function' then
        new:_postInit()
    end

    return new
end

return BaseElement
