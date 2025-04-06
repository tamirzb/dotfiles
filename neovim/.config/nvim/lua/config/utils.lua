local which_key = require('which-key')

local M = {}

-- Apply a highlights table
M.apply_highlights = function(highlights)
    for group, color in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, color)
    end
end

-- Easier API to set a vim keymap using lua. Always has noremap, silent and
-- expr are configurable.
M.set_keymap = function(mode, lhs, rhs, expr, not_silent)
    vim.api.nvim_set_keymap(mode, lhs, rhs, { noremap = true,
                                              silent = not not_silent,
                                              expr = expr or false })
end

-- which-key used to allow registering keymaps in this easy way where you can
-- supply opts for a bunch of keymaps at once but for some reason deperecated
-- it
M.which_key_register = function (keymaps, opts)
    local prefix = opts.prefix or ""
    for key, map in pairs(keymaps) do
        which_key.add({
            prefix .. key, map[1], desc = map[2],
            mode = opts.mode, buffer = opts.buffer
        })
    end
end

return M
