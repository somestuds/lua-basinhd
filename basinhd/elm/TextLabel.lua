local BaseElement = require('basinhd.elm.BaseElement')
local VisualElement = require('basinhd.elm.VisualElement')
--- @class TextLabel : BaseElement
local TextLabel = setmetatable({}, { __index = BaseElement })
TextLabel.__index = TextLabel

TextLabel.text = 'Hello, World!'
TextLabel.textScale = 1
TextLabel.foreground = VisualElement.foreground
--- @type horizontalScreenAnchor
TextLabel.horizontalAnchor = 'none'
--- @type verticalScreenAnchor
TextLabel.verticalAnchor = 'none'

---@param foreground number
function TextLabel:setForeground(foreground)
    VisualElement.setForeground(self, foreground)
    return self
end

--- @param horizontalAnchor horizontalScreenAnchor
--- @param verticalAnchor verticalScreenAnchor
function TextLabel:setTextAnchor(horizontalAnchor, verticalAnchor)
    self.horizontalAnchor = horizontalAnchor
    self.verticalAnchor = verticalAnchor
    return self
end

--- @param text string
function TextLabel:setText(text)
    self.text = text
    return self
end

--- @param scale integer
function TextLabel:setTextScale(scale)
    self.textScale = scale
    return self
end

function TextLabel:_render()
    if not self.visible then return 0, 0, 0, 0 end
    local x, y = self.x, self.y
    local w, h = self.parent.width, self.parent.height
    local text = self.text
    local textLength, textHeight = _G.gpu.getTextLength(text), UniversalTextHeight
    if textLength > w then
        repeat
            text = text:sub(1, -2)
            textLength = _G.gpu.getTextLength(text)
        until textLength <= w
    end

    local tx, ty = Switch(self.horizontalAnchor, {
        none = x,
        left = 1,
        center = 1 + math.round((w / 2) - (textLength / 2)),
        right = 1 + math.round(w - textLength)
    }) + (x - 1), Switch(self.verticalAnchor, {
        none = y,
        top = 1,
        center = 1 + math.round((h / 2) - (textHeight / 2)),
        bottom = 1 + math.round(h - textHeight)
    }) + (y - 1)
    tx, ty = math.clamp(tx, 1, self.parent.width - textLength), math.clamp(ty, 1, self.parent.height - textHeight)
    tx, ty = BaseElement._alignChildToParent(self.parent, tx, ty)
    _G.gpu.drawText(tx, ty, text, self.foreground, self.parent.background, self.textScale)
end

return TextLabel
