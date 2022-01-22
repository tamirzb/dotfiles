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

return M
