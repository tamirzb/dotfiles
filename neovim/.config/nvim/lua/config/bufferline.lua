local colors = require("config.colors")

-- Get the background color a given buffer should have
local get_bg_color = function (buffer)
    return buffer.is_focused and colors.active or colors.window
end

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

-- Set the bar background
-- Other than this Cokeline should take care of applying highlights
require("config.utils").apply_highlights({
    TablineFill = { bg = colors.background }
})

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
        focused = { fg = colors.text, bg = colors.active },
        unfocused = { fg = colors.inactive, bg = colors.window }
    },

    components = {
        { text = "" , hl = { fg = get_bg_color, bg = colors.background } },

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
            return buffer.is_focused and colors.red or colors.inactive
        end } },

        -- Indicate if the buffer was modified
        { text = function(buffer)
            return buffer.is_modified and "[+]" or ""
        end, hl = { fg = colors.green } },

        { text = "" , hl = { fg = get_bg_color, bg = colors.background } },
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
