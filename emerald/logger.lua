local module = {}

local escape = '\027['

local function hslToRgb(hue, sat, light)
    hue = (360 + (hue % 360)) % 360
    sat = math.min(1, math.max(0, sat))
    light = math.min(1, math.max(0, light))

    local out = {}

    for i = 1, 3, 1 do
        local n = ({ 0, 8, 4 })[i]
        local k = (n + hue / 30) % 12
        local a = sat * math.min(light, 1 - light)
        out[i] = bit.bor(((light - a * math.max(-1, math.min(k - 3, 9 - k, 1))) * 255), 0)
    end

    return table.concat(out, ';')
end

local sequence = 0
local function prefixColor(isEmerald)
    sequence = sequence + 47

    if isEmerald then
        return {
            escape .. '48;2;45;86;37m' .. escape .. '38;2;170;255;153m',
            escape .. '48;2;50;96;41m' .. escape .. '38;2;194;251;182m'
        }
    end

    return {
        escape .. '48;2;' .. hslToRgb(sequence, 0.4, 0.24) .. 'm' .. escape .. '38;2;' .. hslToRgb(sequence, 1.0, 0.8) .. 'm',
        escape .. '48;2;' .. hslToRgb(sequence, 0.4, 0.27) .. 'm' .. escape .. '38;2;' .. hslToRgb(sequence, 0.9, 0.85) .. 'm'
    }
end

local function getDateString()
    return os.date(' %X ')
end

local levels = {
    error = escape .. '48;2;255;71;87m ERROR ',
    warn = escape .. '48;2;247;159;31m WARN ',
    info = escape .. '48;2;55;66;250m INFO ',
    debug = escape .. '48;2;65;66;67m DEBUG '
}

function module:getLogger(prefix)
    local isEmerald = false

    if prefix:match('^emerald:') then isEmerald = true end
    local colors = prefixColor(isEmerald)

    local function makePrefix()
        return colors[1] .. getDateString() .. colors[2] .. ' ' .. prefix .. ' '
    end

    local function log(level, message)
        print(makePrefix() .. escape .. '0m' .. levels[level] .. escape .. '0m ' .. message)
    end

    return {
        debug = function(message) log('debug', message) end,
        info = function(message) log('info', message) end,
        warn = function(message) log('warn', message) end,
        error = function(message) log('error', message) end
    }
end

function module:getLoggerScope(scope)
    return function(prefix)
        return module:getLogger(scope .. ':' .. prefix)
    end
end

return module