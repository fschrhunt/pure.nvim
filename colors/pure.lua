-- pure: a soft, dark color scheme with a transparent background.
--
-- Every color comes from the palette below, so the editor looks the same in
-- any terminal; only the background is left to the terminal. Code keeps
-- color for what you scan for (keywords, definitions, types, literals) and
-- leaves calls, variables and brackets in the plain text color.
-- Requires 'termguicolors'.

vim.cmd.highlight('clear')
vim.g.colors_name = 'pure'

local c = {
  text = '#d4d9e8', -- plain text
  muted = '#7f87a2', -- comments, quiet UI text
  faint = '#454b63', -- line numbers, borders
  shade = '#2b3047', -- selection, current menu item
  ink = '#171a26', -- dark text on bright highlights

  purple = '#b79cf2', -- keywords
  blue = '#80a6f2', -- definitions
  sky = '#7cc8f0', -- types
  cyan = '#8ad8f0', -- operators, punctuation
  coral = '#f2838f', -- built-ins: nil, true, len, error
  orange = '#f2a46e', -- numbers and constants
  yellow = '#e3bd7d', -- warnings, todos
  green = '#a8d48a', -- strings

  diff_add = '#1f3328',
  diff_change = '#1f2a3f',
  diff_text = '#2c3f60',
  diff_delete = '#3a2129',
}

local groups = {
  -- Base syntax (used by every language)
  Normal = { fg = c.text },
  Comment = { fg = c.muted, italic = true },
  Constant = { fg = c.orange },
  String = { fg = c.green },
  Character = { fg = c.green },
  Identifier = { fg = c.text },
  Function = { fg = c.blue },
  Statement = { fg = c.purple, italic = true },
  Operator = { fg = c.cyan },
  PreProc = { fg = c.purple, italic = true },
  Type = { fg = c.sky },
  Special = { fg = c.cyan },
  Delimiter = { fg = c.cyan },
  Title = { fg = c.blue, bold = true },
  Todo = { fg = c.yellow, bold = true },
  Error = { fg = c.coral },
  Underlined = { underline = true },

  -- Tree-sitter refinements
  ['@variable'] = { fg = c.text },
  ['@variable.builtin'] = { fg = c.coral },
  ['@constant.builtin'] = { fg = c.coral },
  ['@function.builtin'] = { fg = c.coral },
  ['@type.builtin'] = { fg = c.coral },
  ['@function.call'] = { fg = c.text },
  ['@function.method.call'] = { fg = c.text },
  ['@keyword.function'] = { fg = c.blue },
  ['@constructor'] = { fg = c.sky },
  ['@property'] = { fg = c.text },
  ['@module'] = { fg = c.text },
  ['@punctuation.bracket'] = { fg = c.text },
  ['@string.escape'] = { fg = c.cyan },
  ['@markup.heading'] = { fg = c.blue, bold = true },
  ['@markup.raw'] = { fg = c.green },
  ['@markup.link'] = { fg = c.sky, underline = true },

  -- Editor
  LineNr = { fg = c.faint },
  CursorLineNr = { fg = c.text, bold = true },
  CursorLine = {},
  SignColumn = {},
  FoldColumn = { fg = c.faint },
  Folded = { fg = c.muted },
  NonText = { fg = c.faint },
  Whitespace = { fg = c.faint },
  SpecialKey = { fg = c.faint },
  Conceal = { fg = c.muted },
  MatchParen = { fg = c.orange, bold = true },
  Visual = { bg = c.shade },
  Search = { fg = c.ink, bg = c.yellow },
  CurSearch = { fg = c.ink, bg = c.orange },
  IncSearch = { link = 'CurSearch' },
  Substitute = { link = 'CurSearch' },
  Directory = { fg = c.blue },
  QuickFixLine = { bg = c.shade },
  SpellBad = { undercurl = true, sp = c.coral },
  SpellCap = { undercurl = true, sp = c.yellow },
  SpellLocal = { undercurl = true, sp = c.sky },
  SpellRare = { undercurl = true, sp = c.purple },

  -- Bars, splits and popups
  StatusLine = { fg = c.muted },
  StatusLineNC = { fg = c.faint },
  WinSeparator = { fg = c.faint },
  TabLine = { fg = c.muted },
  TabLineFill = {},
  TabLineSel = { fg = c.text, bold = true },
  NormalFloat = { fg = c.text },
  FloatBorder = { fg = c.faint },
  FloatTitle = { fg = c.blue, bold = true },
  Pmenu = { fg = c.text },
  PmenuBorder = { fg = c.faint },
  PmenuSel = { bg = c.shade, bold = true },
  PmenuMatch = { fg = c.blue },
  PmenuMatchSel = { fg = c.blue, bg = c.shade, bold = true },
  PmenuSbar = {},
  PmenuThumb = { bg = c.faint },

  -- Messages
  ErrorMsg = { fg = c.coral },
  WarningMsg = { fg = c.yellow },
  MoreMsg = { fg = c.blue },
  Question = { fg = c.blue },
  ModeMsg = { fg = c.muted },
  OkMsg = { fg = c.green },

  -- Diffs and diagnostics
  Added = { fg = c.green },
  Changed = { fg = c.yellow },
  Removed = { fg = c.coral },
  DiffAdd = { bg = c.diff_add },
  DiffChange = { bg = c.diff_change },
  DiffText = { bg = c.diff_text },
  DiffDelete = { fg = c.coral, bg = c.diff_delete },
  DiagnosticError = { fg = c.coral },
  DiagnosticWarn = { fg = c.yellow },
  DiagnosticInfo = { fg = c.blue },
  DiagnosticHint = { fg = c.cyan },
  DiagnosticOk = { fg = c.green },
  DiagnosticUnderlineError = { undercurl = true, sp = c.coral },
  DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
  DiagnosticUnderlineInfo = { undercurl = true, sp = c.blue },
  DiagnosticUnderlineHint = { undercurl = true, sp = c.cyan },
  LspCodeLens = { fg = c.muted },

  -- File icons (mini.icons): each icon color maps onto the palette
  MiniIconsAzure = { fg = c.sky },
  MiniIconsBlue = { fg = c.blue },
  MiniIconsCyan = { fg = c.cyan },
  MiniIconsGreen = { fg = c.green },
  MiniIconsGrey = { fg = c.muted },
  MiniIconsOrange = { fg = c.orange },
  MiniIconsPurple = { fg = c.purple },
  MiniIconsRed = { fg = c.coral },
  MiniIconsYellow = { fg = c.yellow },

  -- Picker (mini.pick) and file explorer (mini.files)
  MiniPickMatchCurrent = { bg = c.shade, bold = true },
  MiniPickMatchRanges = { fg = c.blue, bold = true },
  MiniPickPrompt = { fg = c.text },
  MiniPickPromptPrefix = { fg = c.purple },
  MiniPickHeader = { fg = c.muted },
  MiniPickPreviewLine = { bg = c.shade },
  MiniFilesCursorLine = { bg = c.shade, bold = true },
  MiniFilesTitle = { fg = c.muted },

  -- Space-key hints (mini.clue)
  MiniClueNextKey = { fg = c.blue, bold = true },
  MiniClueDescSingle = { fg = c.text },
  MiniClueDescGroup = { fg = c.purple },
  MiniClueSeparator = { fg = c.faint },
}

for name, spec in pairs(groups) do
  vim.api.nvim_set_hl(0, name, spec)
end
