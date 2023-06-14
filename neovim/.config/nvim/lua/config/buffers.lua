-- Use Ctrl+e to delete a buffer without closing the window
require("which-key").register({
    ["<C-w>e"] = { "<cmd>Bwipeout<cr>", "Delete buffer" },
    ["<C-w><C-e>"] = { "<cmd>Bwipeout<cr>", "which_key_ignore" }
})

-- Add a command to make a temporary buffer non-temporary
vim.api.nvim_create_user_command("KeepBufferAlive", function()
    vim.opt_local.buflisted = true
    vim.opt_local.bufhidden = ""
    -- Hacky way to get the tabline to redraw, but the redrawtabline command
    -- doesn't seem to work
    vim.opt.showtabline = 2
end, {})

-- Enter winresizer with <leader>r
vim.g.winresizer_start_key = "<leader>r"
-- Exit winresizer with r
vim.g.winresizer_keycode_finish = string.byte("r")
-- The default to change to resize mode is r, so change it to Shift+r
vim.g.winresizer_keycode_resize = string.byte("R")
