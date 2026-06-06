local VisualElement = require('basinhd.elm.VisualElement')
local TextLabel = require('basinhd.elm.TextLabel')
--- @class Button : VisualElement
local Button = setmetatable({}, { __index = VisualElement })
Button.__index = Button
Button._className = 'Button'

Button.width = 8
Button.height = 6
Button.background = 0x828282
--- @private
--- @type function
Button.onclick = function() end
--- @private
--- @type function
Button.onhover = function() end
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

--- @param onhover function
function Button:onHover(onhover)
    self.onhover = onhover
    return self
end

--- @protected
--- @param hovering boolean
function Button:_hover(hovering)
    self.onhover(self, hovering)
end

--- @protected
function Button:_click()
    self.onclick(self)
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

--- @param scale integer
function Button:setTextScale(scale)
    self._textLabel:setTextScale(scale)
    return self
end

--- @protected
function Button:_postInit()
    VisualElement._postInit(self)
    self.textOffset = { 0, 0 }
    self._textLabel = {}
    self._textLabel = TextLabel:new(self)
    self._textLabel:setTextAnchor('center', 'center')
    self._textLabel:setPosition(0, 0)
end

function Button:_render()
    local rendered = VisualElement._render(self)
    if not rendered then return false end

    if self.height >= UniversalTextHeight and self.textenabled then
        self._textLabel:_render()
    end
    return true
end

return Button
