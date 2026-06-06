require('basinhd.util')

--- @class BaseElement
local BaseElement = {}
BaseElement.__index = BaseElement
--- @protected
BaseElement._className = 'BaseElement'
--- @protected
--- @type number
BaseElement._definitionPeriod = 0

BaseElement.x = 1
BaseElement.y = 1
--- @protected
BaseElement._absoluteX = 1
--- @protected
BaseElement._absoluteY = 1
BaseElement.z = 1
BaseElement.visible = true
BaseElement.alwaysOnTop = false

--- @generic T : BaseElement
--- @param self T
--- @param x integer
--- @param y integer
--- @return T
function BaseElement:setPosition(x, y)
    self:setX(x)
    self:setY(y)
    return self
end

--- @generic T : BaseElement
--- @param self T
--- @param x integer
--- @return T
function BaseElement:setX(x)
    if x < 0 then
        self.x = 1 + self.parent.width + x
    else
        self.x = x
    end
    return self
end

--- @generic T : BaseElement
--- @param self T
--- @param y integer
--- @return T
function BaseElement:setY(y)
    if y < 0 then
        self.y = 1 + self.parent.height + y
    else
        self.y = y
    end
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

--- @generic T : BaseElement
--- @param self T
--- @param aot boolean
--- @return T
function BaseElement:setAlwaysOnTop(aot)
    self.alwaysOnTop = aot
    if aot then
        table.insert(self.root._alwaysOnTopElements, self)
    else
        local found = nil
        for i, aote in pairs(self.root._alwaysOnTopElements) do
            if aote._definitionPeriod == self._definitionPeriod then
                found = i
            end
        end
        if found then
            table.remove(self.root._alwaysOnTopElements, found)
        end
    end
    return self
end

--- @protected
--- @generic T : BaseElement
--- @param self T
--- @param aoX? integer
--- @param aoY? integer
--- @return T
function BaseElement:_alignToParent(aoX, aoY)
    if self.parent then
        self._absoluteX = -1 + self.parent._absoluteX + self.x + (aoX or 0)
        self._absoluteY = -1 + self.parent._absoluteY + self.y + (aoY or 0)
    end
    return self
end

function BaseElement:_postInit()
    self._buttons = {}
    self._frames = {}
end

--- @generic T : BaseElement
--- @param self T
--- @param parent? BaseElement
--- @return T
function BaseElement:new(parent)
    local new = setmetatable({}, { __index = self })
    new.__index = new

    new.parent = parent
    new.root = parent and parent.root
    if new.root then
        new.root._counter = new.root._counter + 1
        new._definitionPeriod = new.root._counter

        if new._className == 'Button' then
            table.insert(new.root._buttons, new)
        elseif new._className == 'Frame' then
            table.insert(new.root._frames, new)
        else
            table.insert(new.root._elements, new)
        end
    end

    local postInit = new._postInit
    if postInit ~= nil and type(postInit) == 'function' then
        new:_postInit()
    else
        Log.errorfatal('Element by classname ' .. new._className .. ' does not have postInit')
    end

    return new
end

function BaseElement:remove()
    if self.children then
        for i = #self.children, 1, -1 do
            self.children[i]:remove()
            self.children[i] = nil
        end
    end

    if self.parent and self.parent.children then
        for i = #self.parent.children, 1, -1 do
            if self.parent.children[i] == self then
                table.remove(self.parent.children, i)
                break
            end
        end
    end

    -- 3. clear references
    self.parent = nil
    self.children = nil
end

---@return boolean
function BaseElement:_render()
    if self.alwaysOnTop and not self.root.renderingAOT then return false end
    if not self.visible then return false end
    return true
end

return BaseElement
