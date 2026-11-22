# Colors

`pure` is a soft, dark color scheme. Code sits on whatever background your terminal has, and
floating panels (the palette, pickers, completion, key hints, and toasts) are solid blocks of a
surface color with padding and no outline. Toasts add a thin blue bar down their left side. It lives in one file, `colors/pure.lua`.

## The palette

Every color in the scheme comes from this table at the top of the file. Change a value there and
it changes everywhere.

| Name | Hex | Used for |
| --- | --- | --- |
| `text` | `#d4d9e8` | Plain text, variables, function calls |
| `muted` | `#7f87a2` | Comments, quiet interface text |
| `faint` | `#454b63` | Line numbers, borders, dividers |
| `surface` | `#1c2031` | Floating panels: palette, pickers, completion, key hints, toasts |
| `shade` | `#2b3047` | Selections and the current item in a list |
| `ink` | `#171a26` | Dark text on bright highlights, like search matches |
| `purple` | `#b79cf2` | Keywords, in italics |
| `blue` | `#80a6f2` | Function and type definitions |
| `sky` | `#7cc8f0` | Types |
| `cyan` | `#8ad8f0` | Operators and punctuation |
| `coral` | `#f2838f` | Built-ins like `nil` and `len`; errors |
| `orange` | `#f2a46e` | Numbers and constants |
| `yellow` | `#e3bd7d` | Warnings, todos, search matches |
| `green` | `#a8d48a` | Strings |

Diffs add four quiet backgrounds (`diff_add`, `diff_change`, `diff_text`, `diff_delete`).

## The idea

Color marks what you scan for: keywords, definitions, types, and literals. Calls, variables, and
brackets stay in the plain text color, so code reads calmly instead of as a rainbow. Interface
elements use the grays. Things that float above your code get a panel; things that are part of the
layout, like splits and the file explorer's columns, stay transparent.

The same palette colors file icons, the picker, the file explorer, the Space-key hints, git
changes, and diagnostics, so plugins look like part of the editor.

## Changing it

- To adjust a color, change its hex value in the palette table.
- To change what something looks like, find its group in the `groups` table, such as `Comment` or
  `Function`, and point it at a different palette color.
- To find the group for something on screen, put the cursor on it and run `:Inspect`.

Restart Neovim, or run `:colorscheme pure`, to see a change.

## Terminal and font

The scheme expects a dark terminal background and a terminal with true color, which every modern
macOS and Linux terminal has. File icons need a [Nerd Font](https://www.nerdfonts.com); Meslo
(`brew install --cask font-meslo-lg-nerd-font`, then choose `MesloLGS Nerd Font`) is a clean
choice close to Menlo.
