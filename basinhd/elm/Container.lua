local VisualElement = require('basinhd.elm.VisualElement')
local Button = require('basinhd.elm.Button')
local TextLabel = require('basinhd.elm.TextLabel')
--- @class Container : VisualElement
local Container = setmetatable({}, { __index = VisualElement })
Container.__index = Container
Container.className = 'Container'

--- @generic T: VisualElement
--- @type T[]
Container.children = {}

--- @generic T: Container
--- @param self T
--- @return Button
function Container:addButton()
    local button = Button:new(self)
    table.insert(self.children, button)
    return button
end

--- @generic T: Container
--- @param self T
--- @return TextLabel
function Container:addText()
    local text = TextLabel:new(self)
    table.insert(self.children, text)
    return text
end

function Container:_render()
    if not self.visible then return 0, 0, 0, 0 end
    local x, y, w, h = VisualElement._render(self)

    table.sort(self.children, function(a, b)
        return a._definitionPeriod > b._definitionPeriod
    end)
    for _, child in ipairs(self.children) do
        child:_render()
    end
    return x, y, w, h
end

return Container
