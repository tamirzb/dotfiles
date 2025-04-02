-- Configure which-key, a plugin that will show help when stuck in the middle
-- of a keymap

local colors = require("config.colors")

require("which-key").setup({
    -- Wait half a second before showing which-key
    -- When using which-key to autocomplete spelling corrections, show
    -- which-key immediately instead of waiting
    delay = function(ctx)
        return ctx.plugin == "spelling" and 0 or 500
    end,

    icons = {
        -- Don't show icons in which-key
        mappings = false,
        -- By default which-key uses some fancy font stuff for these which
        -- aren't really needed
        keys = {
            CR = "<CR>",
            Esc = "<Esc>",
            BS = "<Backspace>",
            Space = "<Space>",
            Tab = "<Tab>",
            C = "Ctrl-",
            M = "Alt-",
        }
    },
})

-- Set colors for the which-key window
require("config.utils").apply_highlights({
    WhichKey = { fg = colors.yellow, style = "bold"},
    WhichKeyGroup = { fg = colors.inactive },
    WhichKeyDesc = { fg = colors.blue },
    WhichKeySeperator = { fg = colors.text },
    WhichKeyFloat = { bg = colors.window }
})
