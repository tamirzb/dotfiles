-- Configure which-key, a plugin that will show help when stuck in the middle
-- of a keymap

local colors = require("config.colors")

require("which-key").setup({
    -- Use which-key for spelling corrections (with z=)
    plugins = { spelling = true },
    -- Adding count to motions (e.g. d2) seems to be displaying which-key
    -- immediately, so better without it
    motions = { count = false }
})

-- Set colors for the which-key window
require("config.utils").apply_highlights({
    WhichKey = { fg = colors.yellow, style = "bold"},
    WhichKeyGroup = { fg = colors.inactive },
    WhichKeyDesc = { fg = colors.blue },
    WhichKeySeperator = { fg = colors.text },
    WhichKeyFloat = { bg = colors.window }
})
