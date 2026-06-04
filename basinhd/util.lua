--- @alias horizontalScreenAnchor 'left'|'center'|'right'|'none'
--- @alias verticalScreenAnchor 'top'|'center'|'bottom'|'none'
UniversalTextHeight = 8

--- @param value number
--- @param min number
--- @param max number
--- @return number
function math.clamp(value, min, max)
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
        error("No condition found for switch statement", 2)
    end
end

-- function SwitchFunction(value, conditions)
    
-- end