require("which-key").register({
    -- Use Ctrl+e to delete a buffer without closing the window
    ["<C-w>e"] = { "<cmd>Bwipeout<cr>", "Delete buffer" },
    ["<C-w><C-e>"] = { "<cmd>Bwipeout<cr>", "which_key_ignore" },

    -- <leader>f to toggle focus on current window, meaning hiding all other
    -- windows and current window takes full space.
    ["<leader>f"] = { require("true-zen").focus,
                      "Toggle focus on current window" }
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

-- When opening a new window in a split put the new window to the right
-- instead of the current window
vim.opt.splitright = true
