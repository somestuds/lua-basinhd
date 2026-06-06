Log = {}

--- @private
--- @param color integer
function Log._setColor(color)
    local oldColor = term.getTextColor()
    term.setTextColor(color)
    return oldColor
end

function Log.info(...)
    local oc = Log._setColor(colors.lightGray)
    local inf = debug.getinfo(2, 'S')
    print('' .. inf.short_src .. ':' .. inf.linedefined .. ' INFO>', ...)
    Log._setColor(oc)
end

function Log.warn(...)
    local oc = Log._setColor(colors.yellow)
    local inf = debug.getinfo(2, 'S')
    print('' .. inf.short_src .. ':' .. inf.linedefined .. ' WARN>', ...)
    Log._setColor(oc)
end

function Log.error(...)
    local oc = Log._setColor(colors.orange)
    local inf = debug.getinfo(2, 'S')
    print('' .. inf.short_src .. ':' .. inf.linedefined .. ' ERR>', ...)
    Log._setColor(oc)
end

--- @param err string
--- @param level? integer
function Log.errorfatal(err, level)
    level = level or 1
    error('ERRFATAL> ' .. err, level + 1)
end


--- @alias horizontalScreenAnchor 'left'|'center'|'right'|'none'
--- @alias verticalScreenAnchor 'top'|'center'|'bottom'|'none'
--- @alias nineWayScreenAnchor 'topLeft'|'topMiddle'|'topRight'|'centerLeft'|'centerMiddle'|'centerRight'|'bottomLeft'|'bottomMiddle'|'bottomRight'
UniversalTextHeight = 8

--- @param value number
--- @param min number
--- @param max number
--- @return number
function math.clamp(value, min, max)
    if not value or not min or not max then
        error(
            'Invalid parameters for math.clamp\nValue:' ..
            tostring(value) .. '\nmin:' .. tostring(min) .. '\nmax:' .. tostring(max), 2)
    end
    return math.max(min, math.min(max, value))
end

--- @param value number
--- @return number
function math.round(value)
    return math.floor(value + 0.5)
end

--- @param hex string|integer
--- @return number
function colors.hexToInteger(hex)
    if type(hex) == 'number' then return hex end
    return tonumber(hex:gsub('^#', ''):gsub('^0x', ''), 16) or 0x000000
end

--- @return integer
function colors.random()
    return math.random() * 16777215
end

--- @param a integer
--- @param b integer
--- @param t number
function colors.lerp(a, b, t)
    return a + (b - a) * t
end

--- @generic T: any
--- @param value string
--- @param conditions table<string, T>
--- @return T?
function Switch(value, conditions)
    local condition = conditions[value] or conditions['_']
    if condition then
        if type(condition) == 'function' then
            return condition()
        else
            return condition
        end
    else
        Log.errorfatal('No condition found for switch statement', 2)
    end
end

function string:includes(query)
    return self:find(query) ~= nil
end