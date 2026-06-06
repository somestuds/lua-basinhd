local VisualElement = require('basinhd.elm.VisualElement')
--- @class Container : VisualElement
local Container = setmetatable({}, { __index = VisualElement })
Container.__index = Container
Container._className = 'Container'

Container.width = 60
Container.height = 40

--- @generic T: VisualElement
--- @type T[]
Container.children = {}

--- @generic T: Container
--- @param self T
--- @return Button
function Container:addButton()
    local Button = require('basinhd.elm.Button')
    local button = Button:new(self)
    table.insert(self.children, button)
    table.insert(self.root._buttons, button)
    return button
end

--- @generic T: Container
--- @param self T
--- @return TextLabel
function Container:addText()
    local TextLabel = require('basinhd.elm.TextLabel')
    local text = TextLabel:new(self)
    table.insert(self.children, text)
    return text
end

--- @generic T: Container
--- @param self T
--- @return Frame
function Container:addFrame()
    local Frame = require('basinhd.elm.Frame')
    local frame = Frame:new(self)
    table.insert(self.children, frame)
    return frame
end

--- @generic T: Container
--- @param self T
--- @return Image
function Container:addImage()
    local Image = require('basinhd.elm.Image')
    local image = Image:new(self)
    table.insert(self.children, image)
    return image
end

--- @protected
function Container:_postInit()
    VisualElement._postInit(self)
    self.children = {}
end

function Container:_render()
    local rendered = VisualElement._render(self)
    if not rendered then return false end

    table.sort(self.children, function(a, b)
        return a._definitionPeriod < b._definitionPeriod
    end)
    for i = 1, #self.children do
        local child = self.children[i]
        child:_alignToParent()
        child:_render()
    end

    return true
end

return Container
