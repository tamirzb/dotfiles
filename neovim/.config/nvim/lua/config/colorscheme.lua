-- Custom colorscheme, mostly inspired by the old vim-hybrid, but with a lot of
-- modifications

local colors = require("config.colors")

local colorscheme = {
    -- Syntax colors, based on old vim-hybrid
    -- This is for how "old" vim did syntax, i.e. without treesitter/LSP, but
    -- then treesitter & LSP still base themselves on these
    Type = { fg = colors.orange }, -- int, long, char, etc.
    StorageClass = { fg = colors.orange }, -- static, register, volatile, etc.
    Structure = { fg = colors.aqua }, -- struct, union, enum, etc.
    Comment = { fg = colors.comment }, -- any comment
    Conditional = { fg = colors.blue }, -- if, then, else, endif, switch, etc.
    Constant = { fg = colors.red }, -- any constant
    Character = { fg = colors.red }, -- a character constant: 'c', '\n'
    Number = { fg = colors.red }, -- a number constant: 234, 0xff
    Boolean = { fg = colors.red }, -- a boolean constant: TRUE, false
    Float = { fg = colors.red }, -- a floating point constant: 2.3e10
    Function = { fg = colors.yellow }, -- function name
    Identifier = { fg = colors.purple }, -- any variable name
    Statement = { fg = colors.blue }, -- any statement
    Keyword = { fg = colors.blue }, -- any other keyword
    Label = { fg = colors.blue }, -- case, default, etc.
    Operator = { fg = colors.aqua }, -- "sizeof", "+", "*", etc.
    Exception = { fg = colors.blue }, -- try, catch, throw
    PreProc = { fg = colors.aqua }, -- generic Preprocessor
    Include = { fg = colors.aqua }, -- preprocessor #include
    Define = { fg = colors.aqua }, -- preprocessor #define
    Macro = { fg = colors.aqua }, -- same as Define
    Typedef = { fg = colors.orange }, -- a typedef
    PreCondit = { fg = colors.aqua }, -- preprocessor #if, #else, #endif, etc.
    Repeat = { fg = colors.blue }, -- for, do, while, etc.
    String = { fg = colors.green }, -- a string constant: "this is a string"
    Special = { fg = colors.green }, -- any special symbol
    SpecialChar = { fg = colors.green }, -- special character in a constant
    Tag = { fg = colors.green }, -- you can use CTRL-] on this
    Delimiter = { fg = colors.green }, -- character that needs attention
    SpecialComment = { fg = colors.green }, -- special things inside a comment
    Debug = { fg = colors.green }, -- debugging statements
    Underlined = { fg = colors.paleblue, underline = true }, -- e.g. links
    Ignore = { fg = colors.disabled }, -- left blank, hidden
    Error = { fg = colors.error, bold = true, underline = true },
    Todo = { fg = colors.yellow }, -- e.g. TODO, XXX, FIXME

    htmlLink = { fg = colors.paleblue, underline = true },
    htmlH1 = { fg = colors.aqua, bold = true },
    htmlH2 = { fg = colors.red, bold = true },
    htmlH3 = { fg = colors.green, bold = true },
    htmlH4 = { fg = colors.yellow, bold = true },
    htmlH5 = { fg = colors.purple, bold = true },
    markdownH1 = { fg = colors.aqua, bold = true },
    markdownH2 = { fg = colors.red, bold = true },
    markdownH3 = { fg = colors.green, bold = true },
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
    Folded = { fg = colors.disabled, italic = true },
    FoldColumn = { fg = colors.inactive },
    IncSearch = { fg = colors.title, bg = colors.selection,
                  underline = true },
    LineNr = { fg = colors.line_numbers, bg = colors.background },
    CursorLineNr = { fg = colors.yellow, bg = colors.background },
    MatchParen = { fg = colors.yellow, bold = true },
    ModeMsg = { fg = colors.yellow },
    MoreMsg = { fg = colors.yellow },
    NonText = { fg = colors.disabled },
    Pmenu = { fg = colors.text, bg = colors.window },
    PmenuSbar = { bg = colors.window },
    PmenuThumb = { bg = colors.selection },
    PmenuSel = { fg = colors.window, bg = colors.blue },
    Question = { fg = colors.green },
    Search = { fg = colors.title, bg = colors.selection, bold = true },
    SignColumn = { fg = colors.text, bg = colors.background },
    SpecialKey = { fg = colors.purple },
    Title = { fg = colors.yellow },
    Visual = { bg = colors.selection },
    VisualNOS = { bg = colors.selection },
    WarningMsg = { fg = colors.yellow },
    Whitespace = { fg = colors.selection },
    WildMenu = { fg = colors.orange, bold = true },
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
    SpellBad = { fg = colors.error, italic = true, underline = true },
    SpellCap = { fg = colors.blue, italic = true, underline = true },
    SpellLocal = { fg = colors.aqua, italic = true, underline = true },
    SpellRare = { fg = colors.purple, italic = true, underline = true },

    -- Colors for :checkhealth
    healthError = { fg = colors.error },
    healthSuccess = { fg = colors.green },
    healthWarning = { fg = colors.yellow },
}

-- Apply the colorscheme
require("config.utils").apply_highlights(colorscheme)
