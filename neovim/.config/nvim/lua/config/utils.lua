local M = {}

-- Apply a highlights table of the format:
-- { GroupName = { fg = "*COLOR*", bg = "*COLOR*", sp = "*COLOR*",
--                 style = "*STYLE*" } }
M.apply_highlights = function(highlights)
    for group, color in pairs(highlights) do
        vim.cmd("highlight " .. group .. " " ..
                "gui=" .. (color.style or "NONE") .. " " ..
                "guifg=" .. (color.fg or "NONE") .. " " ..
                "guibg=" .. (color.bg or "NONE") .. " " ..
                "guisp=" .. (color.sp or "NONE"))
    end
end

-- Easier API to set a vim keymap using lua. Always has noremap, silent and
-- expr are configurable.
M.set_keymap = function(mode, lhs, rhs, expr, not_silent)
    vim.api.nvim_set_keymap(mode, lhs, rhs, { noremap = true,
                                              silent = not not_silent,
                                              expr = expr or false })
end

return M
