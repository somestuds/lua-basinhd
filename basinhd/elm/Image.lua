local BaseElement = require('basinhd.elm.BaseElement')
local TextLabel = require('basinhd.elm.TextLabel')
--- @class Image : BaseElement
local Image = setmetatable({}, { __index = BaseElement })
Image.__index = Image
Image._className = 'Image'

--- @alias imgtype 'file'|'url'
--- @type {uri: string, type: imgtype}
Image.img = {}
--- @private
--- @type table
Image._imgbyte = {}
--- @private
--- @type boolean
Image._isProcessed = false
Image.desiredWidth = -1
Image.desiredHeight = -1
--- @private
--- @type string
Image._alias = ''
--- @private
--- @type TextLabel
Image._fallbackText = nil
--- @type integer
Image.decodedWidth = nil
--- @type integer
Image.decodedHeight = nil

--- @private
function Image:_process()
    if not self.img.type then
        self._isProcessed = false
        return
    end
    if self.img.type == 'url' then
        local imageHttpReachable, whyNot = http.checkURL(self.img.uri)
        if not imageHttpReachable then
            Log.warn('Could not reach image weburl for (' .. self._alias .. '):', whyNot)
            self._isProcessed = false
            return
        end

        local response = http.get(self.img.uri)
        if not response then
            self._isProcessed = false
            return
        end

        local pngRaw = response.readAll()
        self._imgbyte = { string.byte(pngRaw, 1, #pngRaw) }
        self._isProcessed = true
    elseif self.img.type == 'file' then
        local imageFileReachable = fs.exists(self.img.uri)
        if not imageFileReachable then
            Log.warn('Could not read image file for (' .. self._alias .. '); DOES NOT EXIST')
            self._isProcessed = false
            return
        end

        local imageFile = fs.open(self.img.uri, 'r')
        if not imageFile then
            Log.warn('Could not read image file for (' .. self._alias .. '); IN USE')
            self._isProcessed = false
            return
        end

        local pngRaw = imageFile.readAll()
        self._imgbyte = { string.byte(pngRaw, 1, #pngRaw) }
        self._isProcessed = true
    end
end

--- @param path string
function Image:setImage(path)
    local type = Switch(path:includes('https://') or path:includes('http://'), {
        [true] = 'url',
        [false] = 'file'
    })
    self.img = {
        uri = Switch(type, {
            url = 'https://wsrv.nl/?url=' ..
                path ..
                (self.desiredWidth ~= -1 and ('&w=' .. self.desiredWidth) or '') ..
                (self.desiredHeight ~= -1 and ('&h=' .. self.desiredHeight) or ''),
            file = path
        }),
        type = type
    }
    self._isProcessed = false
    return self
end

--- @param width integer
--- @param _isBundled? boolean
--- @return Image
function Image:setDesiredWidth(width, _isBundled)
    local dw = self.desiredWidth
    self.desiredWidth = width
    if not _isBundled and self._isProcessed and dw ~= width then
        self:_process()
    end
    return self
end

--- @param height integer
--- @param _isBundled? boolean
--- @return Image
function Image:setDesiredHeight(height, _isBundled)
    local dh = self.desiredHeight
    self.desiredHeight = height
    if not _isBundled and self._isProcessed and dh ~= height then
        self:_process()
    end
    return self
end

function Image:setDesiredSize(width, height)
    local dw, dh = self.desiredWidth, self.desiredHeight
    self:setDesiredWidth(width, true)
    self:setDesiredHeight(height, true)
    if self._isProcessed and (width ~= dw or height ~= dh) then
        self:_process()
    end
    return self
end

--- @return integer
function Image:getWidth()
    return self.decodedWidth or self.desiredWidth or 0
end

--- @return integer
function Image:getHeight()
    return self.decodedHeight or self.desiredHeight or 0
end

--- @return integer, integer
function Image:getSize()
    return self:getWidth(), self:getHeight()
end

function Image:_postInit()
    BaseElement._postInit(self)
    self.img = {}
    self._imgbyte = {}
    self._fallbackText = TextLabel:new(self.parent)
    self._fallbackText:setPosition(self.x, self.y)
    self._fallbackText:setVisible(false)
end

--- @protected
function Image:_render()
    local render = BaseElement._render(self)
    if not render then return false end

    if not self._isProcessed then
        self:_process()
        if not self._isProcessed then
            self._fallbackText:setVisible(true)
            self:setVisible(false)
            return false
        end
    end
    self._fallbackText:setVisible(false)
    self:setVisible(true)

    local decodedImage = self.root.gpu.decodeImage(table.unpack(self._imgbyte))
    if not self.decodedHeight or not self.decodedWidth then
        self.decodedWidth, self.decodedHeight = decodedImage:getWidth(), decodedImage:getHeight()
    end
    self.root.gpu.drawImage(self.x, self.y, decodedImage.ref())
    decodedImage.free()
    return true
end

return Image
