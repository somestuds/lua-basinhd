local BaseElement = require('basinhd.elm.BaseElement')
local VisualElement = require('basinhd.elm.VisualElement')
--- @class TextLabel : BaseElement
local TextLabel = setmetatable({}, { __index = BaseElement })
TextLabel.__index = TextLabel
TextLabel._className = 'TextLabel'

--- @type { x: integer, y: integer }
TextLabel.textOffset = { x = 0, y = 0 }
TextLabel.text = 'Hello, World!'
TextLabel.textScale = 1
TextLabel.foreground = VisualElement.foreground
--- @type horizontalScreenAnchor
TextLabel.horizontalAnchor = 'left'
--- @type verticalScreenAnchor
TextLabel.verticalAnchor = 'top'

--- @param foreground number
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

--- @param self TextLabel
--- @param x integer
--- @return TextLabel
function TextLabel:setX(x)
    if x < 0 then
        self.textOffset.x = self.textOffset.x + (x - 1)
    else
        self.textOffset.x = x - 1
    end
    return self
end

--- @param self TextLabel
--- @param y integer
--- @return TextLabel
function TextLabel:setY(y)
    if y < 0 then
        self.textOffset.y = self.textOffset.y + (y - 1)
    else
        self.textOffset.y = y - 1
    end
    return self
end

--- @protected
function TextLabel:_postInit()
    BaseElement._postInit(self)
    self.textOffset = {
        x = 0,
        y = 0
    }
end

--- @private
--- @return { truncatedText: string, x: integer, y: integer }
function TextLabel:_preRender()
    local text = self.text
    local textLength = self.root.gpu.getTextLength(text) * self.textScale
    local textHeight = UniversalTextHeight * self.textScale

    while textLength > self.parent.width do
        if textLength <= self.parent.width then break end
        text = text:sub(1, -2)
        textLength = self.root.gpu.getTextLength(text) * self.textScale
    end

    self.x = Switch(self.horizontalAnchor, {
        none = self.x,
        left = 1,
        center = 1 + math.round((self.parent.width / 2) - (textLength / 2)),
        right = 1 + math.round(self.parent.width - textLength)
    })
    self.y = Switch(self.verticalAnchor, {
        none = self.y,
        top = 1,
        center = 1 + math.round((self.parent.height / 2) - (textHeight / 2)),
        bottom = 1 + math.round(self.parent.height - textHeight)
    })

    self.x = math.clamp(self.x, 1, self.parent.width - textLength)
    self.y = math.clamp(self.y, 1, self.parent.height - textHeight)
    self.textOffset.x = math.clamp(self.textOffset.x, 0, -1 + self.parent.width - textLength)
    self.textOffset.y = math.clamp(self.textOffset.y, 0, -1 + self.parent.height - textHeight)
    self:_alignToParent()

    return {
        truncatedText = text,
        tl = textLength
    }
end

--- @return boolean
function TextLabel:_render()
    local render = BaseElement._render(self)
    if not render then return false end

    local preRender = self:_preRender()
    local x, y = self._absoluteX + self.textOffset.x, self._absoluteY + self.textOffset.y
    self.root.gpu.drawText(
        x, y,
        preRender.truncatedText,
        self.foreground,
        self.parent.background,
        self.textScale)

    return true
end

return TextLabel
