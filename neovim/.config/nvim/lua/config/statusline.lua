local colors = require("config.colors")

-- The problem is that some functions can be too expensive to be called on each
-- statusline update. Instead, this keeps a cache of the last result and the
-- time it was executed, per buffer. Then, this cache is used to limit the
-- function to only be executed once every min_reexec_seconds per buffer.
local expensive_func = function(func, min_reexec_seconds)
    -- Map between buffer numbers and { func() result, last execution time }
    local cache = {}

    return function()
        local bufnum = vim.api.nvim_get_current_buf()
        local cache_result = cache[bufnum]

        if (cache_result == nil or
            os.difftime(os.time(), cache_result[2]) > min_reexec_seconds) then
            local result = func()
            cache[bufnum] = { result, os.time() }
            return result
        end

        return cache_result[1]
    end
end

-- Configure the filename component for both active and inactive
local filename = {
    "filename",
    -- Show relative path
    path = 1,
    -- Mark when the file doesn't exist (but there is a file name)
    newfile_status = true,
    symbols = { newfile = "[*]" }
}

-- Display a mark if the buffer is a temporary buffer
local temp_mark_inactive = {
    function() return "temp" end,
    cond = function()
        return vim.api.nvim_buf_get_option(0, "bufhidden") ~= "" or
               not vim.api.nvim_buf_get_option(0, "buflisted")
    end,
}
local temp_mark = vim.tbl_extend("force", temp_mark_inactive, {
    color = { fg = colors.yellow }
})

-- Instead of just git branch, use "git describe" to get a more indicative
-- status of the current commit
local git_describe = {
    expensive_func(function()
        local git_dir = vim.fn.FugitiveGitDir()
        if git_dir == "" then return "" end

        local cmd = "git --git-dir=%s describe --contains --all HEAD 2>&1"
        cmd = cmd:format(git_dir)
        return vim.fn.system(cmd):gsub("\n", "")
    end, 5),
    icon = ""
}

local theme = {
    normal = {
        a = { fg = colors.statusline, bg = colors.blue, gui = "bold" },
        b = { fg = colors.text, bg = colors.active },
        c = { fg = colors.inactive, bg = colors.statusline }
    },
    visual = {
        a = { fg = colors.statusline, bg = colors.orange, gui = "bold" },
    },
    replace = {
        a = { fg = colors.statusline, bg = colors.red, gui = "bold" },
    },
    insert = {
        a = { fg = colors.statusline, bg = colors.green, gui = "bold" },
    }
}

-- lualine still leaves the one character in between vertical buffers unset, so
-- set it to match the statusline color
require("config.utils").apply_highlights({
    StatusLine = { bg = colors.statusline },
    StatusLineNC = { bg = colors.statusline }
})

local options = { theme = theme }
-- Use basic symbols if fancy fonts are not available
if os.getenv("NVIM_NO_FANCY_FONTS") then
    options["component_separators"] = "|"
    options["section_separators"] = ""
    options["icons_enabled"] = false
end

require('lualine').setup({
    options = options,
    sections = {
        lualine_a = {"mode"},
        -- Prefer the filename over the branch name, to have the branch name
        -- truncated when needed
        lualine_b = { temp_mark, filename },
        lualine_c = { git_describe },
        lualine_x = {
            -- LSP's init progress (from lualine-lsp-progress plugin)
            {
                "lsp_progress",
                -- Only show if the buffer has an LSP client attached
                cond = function() return #vim.lsp.buf_get_clients() > 0 end
            },
            -- Count of each diagnostic type
            {
                "diagnostics",
                symbols = {
                    error = "E:", warn = "W:", info = "I:", hint = "H:"
                },
            }
        },
        lualine_y = {"filetype"},
        lualine_z = {
            -- A percentage of where we are in the file
            {
                "progress",
                -- Only show if the window is big enough
                cond = function() return vim.fn.winwidth(0) >= 80 end
            },
            -- Current line and column
            "location"
        }
    },

    -- Sections when the window is not the active one
    inactive_sections = {
        lualine_c = {
            -- Show window number to make it easier to switch to exact window
            -- (using [number]<C-w>w)
            function() return vim.api.nvim_win_get_number(0) end,
            temp_mark_inactive,
            filename
        },
        lualine_x = {
            "location",
        }
    },

    -- Display statusline of quickfix/location list nicely
    extensions = { "quickfix" }
})
