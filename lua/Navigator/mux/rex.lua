---@mod navigator.rex Rex navigator
---@brief [[
---This module provides navigation and interaction for Rex, and uses |navigator.vi|
---as a base class. This is used automatically when rex is detected on host system
---but can also be used to manually override the mux.
---
---Rex sets `REX_BLOCK` in every terminal it opens, and `REX_BIN_DIR` to the
---directory holding the `rex` that matches its server.
---
---Read also: https://www.superlogical.com/rex/docs/automate/cli.md
---@brief ]]

---@private
---@class Rex: Vi
---@field private direction table<Direction, string>
---@field private execute fun(arg: string): unknown
local Rex = require('Navigator.mux.vi'):new()

---Creates a new Rex navigator instance
---@return Rex
---@usage [[
---local ok, rex = pcall(function()
---    return require('Navigator.mux.rex'):new()
---end)
---
---require('Navigator').setup({
---    mux = ok and rex or 'auto'
---})
---@usage ]]
function Rex:new()
    assert(os.getenv('REX_BLOCK') ~= nil, '[Navigator] Rex is not running!')

    local U = require('Navigator.utils')
    local bin_dir = os.getenv('REX_BIN_DIR')
    local rex = (bin_dir ~= nil and bin_dir ~= '') and vim.fn.shellescape(bin_dir .. '/rex') or 'rex'

    ---@type Rex
    local state = {
        execute = function(arg)
            return U.execute(string.format('%s %s', rex, arg))
        end,
        direction = { p = 'prev', h = 'left', k = 'up', l = 'right', j = 'down' },
    }
    self.__index = self
    return setmetatable(state, self)
end

---Switch pane in rex
---@param direction Direction See |navigator.api.Direction|
---@return Rex
function Rex:navigate(direction)
    self.execute(string.format('focus %s', self.direction[direction]))
    return self
end

return Rex
