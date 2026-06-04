local VisualElement = require('basinhd.elm.VisualElement')
local TextLabel = require('basinhd.elm.TextLabel')
--- @class Button : VisualElement
local Button = setmetatable({}, { __index = VisualElement })
Button.__index = Button
Button.className = 'Button'

Button.width = 8
Button.height = 6
Button.background = 0x828282
--- @type function
Button.onclick = function() end
Button.textenabled = true
Button._textLabel = nil
--- @type horizontalScreenAnchor
Button.htanchor = 'center'
--- @type verticalScreenAnchor
Button.vtanchor = 'center'
Button.text = 'Button'
Button.textOffset = { 0, 0 }


--- @param onclick function
function Button:onClick(onclick)
    self.onclick = onclick
    return self
end

--- @param enabled boolean
function Button:setEnabled(enabled)
    self.enabled = enabled
    return self
end

--- @param text string
function Button:setText(text)
    self.text = text
    self._textLabel:setText(text)
    return self
end

--- @param textEnabled boolean
function Button:setTextEnabled(textEnabled)
    self.textenabled = textEnabled
    self._textLabel:setVisible(textEnabled)
    return self
end

--- @param horizontalAnchor horizontalScreenAnchor
--- @param verticalAnchor verticalScreenAnchor
function Button:setTextAnchor(horizontalAnchor, verticalAnchor)
    self.htanchor, self.vtanchor = horizontalAnchor, verticalAnchor
    self._textLabel:setTextAnchor(horizontalAnchor, verticalAnchor)
    return self
end

--- @param x number
--- @param y number
function Button:setTextOffset(x, y)
    self.textOffset = { x + 1, y + 1 }
    self._textLabel:setPosition(table.unpack(self.textOffset))
    return self
end

-- --- @param self Button
-- --- @param parent? BaseElement
-- --- @return Button
-- function Button:new(parent)
--     ---@class Button
--     local button = setmetatable({}, { __index = VisualElement.new(self, parent) })
--     button.__index = button
--     button._textLabel = TextLabel:new(button)
--     button._textLabel:setTextAnchor('center', 'center')
--     return button
-- end

--- @protected
function Button:_postInit()
    self._textLabel = TextLabel:new(self)
    self._textLabel:setTextAnchor('center', 'center')
    self._textLabel:setText('Button')
end

function Button:_render()
    if not self.visible then return 0, 0, 0, 0 end
    local x, y, w, h = VisualElement._render(self)
    if h >= UniversalTextHeight and self.textenabled then self._textLabel:_render() end
    return x, y, w, h
end

return Button
