local Container = require('basinhd.elm.Container')

local BasinHD = {}
BasinHD.gpu = nil
BasinHD.isAlive = false

--- @param gpu ccTweaked.peripheral.wrappedPeripheral
--- @return Container
function BasinHD:getMainFrame(gpu)
    assert(gpu, 'Please provide a tm_gpu peripheral as a parameter')
    self.gpu = gpu
    if not self.mainFrame then
        self.gpu.refreshSize()
        self.gpu.setSize(64)
        self.gpu.fill()

        local gpuSize = { gpu.getSize() }

        --- @class Container
        self.mainFrame = Container:new()
            :setPositionAndSize(1, 1, self.gpu.getSize())

        self.mainFrame.root = {
            _counter = 0,
            gpu = gpu,
            gpu_maxwidth = gpuSize[1],
            gpu_maxheight = gpuSize[2],
            _buttons = {},
            _frames = {},
            _alwaysOnTopElements = {},
            _elements = {},
            renderingAOT = false
        }
        self.cursor = self.mainFrame:addImage()
            :setVisible(false)
            :setImage('basinhd/cursor.png')
            :setPosition(1, 1)
            :setAlwaysOnTop(true)
    end
    return self.mainFrame
end

---@private
--- @param eventName string
--- @param func function
function BasinHD:_listenForEvent(eventName, func)
    return function()
        while self.isAlive do
            os.sleep(0)
            local eventParams = { os.pullEvent(eventName) }
            if not self.isAlive then break end
            table.remove(eventParams, 1)
            func(table.unpack(eventParams))
        end
    end
end

--- @private
function BasinHD:_wrap(func)
    return function()
        func(self)
    end
end

--- @private
function BasinHD:_renderThread()
    local FPS = 240
    repeat
        local time = os.epoch('utc')
        self.mainFrame:_render()

        table.sort(self.mainFrame.root._alwaysOnTopElements, function(a, b)
            return a._definitionPeriod < b._definitionPeriod
        end)
        self.mainFrame.root.renderingAOT = true
        for i = 1, #self.mainFrame.root._alwaysOnTopElements do
            self.mainFrame.root._alwaysOnTopElements[i]
                :_render()
        end
        self.mainFrame.root.renderingAOT = false

        self.gpu.sync()
        os.sleep(math.max(0, ((1000 / FPS) - (os.epoch('utc') - time))) / 1000)
    until not self.isAlive
end


function BasinHD:run()
    assert(self.mainFrame, 'No main frame found.')
    self.isAlive = true
    parallel.waitForAny(
        self:_wrap(self._renderThread),
        self:_listenForEvent('tm_monitor_mouse_move', function(_, mx, my)
            local width, height = self.cursor:getSize()
            self.cursor:setPosition(
                math.clamp(mx - (width / 2), 1, 1 + self.mainFrame.root.gpu_maxwidth - width),
                math.clamp(my - (height / 2), 1, 1 + self.mainFrame.root.gpu_maxheight - height)
            )

            for _, button in pairs(self.mainFrame.root._buttons) do
                if button:_positionInBounds(mx, my) then
                    button:_hover(true)
                else
                    button:_hover(false)
                end
            end
        end),
        self:_listenForEvent('tm_monitor_mouse_enter', function()
            self.cursor:setVisible(true)
        end),
        self:_listenForEvent('tm_monitor_mouse_exit', function()
            self.cursor:setVisible(false)
        end),
        self:_listenForEvent('tm_monitor_mouse_click', function(_, mx, my)
            for _, button in pairs(self.mainFrame.root._buttons) do
                if button:_positionInBounds(mx, my) then
                    button:_click()
                end
            end
        end)
    )
end

function BasinHD:stop()
    self.isAlive = false
    self.gpu.fill()
    self.gpu.sync()
end

return BasinHD
