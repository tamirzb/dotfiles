local colors = require("config.colors")

-- Set symbols based on whether fancy fonts are enabled
local symbols
if os.getenv("NVIM_NO_FANCY_FONTS") then
    symbols = {
        pre_separator = "",
        post_separator = " ",
        padding = " ",
        inside_separator = " | ",
        git = ""
    }
else
    symbols = {
        pre_separator = "",
        post_separator = "",
        padding = "",
        inside_separator = "  ",
        git = " "
    }
end

-- Get the background color a given buffer should have
local get_bg_color = function (buffer)
    return buffer.is_focused and colors.active or colors.window
end

local is_fugitive_buffer = function(buffer)
    return buffer.path:match("^fugitive:///") ~= nil
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
    -- Used to be TabLineFill, now seems to be TabLine. Doing both just in
    -- case.
    TabLine = { bg = colors.background },
    TabLineFill = { bg = colors.background }
})

require("cokeline").setup({
    show_if_buffers_are_at_least = 2,

    buffers = {
        -- If the buffer will disappear when it's no longer displayed by a
        -- window, don't show it
        filter_valid = function(buffer)
            return vim.api.nvim_buf_get_option(buffer.number, "bufhidden") == ""
        end,

        -- After deleting a buffer, focus on the buffer to its right
        focus_on_delete = "next"
    },

    default_hl = {
        fg = function(buffer)
            return buffer.is_focused and colors.text or colors.inactive
        end,
        bg = get_bg_color
    },

    components = {
        { text = symbols.pre_separator,  fg = get_bg_color,
                 bg = colors.background },
        { text = symbols.padding , bg = get_bg_color },

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
        { text = symbols.inside_separator },

        -- Indicate if it's a fugitive buffer
        { text = function(buffer)
            return is_fugitive_buffer(buffer) and symbols.git or ""
        end },

        -- Unique prefix (if more than one file with the same filename is open)
        { text = function(buffer)
            -- Fugitive's unique prefixes are not very indicative
            if is_fugitive_buffer(buffer) then return "" end

            -- Overall length should ideally be <= 30
            return shorten_path(buffer.unique_prefix, 30 - #buffer.filename)
        end },
        -- File name
        { text = function(buffer) return buffer.filename end },

        -- Indicate if the buffer is readonly
        { text = function(buffer)
            return buffer.is_readonly and "[-]" or ""
        end, fg = function(buffer)
            -- Only display readonly color if the buffer is focused
            return buffer.is_focused and colors.red or colors.inactive
        end },

        -- Indicate if the buffer was modified
        { text = function(buffer)
            return buffer.is_modified and "[+]" or ""
        end, fg = colors.green },

        { text = symbols.padding , bg = get_bg_color },
        { text = symbols.post_separator , fg = get_bg_color,
                 bg = colors.background },
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
