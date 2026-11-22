# Keys

pure.nvim keeps very few keys of its own. Everyday actions are on Space, everything else is in the
command palette, and the rest are Neovim's own keys, which work the same as in any tutorial.

Lost? Press `Space p` and type what you want to do, or press Space and pause to see every Space
key.

## Space keys

| Key | Action |
| --- | --- |
| `Space p` | Command palette: every action, with its key |
| `Space f` | Find a file |
| `Space /` | Search text in the project |
| `Space e` | Browse the current file's folder |
| `Space r` | Recent files |
| `Space d` | Show problems |
| `Space w` | Save |
| `Space q` | Close the file (asks before discarding changes) |
| `Space -` | Split below |
| `Space +` | Split right |
| `Space x` | Close the window |
| `Space ?` | Search Neovim's help |

Palette only: open files, new file, save all, copy file path, open a terminal, format the file,
git changes, undo history, compare files, toggles for wrap, line numbers and spell check, edit the
config, update plugins, and restart or quit Neovim.

## Getting around

| Key | Does |
| --- | --- |
| `Ctrl-o` / `Ctrl-i` | Back / forward to where you were, across files |
| `gg` / `G` | Top / bottom of the file |
| `Ctrl-d` / `Ctrl-u` | Half a page down / up |
| `%` | Jump to the matching bracket |
| `/text`, then `n` / `N` | Search, then next / previous match |
| `*` | Search for the word under the cursor |
| `Esc` | Clear the search highlight |
| `Ctrl-w` then `h` `j` `k` `l` | Move between split windows |

## Editing

| Key | Does |
| --- | --- |
| `i` / `a` / `o` | Insert before the cursor / after it / on a new line below |
| `u` / `Ctrl-r` | Undo / redo (undo survives closing the file) |
| `.` | Repeat the last change |
| `ciw` / `ci"` / `di(` | Change a word / change inside quotes / empty the parentheses |
| `gcc` / `gc` | Comment a line / a selection |
| `v` then `an` / `in` | Grow / shrink a selection by code structure |
| `zc` / `zo` | Close / open a fold |
| `:%s/old/new/gc` | Replace across the file, confirming each |

Copying (`y`) also copies to the system clipboard. Paste from the system with `Cmd-V`.

## Code

These work once a language server is running for the file; see [languages](languages.md).

| Key | Does |
| --- | --- |
| `Ctrl-]` | Go to definition |
| `K` | Show docs for what's under the cursor |
| `grr` | Find references |
| `grn` | Rename everywhere |
| `gra` | Code actions |
| `gO` | Outline of the file |
| `]d` / `[d` | Next / previous problem |
| `]h` / `[h` | Next / previous git change |

Suggestions appear while typing. `Tab` and `Shift-Tab` move through them (or through snippet
fields) and `Enter` accepts one, which also adds any import it needs.

## In the picker

The picker is the centered window behind `Space f`, `/`, `r`, `d`, `?` and the palette.

| Key | Does |
| --- | --- |
| Type | Narrow the list (fuzzy) |
| `↑` `↓` or `Ctrl-p` `Ctrl-n` | Move |
| `Enter` | Open or run |
| `Ctrl-v` / `Ctrl-s` | Open in a split right / below |
| `Tab` | Show or hide a preview |
| `Esc` | Close |

## In the file explorer

The explorer (`Space e`) opens on the current file, with its folder on the left and a preview on
the right. The columns grow with the window: the current folder takes about a third of it.

| Key | Does |
| --- | --- |
| `]` / `[` | Forward into a folder / back out of it (`l` / `h` also work) |
| `Enter` | Open the file full screen |
| `q` | Close |
| `=` | Apply edits: rename by editing a name, create by adding a line, delete by removing one |
| `g?` | Show every explorer key |

Deleted files go to a trash folder in Neovim's data directory, not straight to permanent deletion.
