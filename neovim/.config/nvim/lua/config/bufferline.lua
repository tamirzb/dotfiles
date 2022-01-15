-- Colors to be used in the bar, mostly based on the hybrid colorscheme's
-- colors. If ever moving to a lua-based colorscheme, it would probably make
-- sense to remove this and just use the colorscheme's values directly.
local colors = {
    bar_bg = "#181818",

    unfocused_bg = "#373b41",
    unfocused_fg = "#707880",

    focused_bg = "NONE",
    focused_fg = "#c5c8c6",

    modified = "#b5bd68",
    readonly = "#cc6666"
}

-- cokeline bases the color of its bar on the TabLineFill highlight group
vim.cmd("highlight TabLineFill guifg=" .. colors.bar_bg)

-- Shorten path until hopefully reaching a length of less than
-- truncation_target
-- Shortening as in: path/to/file -> p/t/file
local shorten_path = function(path, truncation_target)
    -- Iterate each path component
    for _ = 0, select(2, string.gsub(path, "/", '')) do
        if truncation_target and #path <= truncation_target then break end
        path = path:gsub('([^/])[^/]+%/', '%1/', 1)
    end
    return path
end

require("cokeline").setup({
    show_if_buffers_are_at_least = 2,

    -- If the buffer will disappear when it's no longer displayed by a window,
    -- don't show it
    buffers = {
        filter_valid = function(buffer)
            return vim.api.nvim_buf_get_option(buffer.number, "bufhidden") == ""
        end
    },

    default_hl = {
        focused = { fg = colors.focused_bg, bg = colors.focused_bg },
        unfocused = { fg = colors.unfocused_fg, bg = colors.unfocused_bg }
    },

    components = {
        { text = "" , hl = { fg = colors.bar_bg } },

        -- Since <leader>NUM can switch to max buffer number 10, if we surpass
        -- this number we can switch to buffers using their pick letter
        -- instead.

        -- Buffer index
        { text = function(buffer)
            return buffer.index <= 10 and buffer.index or ""
        end },
        -- Pick letter (letter to type in order to pick this buffer)
        { text = function(buffer)
            return buffer.index > 10 and buffer.pick_letter:upper() or ""
        end },
        -- Separator after buffer index/pick letter
        { text = "  " },

        -- Unique prefix (if more than one file with the same filename is open)
        { text = function(buffer)
            -- Overall length should ideally be <= 30
            return shorten_path(buffer.unique_prefix, 30 - #buffer.filename)
        end },
        -- File name
        { text = function(buffer) return buffer.filename end },

        -- Indicate if the buffer is readonly
        { text = function(buffer)
            return buffer.is_readonly and "[-]" or ""
        end, hl = { fg = function(buffer)
            -- Only display readonly color if the buffer is focused
            return buffer.is_focused and colors.readonly or colors.unfocused_fg
        end } },

        -- Indicate if the buffer was modified
        { text = function(buffer)
            return buffer.is_modified and "[+]" or ""
        end, hl = { fg = colors.modified } },

        { text = " " , hl = { fg = colors.bar_bg } },
    }
})

-- Map <leader>NUM to switch to buffer NUM
local keymaps = {}
for i = 1,10 do
    -- <leader>0 should switch to buffer number 10
    local key = i == 10 and "0" or tostring(i)
    keymaps[key] = {
        string.format("<Plug>(cokeline-focus-%s)", i), "which_key_ignore"
    }
end

-- <leader><leader>LETTER should switch to buffer according to pick letter
keymaps["<leader>"] = {
    "<Plug>(cokeline-pick-focus)", "Switch to buffer by its \"pick letter\""
}

require("which-key").register(keymaps, { prefix = "<leader>" })
