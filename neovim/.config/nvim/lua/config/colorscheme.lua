-- Custom colorscheme, mostly inspired by the old vim-hybrid, but with a lot of
-- modifications

local colors = require("config.colors")

local colorscheme = {
    -- Syntax colors
    Type = { fg = colors.orange },
    StorageClass = { fg = colors.orange },
    Structure = { fg = colors.aqua },
    Comment = { fg = colors.comment },
    Conditional = { fg = colors.blue },
    Constant = { fg = colors.red },
    Character = { fg = colors.red },
    Number = { fg = colors.red },
    Boolean = { fg = colors.red },
    Float = { fg = colors.red },
    Function = { fg = colors.yellow },
    Identifier = { fg = colors.purple },
    Statement = { fg = colors.blue },
    Keyword = { fg = colors.blue },
    Label = { fg = colors.blue },
    Operator = { fg = colors.aqua },
    Exception = { fg = colors.blue },
    PreProc = { fg = colors.aqua },
    Include = { fg = colors.aqua },
    Define = { fg = colors.aqua },
    Macro = { fg = colors.aqua },
    Typedef = { fg = colors.orange },
    PreCondit = { fg = colors.aqua },
    Repeat = { fg = colors.blue },
    String = { fg = colors.green },
    Special = { fg = colors.green },
    SpecialChar = { fg = colors.green },
    Tag = { fg = colors.green },
    Delimiter = { fg = colors.green },
    SpecialComment = { fg = colors.green },
    Debug = { fg = colors.green },
    Underlined = { fg = colors.paleblue, style = "underline" },
    Ignore = { fg = colors.disabled },
    Error = { fg = colors.error, style = "bold,underline" },
    Todo = { fg = colors.yellow },

    htmlLink = { fg = colors.paleblue, style = "underline" },
    htmlH1 = { fg = colors.aqua, style = "bold" },
    htmlH2 = { fg = colors.red, style = "bold" },
    htmlH3 = { fg = colors.green, style = "bold" },
    htmlH4 = { fg = colors.yellow, style = "bold" },
    htmlH5 = { fg = colors.purple, style = "bold" },
    markdownH1 = { fg = colors.aqua, style = "bold" },
    markdownH2 = { fg = colors.red, style = "bold" },
    markdownH3 = { fg = colors.green, style = "bold" },
    markdownH1Delimiter = { fg = colors.aqua },
    markdownH2Delimiter = { fg = colors.red },
    markdownH3Delimiter = { fg = colors.green },

    -- Editor colors
    Normal = { fg = colors.text, bg = colors.background },
    NormalNC = { fg = colors.text, bg = colors.background },
    NormalFloat = { fg = colors.text, bg = colors.window },
    FloatBorder = { fg = colors.paleblue, bg = colors.window },
    ColorColumn = { bg = colors.current },
    Conceal = { fg = colors.disabled },
    Directory = { fg = colors.blue },
    -- Color for added text
    DiffAdd = { bg = colors.diff_add_light },
    DiffText = { bg = colors.diff_add_light },
    -- Color for an unmodified part of a modified line
    DiffChange = { bg = colors.diff_add_dark },
    -- Color for lines that were deleted
    DiffDelete = { fg = colors.diff_delete, bg = colors.diff_delete },
    ErrorMsg = { fg = colors.error },
    Folded = { fg = colors.disabled, style = "italic" },
    FoldColumn = { fg = colors.inactive },
    IncSearch = { fg = colors.title, bg = colors.selection,
                  style = "underline" },
    LineNr = { fg = colors.line_numbers, bg = colors.background },
    CursorLineNr = { fg = colors.yellow, bg = colors.background },
    MatchParen = { fg = colors.yellow, style = "bold" },
    ModeMsg = { fg = colors.yellow },
    MoreMsg = { fg = colors.yellow },
    NonText = { fg = colors.disabled },
    Pmenu = { fg = colors.text, bg = colors.window },
    PmenuSbar = { bg = colors.window },
    PmenuThumb = { bg = colors.selection },
    PmenuSel = { fg = colors.window, bg = colors.blue },
    Question = { fg = colors.green },
    Search = { fg = colors.title, bg = colors.selection, style = "bold" },
    SignColumn = { fg = colors.text, bg = colors.background },
    SpecialKey = { fg = colors.purple },
    Title = { fg = colors.title, style = "bold" },
    Visual = { bg = colors.selection },
    VisualNOS = { bg = colors.selection },
    WarningMsg = { fg = colors.yellow },
    Whitespace = { fg = colors.selection },
    WildMenu = { fg = colors.orange, style = "bold" },
    CursorColumn = { bg = colors.current },
    CursorLine = { bg = colors.current },
    VertSplit = { fg = colors.border },
    EndOfBuffer = { fg = colors.disabled },

    -- Colors for viewing diff files (e.g. patch files, git commit)
    diffAdded = { fg = colors.green },
    diffRemoved = { fg = colors.red },
    diffOldFile = { fg = colors.comment },
    diffNewFile = { fg = colors.title },

    -- Colors for spell checking
    SpellBad = { fg = colors.error, style = "italic,underline" },
    SpellCap = { fg = colors.blue, style = "italic,underline" },
    SpellLocal = { fg = colors.aqua, style = "italic,underline" },
    SpellRare = { fg = colors.purple, style = "italic,underline" },

    -- Colors for :checkhealth
    healthError = { fg = colors.error },
    healthSuccess = { fg = colors.green },
    healthWarning = { fg = colors.yellow },
}

-- Allow choosing from the whole 24bit color range
vim.o.termguicolors = true

-- Apply the colorscheme
require("config.utils").apply_highlights(colorscheme)
