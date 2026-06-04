local Container = require('basinhd.elm.Container')

local BasinHD = {}
BasinHD.gpu = nil
BasinHD.isAlive = false

--- @param gpu ccTweaked.peripheral.wrappedPeripheral
--- @return Container
function BasinHD:getMainFrame(gpu)
    assert(gpu, 'Please provide a tm_gpu peripheral as a parameter')
    self.gpu = gpu
    _G.gpu = gpu
    if not self.mainFrame then
        self.gpu.refreshSize()
        self.gpu.setSize(64)
        self.gpu.fill()

        self.mainFrame = Container:new()
            :setPositionAndSize(1, 1, self.gpu.getSize())
    end
    return self.mainFrame
end

function BasinHD:stop()
    self.isAlive = false
    self.gpu.fill()
    self.gpu.sync()
end

function BasinHD:run()
    assert(self.mainFrame, 'No main frame found.')
    self.isAlive = true
    repeat
        local time = os.epoch('utc')
        self.mainFrame:_render()
        self.gpu.sync()
        os.sleep(math.max(0, ((1000 / 24) - (os.epoch('utc') - time))) / 1000)
    until not self.isAlive
end

return BasinHD
